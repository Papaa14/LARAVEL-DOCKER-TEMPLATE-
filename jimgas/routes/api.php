<?php

use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ProductController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// API Routes with Spatie Permission middleware examples
Route::middleware(['auth:sanctum'])->group(function () {

    // User management routes
    Route::middleware(['permission:manage users'])->group(function () {
        Route::get('/users', function () {
            return response()->json(['message' => 'Users list']);
        });
        Route::post('/users', function () {
            return response()->json(['message' => 'User created']);
        });
    });
    // Customer Actions
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/my-orders', [OrderController::class, 'index']);

    // Admin routes
    Route::middleware(['role:admin'])->group(function () {
        Route::get('/admin/dashboard', function () {
            return response()->json(['message' => 'Admin dashboard']);
        });
        Route::post('/products', [ProductController::class, 'store']); // Add product
        Route::put('/products/{id}', [ProductController::class, 'update']);
        Route::patch('/orders/{id}/status', [OrderController::class, 'updateStatus']);
        Route::get('/admin/orders', [OrderController::class, 'allOrders']);
    });

    // Permission management
    Route::middleware(['permission:manage permissions'])->group(function () {
        Route::get('/permissions', function () {
            return response()->json(['message' => 'Permissions list']);
        });
        Route::get('/roles', function () {
            return response()->json(['message' => 'Roles list']);
        });
    });
});

// Public Routes
Route::get('/products', [ProductController::class, 'index']);
