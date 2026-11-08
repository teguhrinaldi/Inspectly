<?php

namespace Database\Factories;

use App\Models\TemplateSection;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<\App\Models\TemplateChecklistItem>
 */
class TemplateChecklistItemFactory extends Factory
{
    public function definition(): array
    {
        return [
            'section_id' => TemplateSection::factory(),
            'label' => fake()->sentence(4),
            'help_text' => fake()->optional()->sentence(),
            'requires_evidence' => false, // deterministic; tests opt in explicitly
            'sort_order' => 0,
        ];
    }
}
