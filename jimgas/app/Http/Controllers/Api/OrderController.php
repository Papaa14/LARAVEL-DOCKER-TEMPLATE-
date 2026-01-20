<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    // 1. Customer places an order
    public function store(Request $request)
    {
        $request->validate([
            'delivery_address' => 'required|string',
            'delivery_phone' => 'required|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
        ]);

        try {
            return DB::transaction(function () use ($request) {
                $totalAmount = 0;
                $orderItemsData = [];

                // Calculate totals and prepare item data
                foreach ($request->items as $item) {
                    $product = Product::findOrFail($item['product_id']);

                    // Optional: Check Stock
                    if($product->stock_quantity < $item['quantity']) {
                         throw new \Exception("Insufficient stock for " . $product->name);
                    }

                    $subtotal = $product->price * $item['quantity'];
                    $totalAmount += $subtotal;

                    $orderItemsData[] = [
                        'product_id' => $product->id,
                        'product_name' => $product->name,
                        'quantity' => $item['quantity'],
                        'unit_price' => $product->price,
                        'subtotal' => $subtotal,
                    ];
                }

                // Create Order
                $order = Order::create([
                    'user_id' => auth()->id(),
                    'order_number' => 'GAS-' . strtoupper(Str::random(8)),
                    'status' => 'pending',
                    'payment_method' => 'cod', // Cash on Delivery
                    'payment_status' => 'pending',
                    'total_amount' => $totalAmount,
                    'delivery_address' => $request->delivery_address,
                    'delivery_phone' => $request->delivery_phone,
                    'notes' => $request->notes,
                ]);

                // Create Order Items
                foreach ($orderItemsData as $data) {
                    $order->items()->create($data);
                }

                return response()->json([
                    'message' => 'Order placed successfully',
                    'order_number' => $order->order_number
                ], 201);
            });

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    // 2. Customer sees their own orders
    public function index()
    {
        $orders = Order::with('items')
                    ->where('user_id', auth()->id())
                    ->latest()
                    ->get();
        return response()->json($orders);
    }

    // 3. Admin: Update Status (e.g., Deliver & Pay)
    public function updateStatus(Request $request, $id)
    {
        // Ensure user is admin/staff via Spatie
        // $this->authorize('manage orders');

        $request->validate([
            'status' => 'required|in:pending,confirmed,out_for_delivery,delivered,cancelled',
            'payment_status' => 'required|in:pending,paid'
        ]);

        $order = Order::findOrFail($id);
        $order->update([
            'status' => $request->status,
            'payment_status' => $request->payment_status
        ]);

        return response()->json(['message' => 'Order updated']);
    }
}
