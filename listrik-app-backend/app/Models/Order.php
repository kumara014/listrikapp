<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Order extends Model
{
    protected $fillable = [
        'agenda_number',
        'customer_id',
        'partner_id',
        'lit_id',
        'service_type',
        'status',
        'address',
        'latitude',
        'longitude',
        'installation_type',
        'power_capacity',
        'total_price',
        'notes',
    ];

    /**
     * Get the customer that owns the order.
     */
    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    /**
     * Get the partner for the order.
     */
    public function partner(): BelongsTo
    {
        return $this->belongsTo(Partner::class, 'partner_id');
    }

    /**
     * Get the LIT partner for the order.
     */
    public function lit(): BelongsTo
    {
        return $this->belongsTo(Partner::class, 'lit_id');
    }

    /**
     * Get the payment associated with the order.
     */
    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class);
    }
}
