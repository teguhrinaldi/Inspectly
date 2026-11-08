<?php

namespace Database\Factories;

use App\Models\InspectionTemplate;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<\App\Models\TemplateSection>
 */
class TemplateSectionFactory extends Factory
{
    public function definition(): array
    {
        return [
            'template_id' => InspectionTemplate::factory(),
            'title' => fake()->words(2, true),
            'sort_order' => 0,
        ];
    }
}
