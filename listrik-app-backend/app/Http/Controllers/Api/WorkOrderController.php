<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class WorkOrderController extends Controller
{
    /**
     * Get all orders assigned to the authenticated partner.
     */
    public function index(Request $request)
    {
        $partner = $request->user()->partner;

        $orders = Order::where('partner_id', $partner->id)
            ->with(['customer:id,name', 'lit:id,company_name'])
            ->latest()
            ->paginate(10);

        return response()->json($orders);
    }

    /**
     * Show full order details.
     */
    public function show($id, Request $request)
    {
        $partner = $request->user()->partner;

        $order = Order::where('partner_id', $partner->id)
            ->with(['customer', 'payment'])
            ->findOrFail($id);

        return response()->json([
            'order' => $order
        ]);
    }

    /**
     * Update order status.
     */
    public function updateStatus($id, Request $request)
    {
        $partner = $request->user()->partner;
        $order = Order::where('partner_id', $partner->id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'status' => 'required|string|in:in_progress,generate,completed'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $newStatus = $request->status;
        $currentStatus = $order->status;

        // Validation of transitions:
        // verified -> in_progress
        // in_progress -> generate
        // generate -> completed
        $allowedTransitions = [
            'verified' => ['in_progress'],
            'in_progress' => ['generate'],
            'generate' => ['completed'],
        ];

        if (!isset($allowedTransitions[$currentStatus]) || !in_array($newStatus, $allowedTransitions[$currentStatus])) {
            return response()->json([
                'message' => "Invalid status transition from {$currentStatus} to {$newStatus}."
            ], 400);
        }

        $order->update(['status' => $newStatus]);

        $statusMessages = [
            'in_progress' => 'Pesanan kamu sedang dikerjakan oleh mitra.',
            'generate' => 'Pekerjaan selesai! Sertifikat sedang digenerate.',
            'completed' => 'Pesanan telah selesai! Terima kasih telah menggunakan layanan kami.',
        ];

        Notification::create([
            'user_id' => $order->customer_id,
            'title' => 'Update Pesanan ' . $order->agenda_number,
            'message' => $statusMessages[$newStatus] ?? "Status pesanan berubah menjadi {$newStatus}.",
            'type' => $newStatus == 'completed' ? 'success' : 'info',
        ]);

        return response()->json([
            'message' => 'Order status updated successfully',
            'order' => $order
        ]);
    }
}
