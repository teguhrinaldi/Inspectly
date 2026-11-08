<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<\App\Models\InspectionTemplate>
 */
class InspectionTemplateFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => fake()->words(3, true).' Inspection',
            'description' => fake()->sentence(),
            'category' => fake()->randomElement(['safety', 'property', 'equipment', 'vehicle', 'custom']),
            'is_active' => true,
        ];
    }
}
