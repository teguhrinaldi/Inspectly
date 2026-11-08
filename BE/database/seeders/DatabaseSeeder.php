<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // The demo story includes admin@inspectly.test / "password". Never
        // seed it into production unless explicitly asked for (a public demo
        // server): set ALLOW_DEMO_SEED=true in that environment's .env.
        if (app()->isProduction() && ! config('app.allow_demo_seed')) {
            $this->command?->warn('Skipping demo data in production (set ALLOW_DEMO_SEED=true to seed it anyway).');

            return;
        }

        $this->call(DemoSeeder::class);
    }
}
