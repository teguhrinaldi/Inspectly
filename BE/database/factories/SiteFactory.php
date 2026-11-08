<?php

namespace Database\Factories;

use App\Models\Customer;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<\App\Models\Site>
 */
class SiteFactory extends Factory
{
    public function definition(): array
    {
        return [
            'customer_id' => Customer::factory(),
            'name' => fake()->streetName().' Site',
            'address' => fake()->address(),
            'latitude' => fake()->latitude(),
            'longitude' => fake()->longitude(),
            'qr_code' => 'INSPECTLY:SITE:'.Str::upper(Str::random(8)).'-'.fake()->unique()->numberBetween(1, 999),
            'status' => 'active',
            'cover_image_url' => null,
        ];
    }
}
