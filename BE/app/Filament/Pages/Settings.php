<?php

namespace App\Filament\Pages;

use App\Models\Inspection;
use App\Models\Setting;
use Filament\Forms;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Pages\Page;

/**
 * @property Form $form
 */
class Settings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static ?int $navigationSort = 8;

    protected static string $view = 'filament.pages.settings';

    /** @var array<string, mixed> */
    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill(Setting::allWithDefaults());
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Company')
                    ->description('Included in the report payload returned by GET /api/reports/{id}.')
                    ->schema([
                        Forms\Components\TextInput::make('company_name')
                            ->label('Company name')
                            ->required()
                            ->maxLength(120),
                        Forms\Components\Textarea::make('report_footer')
                            ->label('Report footer text')
                            ->rows(2)
                            ->maxLength(500),
                    ]),
                Forms\Components\Section::make('Scheduling')
                    ->schema([
                        Forms\Components\Select::make('default_recurrence')
                            ->label('Default recurrence for new inspections')
                            ->helperText('Applied when an inspection is created through the API without a recurrence.')
                            ->options([
                                Inspection::RECURRENCE_ONE_TIME => 'One time',
                                Inspection::RECURRENCE_WEEKLY => 'Weekly',
                                Inspection::RECURRENCE_MONTHLY => 'Monthly',
                                Inspection::RECURRENCE_QUARTERLY => 'Every 3 months',
                            ])
                            ->required(),
                    ]),
            ])
            ->statePath('data');
    }

    public function save(): void
    {
        foreach ($this->form->getState() as $key => $value) {
            if (array_key_exists($key, Setting::DEFAULTS)) {
                Setting::put($key, $value === null ? null : (string) $value);
            }
        }

        Notification::make()->title('Settings saved')->success()->send();
    }
}
