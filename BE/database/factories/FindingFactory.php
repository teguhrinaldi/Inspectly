<?php

namespace Database\Factories;

use App\Models\Finding;
use App\Models\Inspection;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<\App\Models\Finding>
 */
class FindingFactory extends Factory
{
    public function definition(): array
    {
        return [
            'inspection_id' => Inspection::factory(),
            'inspection_item_id' => null,
            'title' => fake()->sentence(4),
            'description' => fake()->paragraph(),
            'severity' => fake()->randomElement(['critical', 'high', 'medium', 'low']),
            'recommendation' => fake()->sentence(),
            'status' => Finding::STATUS_OPEN,
        ];
    }
}
