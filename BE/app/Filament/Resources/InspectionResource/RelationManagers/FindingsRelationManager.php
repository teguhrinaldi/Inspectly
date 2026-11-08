<?php

namespace App\Filament\Resources\InspectionResource\RelationManagers;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class FindingsRelationManager extends RelationManager
{
    protected static string $relationship = 'findings';

    protected static ?string $recordTitleAttribute = 'title';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('title')->required()->maxLength(255)->columnSpanFull(),
                Textarea::make('description')->columnSpanFull(),
                Select::make('severity')
                    ->options(['critical' => 'Critical', 'high' => 'High', 'medium' => 'Medium', 'low' => 'Low'])
                    ->required(),
                Select::make('status')
                    ->options(['open' => 'Open', 'resolved' => 'Resolved'])
                    ->required(),
                Textarea::make('recommendation')->columnSpanFull(),
            ])
            ->columns(2);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('title')
            ->columns([
                Tables\Columns\TextColumn::make('title')->wrap(),
                Tables\Columns\BadgeColumn::make('severity')
                    ->colors([
                        'danger' => ['critical', 'high'],
                        'warning' => 'medium',
                        'gray' => 'low',
                    ]),
                Tables\Columns\BadgeColumn::make('status')
                    ->colors(['danger' => 'open', 'success' => 'resolved']),
                Tables\Columns\TextColumn::make('recommendation')->limit(50)->placeholder('—'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ]);
    }
}
