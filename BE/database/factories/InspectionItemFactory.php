<?php

namespace Database\Factories;

use App\Models\Inspection;
use App\Models\InspectionItem;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<InspectionItem>
 */
class InspectionItemFactory extends Factory
{
    public function definition(): array
    {
        return [
            'inspection_id' => Inspection::factory(),
            'template_checklist_item_id' => null,
            'label' => fake()->sentence(4),
            'result' => null,
            'note' => null,
            'sort_order' => 0,
        ];
    }
}
