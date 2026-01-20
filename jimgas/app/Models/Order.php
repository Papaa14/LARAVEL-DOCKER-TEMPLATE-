<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'order_number', 'status', 'payment_method',
        'payment_status', 'total_amount', 'delivery_address',
        'delivery_phone', 'notes'
    ];

    // Relationship: Who made the order?
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relationship: What is in the order?
    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
}
