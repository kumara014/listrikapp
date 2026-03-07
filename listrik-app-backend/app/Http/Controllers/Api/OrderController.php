<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Notification;
use App\Services\PricingService;
use Illuminate\Http\Request;
use Carbon\Carbon;

class OrderController extends Controller
{
    protected $pricingService;

    public function __construct(PricingService $pricingService)
    {
        $this->pricingService = $pricingService;
    }

    /**
     * Display a listing of orders for the authenticated customer.
     */
    public function index(Request $request)
    {
        $orders = Order::where('customer_id', $request->user()->id)
            ->with(['partner', 'lit', 'payment'])
            ->latest()
            ->paginate(10);

        return response()->json($orders);
    }

    /**
     * Store a newly created order.
     */
    public function store(Request $request)
    {
        $request->validate([
            'service_type' => 'required|in:nidi,slo,nidi_slo,full_package',
            'partner_id' => 'nullable|exists:partners,id',
            'lit_id' => 'nullable|exists:partners,id',
            'address' => 'required|string',
            'latitude' => 'nullable|string',
            'longitude' => 'nullable|string',
            'installation_type' => 'required|string',
            'power_capacity' => 'required|integer',
            'notes' => 'nullable|string',
        ]);

        $totalPrice = $this->pricingService->calculate(
            $request->service_type,
            $request->power_capacity
        );

        $agendaNumber = 'LSK-' . Carbon::now()->format('Ymd') . '-' . strtoupper(bin2hex(random_bytes(2)));

        $order = Order::create([
            'agenda_number' => $agendaNumber,
            'customer_id' => $request->user()->id,
            'partner_id' => $request->partner_id,
            'lit_id' => $request->lit_id,
            'status' => 'pending',
            'service_type' => $request->service_type,
            'address' => $request->address,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'installation_type' => $request->installation_type,
            'power_capacity' => $request->power_capacity,
            'total_price' => $totalPrice,
            'notes' => $request->notes,
        ]);

        Notification::create([
            'user_id' => $request->user()->id,
            'title' => 'Pesanan Baru Berhasil! 🎉',
            'message' => "Pesanan dengan nomor agenda {$agendaNumber} telah dibuat dan sedang menunggu verifikasi.",
            'type' => 'success',
        ]);

        return response()->json($order, 201);
    }

    /**
     * Display the specified order.
     */
    public function show($id)
    {
        $order = Order::with(['customer', 'partner', 'lit', 'payment'])
            ->findOrFail($id);

        return response()->json($order);
    }

    /**
     * Cancel the specified order.
     */
    public function cancel(Request $request, $id)
    {
        $order = Order::findOrFail($id);

        // Ensure user owns the order
        if ($order->customer_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if (!in_array($order->status, ['pending', 'verified'])) {
            return response()->json([
                'message' => 'Cannot cancel order. Status is already ' . $order->status
            ], 422);
        }

        $order->update(['status' => 'cancelled']);

        return response()->json([
            'message' => 'Order cancelled successfully',
            'order' => $order
        ]);
    }
}
