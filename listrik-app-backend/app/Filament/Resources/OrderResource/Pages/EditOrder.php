<?php

namespace App\Filament\Resources\OrderResource\Pages;

use App\Filament\Resources\OrderResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use App\Models\Notification;

class EditOrder extends EditRecord
{
    protected static string $resource = OrderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }

    protected function afterSave(): void
    {
        $order = $this->record;
        
        $message = "Status pesanan {$order->agenda_number} telah diperbarui menjadi {$order->status}.";
        if ($order->status == 'verified') {
            $message = "Horee! 🎉 Pesanan {$order->agenda_number} telah diverifikasi oleh Admin. Silakan lanjutkan ke pembayaran.";
        } else if ($order->status == 'in_progress') {
            $message = "Pesanan sedang dikerjakan oleh teknisi ahli kami.";
        }

        Notification::create([
            'user_id' => $order->customer_id,
            'title' => 'Update Status Pesanan ⚡',
            'message' => $message,
            'type' => 'info',
        ]);
    }
}
