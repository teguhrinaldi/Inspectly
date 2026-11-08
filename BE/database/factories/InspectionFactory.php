<?php

namespace Database\Factories;

use App\Models\Customer;
use App\Models\Inspection;
use App\Models\InspectionTemplate;
use App\Models\Site;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Inspection>
 */
class InspectionFactory extends Factory
{
    public function definition(): array
    {
        return [
            'template_id' => InspectionTemplate::factory(),
            'customer_id' => Customer::factory(),
            'site_id' => Site::factory(),
            'inspector_id' => User::factory()->inspector(),
            'status' => Inspection::STATUS_SCHEDULED,
            'scheduled_at' => now()->addDays(fake()->numberBetween(1, 14)),
            'started_at' => null,
            'completed_at' => null,
            'recurrence' => Inspection::RECURRENCE_ONE_TIME,
            'next_due_at' => null,
            'location_lat' => null,
            'location_lng' => null,
            'location_captured_at' => null,
            'pass_percentage' => null,
        ];
    }

    public function draft(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Inspection::STATUS_DRAFT,
            'scheduled_at' => null,
        ]);
    }

    public function inProgress(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Inspection::STATUS_IN_PROGRESS,
            'started_at' => now(),
        ]);
    }

    public function completed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Inspection::STATUS_COMPLETED,
            'started_at' => now()->subHour(),
            'completed_at' => now(),
            'pass_percentage' => fake()->numberBetween(60, 100),
        ]);
    }
}
