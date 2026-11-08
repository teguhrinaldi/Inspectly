<?php

namespace App\Filament\Pages;

use App\Filament\Resources\InspectionResource;
use App\Models\Inspection;
use Filament\Pages\Page;
use Filament\Tables;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Table;

/**
 * Completed inspections with their computed results. The PDF itself is
 * generated on the inspector's device; each row opens the full inspection
 * record (checklist, findings, evidence, signatures).
 */
class Reports extends Page implements HasTable
{
    use InteractsWithTable;

    protected static ?string $navigationIcon = 'heroicon-o-document-chart-bar';

    protected static ?int $navigationSort = 7;

    protected static string $view = 'filament.pages.reports';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Inspection::query()
                    ->where('status', Inspection::STATUS_COMPLETED)
                    ->with(['site', 'template', 'inspector'])
                    ->withCount([
                        'findings',
                        'findings as serious_findings_count' => fn ($q) => $q->whereIn('severity', ['critical', 'high']),
                    ])
            )
            ->defaultSort('completed_at', 'desc')
            ->columns([
                Tables\Columns\TextColumn::make('site.name')->label('Site')->searchable()->weight('semibold'),
                Tables\Columns\TextColumn::make('template.name')->label('Template'),
                Tables\Columns\TextColumn::make('inspector.name')->label('Inspector'),
                Tables\Columns\TextColumn::make('completed_at')->label('Completed')->dateTime('M j, Y · H:i')->sortable(),
                Tables\Columns\TextColumn::make('pass_percentage')
                    ->label('Pass rate')
                    ->formatStateUsing(fn ($state) => $state === null ? '—' : round((float) $state).'%')
                    ->badge()
                    ->color(fn ($state) => (float) $state >= 80 ? 'success' : 'warning')
                    ->sortable(),
                Tables\Columns\TextColumn::make('findings_count')->label('Findings'),
                Tables\Columns\TextColumn::make('serious_findings_count')
                    ->label('Critical / High')
                    ->badge()
                    ->color(fn ($state) => $state > 0 ? 'danger' : 'gray'),
                Tables\Columns\TextColumn::make('next_due_at')->label('Next due')->date('M j, Y')->placeholder('—'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('template_id')->relationship('template', 'name')->label('Template'),
                Tables\Filters\SelectFilter::make('site_id')->relationship('site', 'name')->label('Site'),
            ])
            ->recordUrl(fn (Inspection $record) => InspectionResource::getUrl('view', ['record' => $record]));
    }
}
