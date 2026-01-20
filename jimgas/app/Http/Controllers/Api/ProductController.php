<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    // 1. GET /api/products
    // Public: Customers use this to see what gas is available
    public function index()
    {
        // Return all active products, usually ordered by name
        return Product::where('is_active', true)->get();
    }

    // 2. POST /api/products
    // Protected (Admin Only): Add a new gas cylinder/refill to the system
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string', // e.g., "K-Gas 6kg"
            'brand' => 'required|string', // e.g., "K-Gas"
            'weight_kg' => 'required|integer', // e.g., 6
            'type' => 'required|in:refill,cylinder', // Just gas? or metal too?
            'price' => 'required|numeric',
            'stock_quantity' => 'required|integer',
        ]);

        $product = Product::create($request->all());

        return response()->json([
            'message' => 'Product created successfully',
            'product' => $product
        ], 201);
    }

    // 3. PUT /api/products/{id}
    // Protected (Admin Only): Update price or stock
    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $request->validate([
            'price' => 'numeric',
            'stock_quantity' => 'integer',
        ]);

        $product->update($request->all());

        return response()->json([
            'message' => 'Product updated',
            'product' => $product
        ]);
    }

    // 4. DELETE /api/products/{id}
    // Protected (Admin Only): Soft delete (just hide it from customers)
    public function destroy($id)
    {
        $product = Product::findOrFail($id);
        $product->update(['is_active' => false]);

        return response()->json(['message' => 'Product removed from catalog']);
    }
}
