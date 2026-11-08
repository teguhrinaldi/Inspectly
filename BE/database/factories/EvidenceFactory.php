<?php

namespace Database\Factories;

use App\Models\Inspection;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<\App\Models\Evidence>
 */
class EvidenceFactory extends Factory
{
    public function definition(): array
    {
        return [
            'inspection_id' => Inspection::factory(),
            'inspection_item_id' => null,
            'finding_id' => null,
            'file_path' => 'demo/evidence/'.fake()->uuid().'.jpg',
            'watermarked_path' => null,
            'latitude' => fake()->latitude(),
            'longitude' => fake()->longitude(),
            'captured_at' => now(),
        ];
    }
}
