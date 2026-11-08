<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    public const DEFAULTS = [
        'company_name' => 'Inspectly',
        'report_footer' => 'Generated with Inspectly.',
        'default_recurrence' => Inspection::RECURRENCE_ONE_TIME,
    ];

    protected $fillable = ['key', 'value'];

    public static function valueOf(string $key): ?string
    {
        return static::query()->where('key', $key)->value('value') ?? (self::DEFAULTS[$key] ?? null);
    }

    /**
     * @return array<string, ?string>
     */
    public static function allWithDefaults(): array
    {
        return array_merge(self::DEFAULTS, static::query()->pluck('value', 'key')->all());
    }

    public static function put(string $key, ?string $value): void
    {
        static::query()->updateOrCreate(['key' => $key], ['value' => $value]);
    }
}
