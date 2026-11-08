<?php

namespace App\Filament\Resources\SiteResource\Pages;

use App\Filament\Resources\SiteResource;
use App\Models\Site;
use Filament\Actions;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;

class EditSite extends EditRecord
{
    protected static string $resource = SiteResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // A site with inspections can't be deleted (foreign keys
            // restrict it): explain instead of showing a 500 page.
            Actions\DeleteAction::make()
                ->before(function (Actions\DeleteAction $action, Site $record) {
                    if ($record->inspections()->exists()) {
                        Notification::make()
                            ->danger()
                            ->title('Cannot delete this site')
                            ->body('It still has inspections. Set its status to inactive instead.')
                            ->send();
                        $action->cancel();
                    }
                }),
        ];
    }
}
