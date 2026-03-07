<?php

namespace App\Services;

class PricingService
{
    /**
     * Calculate order total_price based on service_type and power_capacity.
     */
    public function calculate($serviceType, $powerCapacity)
    {
        $basePrices = [
            'nidi' => 500000,
            'slo' => 350000,
            'nidi_slo' => 800000,
            'full_package' => 1200000,
        ];

        $totalPrice = $basePrices[$serviceType] ?? 0;

        if ($powerCapacity > 5500) {
            $totalPrice += 100000;
        } elseif ($powerCapacity > 2200) {
            $totalPrice += 50000;
        }

        return (int) $totalPrice;
    }
}
