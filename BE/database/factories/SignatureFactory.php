<?php

namespace Database\Factories;

use App\Models\Inspection;
use App\Models\Signature;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Signature>
 */
class SignatureFactory extends Factory
{
    public function definition(): array
    {
        return [
            'inspection_id' => Inspection::factory(),
            'type' => Signature::TYPE_INSPECTOR,
            'signer_name' => fake()->name(),
            'file_path' => 'demo/signatures/'.fake()->uuid().'.png',
            'signed_at' => now(),
        ];
    }
}
