<?php

namespace App\Filament\Resources\InspectionResource\RelationManagers;

use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ItemsRelationManager extends RelationManager
{
    protected static string $relationship = 'items';

    protected static ?string $title = 'Checklist items';

    protected static ?string $recordTitleAttribute = 'label';

    public function form(Form $form): Form
    {
        return $form->schema([]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('label')
            ->columns([
                Tables\Columns\TextColumn::make('sort_order')->label('#')->sortable(),
                Tables\Columns\TextColumn::make('label')->wrap(),
                Tables\Columns\BadgeColumn::make('result')
                    ->colors([
                        'success' => 'pass',
                        'danger' => 'fail',
                        'gray' => 'na',
                    ])
                    ->placeholder('Pending'),
                Tables\Columns\TextColumn::make('note')->limit(40)->placeholder('—'),
            ])
            ->defaultSort('sort_order');
    }
}
