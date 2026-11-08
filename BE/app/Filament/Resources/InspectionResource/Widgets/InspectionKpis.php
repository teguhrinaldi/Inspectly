<?php

namespace App\Filament\Resources\InspectionResource\Widgets;

use App\Support\InspectionStats;
use Filament\Widgets\Widget;

/** The dashboard's four KPI cards, above the Inspections table. */
class InspectionKpis extends Widget
{
    protected static string $view = 'filament.widgets.inspection-kpis';

    protected int|string|array $columnSpan = 'full';

    /** @return array<int, array<string, mixed>> */
    public function stats(): array
    {
        return (new InspectionStats)->kpis();
    }
}
