<?php

namespace App\Filament\Resources\InspectionResource\Pages;

use App\Filament\Resources\InspectionResource;
use App\Filament\Resources\InspectionResource\Widgets\InspectionKpis;
use App\Models\Inspection;
use App\Models\InspectionItem;
use App\Models\InspectionTemplate;
use App\Models\Setting;
use App\Models\User;
use Filament\Actions;
use Filament\Forms;
use Filament\Forms\Get;
use Filament\Forms\Set;
use Filament\Resources\Pages\ListRecords;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

class ListInspections extends ListRecords
{
    protected static string $resource = InspectionResource::class;

    public function getSubheading(): ?string
    {
        return 'Manage and track all inspections across your sites and customers.';
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()
                ->label('New Inspection')
                ->icon('heroicon-m-plus')
                ->modalHeading('Schedule an inspection')
                ->form([Forms\Components\Grid::make(2)->schema([
                    Forms\Components\Select::make('template_id')->label('Template')
                        ->options(fn () => InspectionTemplate::query()->orderBy('name')->pluck('name', 'id'))
                        ->required(),
                    Forms\Components\Select::make('customer_id')->label('Customer')
                        ->relationship('customer', 'name')
                        ->live()
                        ->afterStateUpdated(fn (Set $set) => $set('site_id', null))
                        ->required(),
                    Forms\Components\Select::make('site_id')->label('Site')
                        ->relationship('site', 'name', fn (Builder $query, Get $get) => $query->where('customer_id', $get('customer_id')))
                        ->disabled(fn (Get $get) => blank($get('customer_id')))
                        ->required(),
                    Forms\Components\Select::make('inspector_id')->label('Inspector')
                        ->relationship('inspector', 'name', fn (Builder $query) => $query->where('role', User::ROLE_INSPECTOR))
                        ->required(),
                    Forms\Components\DateTimePicker::make('scheduled_at')->label('Scheduled at')
                        ->seconds(false)
                        ->required(),
                    Forms\Components\Select::make('recurrence')
                        ->options([
                            Inspection::RECURRENCE_ONE_TIME => 'One-time',
                            Inspection::RECURRENCE_WEEKLY => 'Weekly',
                            Inspection::RECURRENCE_MONTHLY => 'Monthly',
                            Inspection::RECURRENCE_QUARTERLY => 'Quarterly',
                        ])
                        ->default(fn () => Setting::valueOf('default_recurrence'))
                        ->required(),
                ])])
                ->using(fn (array $data) => $this->scheduleInspection($data)),
        ];
    }

    /**
     * Same as the API's POST /inspections: a scheduled inspection whose
     * checklist is a snapshot of the template's items, in template order.
     */
    private function scheduleInspection(array $data): Inspection
    {
        return DB::transaction(function () use ($data) {
            $inspection = Inspection::create([...$data, 'status' => Inspection::STATUS_SCHEDULED]);
            $template = InspectionTemplate::with('sections.checklistItems')->findOrFail($data['template_id']);

            $sortOrder = 0;
            foreach ($template->sections as $section) {
                foreach ($section->checklistItems as $checklistItem) {
                    InspectionItem::create([
                        'inspection_id' => $inspection->id,
                        'template_checklist_item_id' => $checklistItem->id,
                        'label' => $checklistItem->label,
                        'result' => null,
                        'note' => null,
                        'sort_order' => $sortOrder++,
                    ]);
                }
            }

            return $inspection;
        });
    }

    protected function getHeaderWidgets(): array
    {
        return [InspectionKpis::class];
    }

    public function getHeaderWidgetsColumns(): int|array
    {
        return 1;
    }
}
