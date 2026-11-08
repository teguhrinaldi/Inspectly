<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Inspection;
use App\Models\InspectionTemplate;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/** QC-043: the GPS accuracy (metres) of a photo is stored with the evidence. */
class EvidenceAccuracyTest extends TestCase
{
    use RefreshDatabase;

    public function test_evidence_keeps_the_gps_accuracy(): void
    {
        Storage::fake('public');
        $inspector = User::factory()->inspector()->create();
        $customer = Customer::factory()->create();
        $inspection = Inspection::factory()->create([
            'template_id' => InspectionTemplate::factory()->create()->id,
            'customer_id' => $customer->id,
            'site_id' => Site::factory()->create(['customer_id' => $customer->id])->id,
            'inspector_id' => $inspector->id,
            'status' => Inspection::STATUS_IN_PROGRESS,
        ]);
        Sanctum::actingAs($inspector);

        $this->post('/api/evidence', [
            'file' => UploadedFile::fake()->image('a.jpg'),
            'inspection_id' => $inspection->id,
            'lat' => -6.2,
            'lng' => 106.8,
            'accuracy' => 12.5,
        ], ['Accept' => 'application/json'])
            ->assertCreated()
            ->assertJsonPath('data.accuracy', 12.5);

        $this->post('/api/evidence', [
            'file' => UploadedFile::fake()->image('b.jpg'),
            'inspection_id' => $inspection->id,
            'accuracy' => -3,
        ], ['Accept' => 'application/json'])
            ->assertStatus(422)
            ->assertJsonValidationErrors('accuracy');
    }
}
