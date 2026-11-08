<?php

namespace Database\Factories;

use App\Models\Activity;
use App\Models\Inspection;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<\App\Models\Activity>
 */
class ActivityFactory extends Factory
{
    public function definition(): array
    {
        return [
            'inspection_id' => Inspection::factory(),
            'type' => Activity::TYPE_STARTED,
            'description' => fake()->sentence(),
            'actor_user_id' => null,
            'occurred_at' => now(),
        ];
    }
}
