<?php

namespace App\Filament\Resources;

use App\Filament\Resources\InspectionTemplateResource\Pages;
use App\Models\InspectionTemplate;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class InspectionTemplateResource extends Resource
{
    protected static ?string $model = InspectionTemplate::class;

    protected static ?string $navigationIcon = 'heroicon-o-document-duplicate';

    protected static ?int $navigationSort = 3;

    protected static ?string $navigationLabel = 'Templates';

    /**
     * The "template builder": nested repeaters let an admin add/reorder
     * sections and, within each section, checklist items — backed directly
     * by the sections()/checklistItems() relationships so saves persist the
     * whole tree in one submit.
     */
    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Template Name')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Textarea::make('description')
                    ->columnSpanFull(),
                Forms\Components\Select::make('category')
                    ->options([
                        'safety' => 'Safety',
                        'property' => 'Property',
                        'equipment' => 'Equipment',
                        'vehicle' => 'Vehicle',
                        'custom' => 'Custom',
                    ])
                    ->required(),
                Forms\Components\Toggle::make('is_active')
                    ->default(true),
                Forms\Components\Repeater::make('sections')
                    ->relationship('sections')
                    ->orderColumn('sort_order')
                    ->collapsible()
                    ->itemLabel(fn (array $state): string => ($state['title'] ?? 'New section').'  ·  '.count($state['checklistItems'] ?? []).' items')
                    ->addActionLabel('Add Section')
                    ->collapsed()
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Repeater::make('checklistItems')
                            ->relationship('checklistItems')
                            ->orderColumn('sort_order')
                            ->collapsible()
                            ->itemLabel(fn (array $state): ?string => $state['label'] ?? 'New item')
                            ->addActionLabel('Add Checklist Item')
                            ->schema([
                                Forms\Components\TextInput::make('label')
                                    ->required()
                                    ->maxLength(255),
                                Forms\Components\TextInput::make('help_text')
                                    ->label('Question')
                                    ->maxLength(255),
                                Forms\Components\Toggle::make('requires_evidence')
                                    ->label('Requires evidence photo'),
                            ])
                            ->columns(2)
                            ->defaultItems(0),
                    ])
                    ->columnSpanFull()
                    ->defaultItems(0),
            ])
            ->columns(2);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('category')->badge(),
                Tables\Columns\TextColumn::make('sections_count')->counts('sections')->label('Sections'),
                Tables\Columns\IconColumn::make('is_active')->boolean(),
                Tables\Columns\TextColumn::make('created_at')->dateTime()->sortable()->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('category')->options([
                    'safety' => 'Safety',
                    'property' => 'Property',
                    'equipment' => 'Equipment',
                    'vehicle' => 'Vehicle',
                    'custom' => 'Custom',
                ]),
                Tables\Filters\TernaryFilter::make('is_active'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListInspectionTemplates::route('/'),
            'create' => Pages\CreateInspectionTemplate::route('/create'),
            'edit' => Pages\EditInspectionTemplate::route('/{record}/edit'),
        ];
    }
}
