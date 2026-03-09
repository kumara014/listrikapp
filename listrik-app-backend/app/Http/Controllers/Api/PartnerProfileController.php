<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PartnerProfileController extends Controller
{
    /**
     * Show the authenticated partner's profile.
     */
    public function show(Request $request)
    {
        $partner = $request->user()->partner->load('user');

        return response()->json([
            'data' => $partner
        ]);
    }

    /**
     * Update the authenticated partner's profile.
     */
    public function update(Request $request)
    {
        $user = $request->user();
        $partner = $user->partner;

        $validator = Validator::make($request->all(), [
            'company_name' => 'required|string|max:255',
            'bank_name' => 'required|string|max:255',
            'bank_account_number' => 'required|string|max:255',
            'bank_account_name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Update Partner info
        $partner->update($request->only([
            'company_name',
            'bank_name',
            'bank_account_number',
            'bank_account_name'
        ]));

        // Update User info (phone)
        $user->update(['phone' => $request->phone]);

        return response()->json([
            'message' => 'Profile updated successfully',
            'data' => $partner->load('user')
        ]);
    }
}
