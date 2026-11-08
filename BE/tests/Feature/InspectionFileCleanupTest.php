<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Evidence;
use App\Models\Inspection;
use App\Models\InspectionTemplate;
use App\Models\Signature;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class InspectionFileCleanupTest extends TestCase
{
    use RefreshDatabase;

    /** QC-054: deleting an inspection also deletes its uploaded files. */
    public function test_deleting_an_inspection_removes_its_files(): void
    {
        Storage::fake('public');
        $customer = Customer::factory()->create();
        $inspection = Inspection::factory()->create([
            'template_id' => InspectionTemplate::factory()->create()->id,
            'customer_id' => $customer->id,
            'site_id' => Site::factory()->create(['customer_id' => $customer->id])->id,
            'inspector_id' => User::factory()->inspector()->create()->id,
        ]);
        Storage::disk('public')->put('evidence/1/a.jpg', 'x');
        Storage::disk('public')->put('signatures/1/s.png', 'x');
        Evidence::create(['inspection_id' => $inspection->id, 'file_path' => 'evidence/1/a.jpg', 'captured_at' => now()]);
        Signature::create(['inspection_id' => $inspection->id, 'type' => 'customer', 'signer_name' => 'A', 'file_path' => 'signatures/1/s.png', 'signed_at' => now()]);

        $inspection->delete();

        Storage::disk('public')->assertMissing('evidence/1/a.jpg');
        Storage::disk('public')->assertMissing('signatures/1/s.png');
    }
}
