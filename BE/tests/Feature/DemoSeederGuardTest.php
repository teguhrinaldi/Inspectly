<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** QC-050: `db:seed` in production must not create the demo admin/password. */
class DemoSeederGuardTest extends TestCase
{
    use RefreshDatabase;

    public function test_demo_data_is_not_seeded_in_production(): void
    {
        $this->app['env'] = 'production';

        $this->artisan('db:seed', ['--class' => DatabaseSeeder::class, '--force' => true]);

        $this->assertSame(0, User::count());
    }

    public function test_demo_data_can_be_forced_for_a_demo_server(): void
    {
        $this->app['env'] = 'production';
        config(['app.allow_demo_seed' => true]);

        $this->artisan('db:seed', ['--class' => DatabaseSeeder::class, '--force' => true]);

        $this->assertTrue(User::where('email', 'admin@inspectly.test')->exists());
    }
}
