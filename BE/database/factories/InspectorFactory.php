<?php

namespace Database\Factories;

use App\Models\Inspector;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Inspector>
 */
class InspectorFactory extends Factory
{
    public function definition(): array
    {
        $user = User::factory()->inspector();

        return [
            'user_id' => $user,
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'phone' => fake()->phoneNumber(),
            'avatar_url' => null,
            'status' => 'active',
        ];
    }
}
