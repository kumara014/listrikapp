<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Withdrawal extends Model
{
    protected $fillable = [
        'partner_id',
        'amount',
        'status',
        'requested_at',
        'processed_at',
        'notes',
    ];

    /**
     * Get the partner that owns the withdrawal request.
     */
    public function partner(): BelongsTo
    {
        return $this->belongsTo(Partner::class);
    }
}
