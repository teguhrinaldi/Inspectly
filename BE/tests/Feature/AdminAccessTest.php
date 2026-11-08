<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_non_admin_cannot_create_customer(): void
    {
        $inspector = User::factory()->inspector()->create();
        Sanctum::actingAs($inspector);

        $this->postJson('/api/customers', ['name' => 'Some Customer'])
            ->assertStatus(403);
    }

    public function test_non_admin_cannot_create_template(): void
    {
        $inspector = User::factory()->inspector()->create();
        Sanctum::actingAs($inspector);

        $this->postJson('/api/inspection-templates', [
            'name' => 'New Template',
            'category' => 'safety',
        ])->assertStatus(403);
    }

    public function test_non_admin_cannot_create_inspector(): void
    {
        $inspector = User::factory()->inspector()->create();
        Sanctum::actingAs($inspector);

        $this->postJson('/api/inspectors', [
            'name' => 'New Inspector',
            'email' => 'new.inspector@inspectly.test',
        ])->assertStatus(403);
    }

    public function test_admin_can_create_customer(): void
    {
        $admin = User::factory()->admin()->create();
        Sanctum::actingAs($admin);

        $this->postJson('/api/customers', ['name' => 'Some Customer'])
            ->assertCreated()
            ->assertJsonPath('data.name', 'Some Customer');
    }

    public function test_admin_can_create_template_with_sections(): void
    {
        $admin = User::factory()->admin()->create();
        Sanctum::actingAs($admin);

        $response = $this->postJson('/api/inspection-templates', [
            'name' => 'New Template',
            'category' => 'safety',
            'sections' => [
                [
                    'title' => 'Section 1',
                    'items' => [
                        ['label' => 'Check 1'],
                        ['label' => 'Check 2'],
                    ],
                ],
            ],
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.name', 'New Template')
            ->assertJsonCount(1, 'data.sections')
            ->assertJsonCount(2, 'data.sections.0.items');
    }
}
