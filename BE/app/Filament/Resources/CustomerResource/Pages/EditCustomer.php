<?php

namespace App\Filament\Resources\CustomerResource\Pages;

use App\Filament\Resources\CustomerResource;
use App\Models\Customer;
use Filament\Actions;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;

class EditCustomer extends EditRecord
{
    protected static string $resource = CustomerResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // A customer with sites/inspections can't be deleted (foreign
            // keys restrict it): explain instead of showing a 500 page.
            Actions\DeleteAction::make()
                ->before(function (Actions\DeleteAction $action, Customer $record) {
                    if ($record->sites()->exists() || $record->inspections()->exists()) {
                        Notification::make()
                            ->danger()
                            ->title('Cannot delete this customer')
                            ->body('It still has sites or inspections. Set its status to inactive instead.')
                            ->send();
                        $action->cancel();
                    }
                }),
        ];
    }
}
