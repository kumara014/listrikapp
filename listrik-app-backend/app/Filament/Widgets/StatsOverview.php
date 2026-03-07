<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use App\Models\Partner;
use App\Models\Payment;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Total Orders', Order::count())
                ->description('All orders in the system')
                ->descriptionIcon('heroicon-m-shopping-cart')
                ->color('info'),
            Stat::make('Pending Orders', Order::where('status', 'pending')->count())
                ->description('Orders awaiting verification')
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning'),
            Stat::make('Total Revenue', 'IDR ' . number_format(Payment::where('status', 'success')->sum('amount'), 0, ',', '.'))
                ->description('Total successful payments')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success'),
            Stat::make('Total Partners', Partner::where('status', 'verified')->count())
                ->description('Verified partners')
                ->descriptionIcon('heroicon-m-user-group')
                ->color('primary'),
            Stat::make('Total Customers', User::where('role', User::ROLE_CUSTOMER)->count())
                ->description('Registered customers')
                ->descriptionIcon('heroicon-m-users')
                ->color('success'),
        ];
    }
}
