<?php

namespace App\Filament\Resources\InspectionResource\RelationManagers;

use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class EvidenceRelationManager extends RelationManager
{
    protected static string $relationship = 'evidence';

    protected static ?string $recordTitleAttribute = 'file_path';

    public function form(Form $form): Form
    {
        return $form->schema([]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('file_path')
            ->columns([
                Tables\Columns\TextColumn::make('file_path')->label('File')->wrap(),
                Tables\Columns\TextColumn::make('finding.title')->label('Linked finding')->placeholder('—'),
                Tables\Columns\TextColumn::make('inspectionItem.label')->label('Linked item')->placeholder('—'),
                Tables\Columns\TextColumn::make('captured_at')->dateTime(),
            ]);
    }
}
