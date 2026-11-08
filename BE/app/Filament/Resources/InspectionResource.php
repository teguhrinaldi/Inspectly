<?php

namespace App\Filament\Resources;

use App\Filament\Resources\InspectionResource\Pages;
use App\Filament\Resources\InspectionResource\RelationManagers\EvidenceRelationManager;
use App\Filament\Resources\InspectionResource\RelationManagers\FindingsRelationManager;
use App\Filament\Resources\InspectionResource\RelationManagers\ItemsRelationManager;
use App\Models\Inspection;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

/**
 * Read-only-ish per architecture.md: inspectors do the real work from the
 * mobile app, so there is no "create inspection" page here. Admins can view
 * full detail (checklist items, findings, evidence) and make light edits
 * (status/schedule/inspector re-assignment) when needed.
 */
class InspectionResource extends Resource
{
    protected static ?string $model = Inspection::class;

    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-check';

    protected static ?int $navigationSort = 2;

    public static function getGloballySearchableAttributes(): array
    {
        return ['site.name', 'customer.name', 'template.name', 'inspector.name'];
    }

    public static function getGlobalSearchEloquentQuery(): Builder
    {
        return parent::getGlobalSearchEloquentQuery()->with(['site', 'template', 'inspector']);
    }

    public static function getGlobalSearchResultTitle(Model $record): string
    {
        return $record->site?->name.' · '.$record->template?->name;
    }

