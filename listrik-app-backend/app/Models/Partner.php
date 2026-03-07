<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Partner extends Model
{
    protected $fillable = [
        'user_id',
        'company_name',
        'type',
        'iujptl_number',
        'sbu_number',
        'bank_name',
        'bank_account_number',
        'bank_account_name',
        'status',
        'balance',
    ];

    /**
     * Get the user that owns the partner profile.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the orders associated with the partner.
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}
