<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Partner;
use App\Models\Order;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Admin user
        User::create([
            'name' => 'Admin ListrikApp',
            'email' => 'admin@listrikapp.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
        ]);

        // Sample Customer
        $customer = User::create([
            'name' => 'John Customer',
            'email' => 'customer@listrikapp.com',
            'password' => Hash::make('password123'),
            'phone' => '081234567890',
            'role' => 'customer',
        ]);

        // Sample Partner 1 (Bangsang)
        $partnerUser1 = User::create([
            'name' => 'Partner Bangsang One',
            'email' => 'bangsang1@example.com',
            'password' => Hash::make('password123'),
            'role' => 'partner',
        ]);

        $partner1 = Partner::create([
            'user_id' => $partnerUser1->id,
            'company_name' => 'Bangsang Services Co.',
            'type' => 'bangsang',
            'status' => 'verified',
            'balance' => 500000, // IDR 500k for withdrawal testing
        ]);

        // Create an old order for withdrawal eligibility
        Order::create([
            'agenda_number' => 'LSK-20260301-0001',
            'customer_id' => $customer->id,
            'partner_id' => $partner1->id,
            'service_type' => 'nidi_slo',
            'status' => 'generate',
            'address' => 'Old Street 123',
            'installation_type' => 'house',
            'power_capacity' => 1300,
            'total_price' => 150000,
            'created_at' => Carbon::now()->subDays(5),
            'updated_at' => Carbon::now()->subDays(5),
        ]);

        // Sample Partner 2 (Lit TR)
        $partnerUser2 = User::create([
            'name' => 'Partner Lit TR One',
            'email' => 'littr1@example.com',
            'password' => Hash::make('password123'),
            'role' => 'partner',
        ]);

        Partner::create([
            'user_id' => $partnerUser2->id,
            'company_name' => 'Lit TR Professionals',
            'type' => 'lit_tr',
            'status' => 'verified',
            'balance' => 0,
        ]);
    }
}
