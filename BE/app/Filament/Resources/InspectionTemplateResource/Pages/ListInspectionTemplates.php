<?php

namespace App\Filament\Resources\InspectionTemplateResource\Pages;

use App\Filament\Resources\InspectionTemplateResource;
use App\Models\InspectionTemplate;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

/**
 * "Templates" opens the builder on the first template; the table is only
 * shown when no template exists yet.
 */
class ListInspectionTemplates extends ListRecords
{
    protected static string $resource = InspectionTemplateResource::class;

    public function mount(): void
    {
        $first = InspectionTemplate::query()->orderBy('id')->first();
        if ($first) {
            $this->redirect(InspectionTemplateResource::getUrl('edit', ['record' => $first]));

            return;
        }
        parent::mount();
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()->label('New Template'),
        ];
    }
}