    public static function getGlobalSearchResultDetails(Model $record): array
    {
        return array_filter([
            'Inspector' => $record->inspector?->name,
            'Scheduled' => $record->scheduled_at?->format('M j, Y H:i'),
        ]);
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('template_id')
                    ->relationship('template', 'name')
                    ->required()
                    ->disabled(),
                Forms\Components\Select::make('customer_id')
                    ->relationship('customer', 'name')
                    ->required()
                    ->disabled(),
                Forms\Components\Select::make('site_id')
                    ->relationship('site', 'name')
                    ->required()
                    ->disabled(),
                Forms\Components\Select::make('inspector_id')
                    ->relationship('inspector', 'name')
                    ->required(),
                Forms\Components\Select::make('status')
                    ->options([
                        'draft' => 'Draft',
                        'scheduled' => 'Scheduled',
                        'in_progress' => 'In progress',
                        'completed' => 'Completed',
                    ])
                    ->required(),
                Forms\Components\DateTimePicker::make('scheduled_at'),
                Forms\Components\DateTimePicker::make('started_at')->disabled(),
                Forms\Components\DateTimePicker::make('completed_at')->disabled(),
                Forms\Components\Select::make('recurrence')
                    ->options([
                        'one_time' => 'One-time',
                        'weekly' => 'Weekly',
                        'monthly' => 'Monthly',
                        'quarterly' => 'Quarterly',
                    ])
                    ->required(),
                Forms\Components\DateTimePicker::make('next_due_at')->disabled(),
                Forms\Components\TextInput::make('pass_percentage')->numeric()->disabled()->suffix('%'),
            ])
            ->columns(2);
    }

    public static function table(Table $table): Table
    {
        $statuses = [
            'draft' => 'Draft',
            'scheduled' => 'Scheduled',
            'in_progress' => 'In Progress',
            'completed' => 'Completed',
        ];
        $dateTime = fn (string $column) => Tables\Columns\TextColumn::make($column)
            ->date('M j, Y')
            ->description(fn (Inspection $record) => $record->{$column}?->format('H:i:s'))
            ->placeholder('—')
            ->sortable();

        return $table
            ->modifyQueryUsing(fn (Builder $query) => $query
                ->with(['site', 'customer', 'template', 'inspector'])
                ->withCount(['items', 'items as answered_items_count' => fn (Builder $q) => $q->whereNotNull('result')]))
            ->defaultSort('scheduled_at', 'desc')
            ->recordUrl(fn (Inspection $record) => static::getUrl('view', ['record' => $record]))
            ->columns([
                Tables\Columns\ViewColumn::make('site.name')->label('Site')
                    ->view('filament.tables.site')->sortable(),
                Tables\Columns\TextColumn::make('customer.name')->label('Customer')
                    ->sortable()->wrap(),
                Tables\Columns\TextColumn::make('template.name')->label('Template')->sortable(),
                Tables\Columns\ViewColumn::make('inspector.name')->label('Inspector')
                    ->view('filament.tables.inspector')->sortable(),
                Tables\Columns\ViewColumn::make('status')->view('filament.tables.status')->sortable(),
                $dateTime('scheduled_at')->label('Scheduled at'),
                $dateTime('completed_at')->label('Completed at'),
                Tables\Columns\ViewColumn::make('progress')->label('Progress')
                    ->view('filament.tables.progress')
                    ->sortable(query: fn (Builder $query, string $direction) => $query->orderBy('answered_items_count', $direction)),
            ])
            ->filters([
                Tables\Filters\Filter::make('search')
                    ->form([
                        Forms\Components\TextInput::make('q')->label('Search')
                            ->placeholder('Search…')
                            ->prefixIcon('heroicon-o-magnifying-glass')
                            ->live(debounce: 400),
                    ])
                    ->query(function (Builder $query, array $data) {
                        $term = trim((string) ($data['q'] ?? ''));
                        if ($term === '') {
                            return $query;
                        }
                        $like = '%'.str_replace(['%', '_'], ['\%', '\_'], $term).'%';

                        return $query->where(fn (Builder $w) => $w
                            ->whereHas('site', fn (Builder $q) => $q->where('name', 'like', $like)->orWhere('address', 'like', $like))
                            ->orWhereHas('customer', fn (Builder $q) => $q->where('name', 'like', $like))
                            ->orWhereHas('template', fn (Builder $q) => $q->where('name', 'like', $like))
                            ->orWhereHas('inspector', fn (Builder $q) => $q->where('name', 'like', $like)));
                    })
                    ->indicateUsing(fn (array $data) => filled($data['q'] ?? null) ? 'Search: '.$data['q'] : null),
                Tables\Filters\SelectFilter::make('site')->relationship('site', 'name')
                    ->label('Site')->placeholder('All Sites')->preload()
                    ->modifyFormFieldUsing(fn (Forms\Components\Select $field) => $field->prefixIcon('heroicon-o-map-pin')),
                Tables\Filters\SelectFilter::make('customer')->relationship('customer', 'name')
                    ->label('Customer')->placeholder('All Customers')->preload()
                    ->modifyFormFieldUsing(fn (Forms\Components\Select $field) => $field->prefixIcon('heroicon-o-users')),
                Tables\Filters\SelectFilter::make('template')->relationship('template', 'name')
                    ->label('Template')->placeholder('All Templates')->preload()
                    ->modifyFormFieldUsing(fn (Forms\Components\Select $field) => $field->prefixIcon('heroicon-o-document-text')),
                Tables\Filters\SelectFilter::make('status')->options($statuses)
                    ->label('Status')->placeholder('All Status')
                    ->modifyFormFieldUsing(fn (Forms\Components\Select $field) => $field->prefixIcon('heroicon-o-signal')),
                Tables\Filters\SelectFilter::make('scheduled')
                    ->label('Scheduled')->placeholder('Any date')
                    ->options([
                        'today' => 'Today',
                        'week' => 'This week',
                        'last7' => 'Last 7 days',
                        'last30' => 'Last 30 days',
                        'month' => 'This month',
                        'upcoming' => 'Upcoming',
                    ])
                    ->query(fn (Builder $query, array $data) => match ($data['value'] ?? null) {
                        'today' => $query->whereBetween('scheduled_at', [now()->startOfDay(), now()->endOfDay()]),
                        'week' => $query->whereBetween('scheduled_at', [now()->startOfWeek(), now()->endOfWeek()]),
                        'last7' => $query->whereBetween('scheduled_at', [now()->subDays(6)->startOfDay(), now()->endOfDay()]),
                        'last30' => $query->whereBetween('scheduled_at', [now()->subDays(29)->startOfDay(), now()->endOfDay()]),
                        'month' => $query->whereBetween('scheduled_at', [now()->startOfMonth(), now()->endOfMonth()]),
                        'upcoming' => $query->where('scheduled_at', '>', now()),
                        default => $query,
                    })
                    ->modifyFormFieldUsing(fn (Forms\Components\Select $field) => $field->prefixIcon('heroicon-o-calendar')),
            ], layout: Tables\Enums\FiltersLayout::AboveContent)
            ->filtersFormColumns(['default' => 2, 'md' => 3, '2xl' => 6])
            ->actions([
                Tables\Actions\ActionGroup::make([
                    Tables\Actions\ViewAction::make(),
                    Tables\Actions\EditAction::make(),
                ])->icon('heroicon-m-ellipsis-horizontal')->tooltip('Actions'),
            ])
            ->paginated([10, 25, 50]);
    }

    public static function getRelations(): array
    {
        return [
            ItemsRelationManager::class,
            FindingsRelationManager::class,
            EvidenceRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListInspections::route('/'),
            'view' => Pages\ViewInspection::route('/{record}'),
            'edit' => Pages\EditInspection::route('/{record}/edit'),
        ];
    }
}
