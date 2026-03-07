<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsPartner
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user || $user->role !== 'partner') {
            return response()->json([
                'message' => 'Unauthorized. Only partners can access this resource.'
            ], 403);
        }

        if (!$user->partner || $user->partner->status !== 'verified') {
            return response()->json([
                'message' => 'Unauthorized. Your partner account is not verified yet.'
            ], 403);
        }

        return $next($request);
    }
}
