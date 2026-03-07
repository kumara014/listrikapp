<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PartnerController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PartnerProfileController;
use App\Http\Controllers\Api\WorkOrderController;
use App\Http\Controllers\Api\WithdrawalController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/google', [AuthController::class, 'googleLogin']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Public/Auth Partner Listing
    Route::get('/partners', [PartnerController::class, 'index']);
    Route::get('/partners/{id}', [PartnerController::class, 'show']);

    // Customer Order Routes
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{id}', [OrderController::class, 'show']);
    Route::post('/orders/{id}/cancel', [OrderController::class, 'cancel']);

    // Partner Working Routes
    Route::middleware('partner')->group(function () {
        Route::get('/partner/profile', [PartnerProfileController::class, 'show']);
        Route::put('/partner/profile', [PartnerProfileController::class, 'update']);
        Route::get('/partner/orders', [WorkOrderController::class, 'index']);
        Route::get('/partner/orders/{id}', [WorkOrderController::class, 'show']);
        Route::post('/partner/orders/{id}/status', [WorkOrderController::class, 'updateStatus']);
        Route::get('/partner/withdrawals', [WithdrawalController::class, 'index']);
        Route::post('/partner/withdrawals', [WithdrawalController::class, 'store']);
        Route::post('/partner/withdrawals/{id}/cancel', [WithdrawalController::class, 'cancel']);
    });
    // Notifications
    Route::get('/notifications', [App\Http\Controllers\Api\NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [App\Http\Controllers\Api\NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [App\Http\Controllers\Api\NotificationController::class, 'markAllAsRead']);
});
