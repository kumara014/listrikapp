<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Withdrawal;
use App\Models\Order;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class WithdrawalController extends Controller
{
    /**
     * Get all withdrawals for the authenticated partner.
     */
    public function index(Request $request)
    {
        $partner = $request->user()->partner;

        $withdrawals = Withdrawal::where('partner_id', $partner->id)
            ->latest()
            ->paginate(10);

        return response()->json($withdrawals);
    }

    /**
     * Store a new withdrawal request.
     */
    public function store(Request $request)
    {
        $partner = $request->user()->partner;

        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:1000'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $amount = $request->amount;

        // Validation: Amount <= Partner balance
        if ($amount > $partner->balance) {
            return response()->json([
                'message' => 'Insufficient balance for the withdrawal.'
            ], 422);
        }

        // Validation: No other pending withdrawal
        $hasPending = Withdrawal::where('partner_id', $partner->id)
            ->where('status', 'pending')
            ->exists();

        if ($hasPending) {
            return response()->json([
                'message' => 'You already have a pending withdrawal request.'
            ], 422);
        }

        // Validation: Partner has orders with status=generate for more than 3 days
        $threeDaysAgo = Carbon::now()->subDays(3);
        $hasGenerateOrderValid = Order::where('partner_id', $partner->id)
            ->where('status', 'generate')
            ->where('created_at', '<=', $threeDaysAgo)
            ->exists();

        if (!$hasGenerateOrderValid) {
            return response()->json([
                'message' => 'Withdrawal only allowed if you have generate orders that are older than 3 days.'
            ], 422);
        }

        return DB::transaction(function () use ($partner, $amount) {
            // Deduct from balance
            $partner->decrement('balance', $amount);

            // Create withdrawal request
            $withdrawal = Withdrawal::create([
                'partner_id' => $partner->id,
                'amount' => $amount,
                'status' => 'pending',
                'requested_at' => now(),
            ]);

            return response()->json([
                'message' => 'Withdrawal request created successfully.',
                'withdrawal' => $withdrawal
            ], 201);
        });
    }

    /**
     * Cancel a pending withdrawal.
     */
    public function cancel($id, Request $request)
    {
        $partner = $request->user()->partner;
        $withdrawal = Withdrawal::where('partner_id', $partner->id)->findOrFail($id);

        if ($withdrawal->status !== 'pending') {
            return response()->json([
                'message' => 'Only pending withdrawals can be cancelled.'
            ], 400);
        }

        DB::transaction(function () use ($partner, $withdrawal) {
            // Refund amount back to balance
            $partner->increment('balance', $withdrawal->amount);

            // Set to rejected or cancelled?
            // The prompt says "cancel: cancel a withdrawal only if status is still pending. Refund amount back to partner balance."
            // I'll update it to 'rejected' for bookkeeping or just delete?
            // Usually, mark as 'rejected' or add a 'cancelled' status.
            // But since enum only has ['pending', 'approved', 'rejected'], I'll use 'rejected' or maybe I should have added 'cancelled'.
            // For now, I'll use 'rejected' or just delete.
            // Let's use 'rejected' and add a note.
            $withdrawal->update([
                'status' => 'rejected',
                'notes' => 'Cancelled by partner.',
                'processed_at' => now()
            ]);
        });

        return response()->json([
            'message' => 'Withdrawal cancelled and amount refunded to your balance.'
        ]);
    }
}
