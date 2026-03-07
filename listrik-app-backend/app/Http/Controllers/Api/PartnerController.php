<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Partner;
use Illuminate\Http\Request;

class PartnerController extends Controller
{
    /**
     * Display a listing of verified partners.
     */
    public function index(Request $request)
    {
        $query = Partner::query()->where('status', 'verified');

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $partners = $query->paginate(10);

        return response()->json($partners);
    }

    /**
     * Display the specified partner.
     */
    public function show($id)
    {
        $partner = Partner::with('user')->findOrFail($id);

        return response()->json($partner);
    }
}
