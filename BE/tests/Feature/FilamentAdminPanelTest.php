<?php

namespace Tests\Feature;

use App\Filament\Pages\Settings;
use App\Filament\Resources\InspectionTemplateResource\Pages\EditInspectionTemplate;
use App\Models\Customer;
use App\Models\Inspection;
use App\Models\InspectionTemplate;
use App\Models\Inspector;
use App\Models\Setting;
use App\Models\Site;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class FilamentAdminPanelTest extends TestCase
{
    use RefreshDatabase;

    public function test_inspector_role_cannot_access_admin_panel(): void
    {
        $inspector = User::factory()->inspector()->create();

        $this->actingAs($inspector)->get('/admin')->assertForbidden();
    }

    public function test_admin_can_load_dashboard_and_resource_pages(): void
    {
        $admin = User::factory()->admin()->create();

        $customer = Customer::factory()->create();
        $site = Site::factory()->create(['customer_id' => $customer->id]);
        $template = InspectionTemplate::factory()->create();
        $inspectorUser = User::factory()->inspector()->create();
        Inspector::factory()->create(['user_id' => $inspectorUser->id]);
        $inspection = Inspection::factory()->create([
            'customer_id' => $customer->id,
            'site_id' => $site->id,
            'template_id' => $template->id,
            'inspector_id' => $inspectorUser->id,
        ]);

        $this->actingAs($admin);

        $this->get('/admin')->assertOk()
            ->assertSee('Total Inspections')
            ->assertSee('Inspection Overview')
            ->assertSee('Inspection Risk Overview')
            ->assertSee('Recent Findings');
        $this->get('/admin/customers')->assertOk();
        $this->get('/admin/sites')->assertOk();
        $this->get('/admin/inspectors')->assertOk();
        $this->get('/admin/inspection-templates')
            ->assertRedirect("/admin/inspection-templates/{$template->id}/edit");
        $this->get('/admin/inspections')->assertOk();
        $this->get("/admin/inspections/{$inspection->id}")->assertOk();
        $this->get("/admin/customers/{$customer->id}/edit")->assertOk();
        $this->get("/admin/sites/{$site->id}/edit")->assertOk();
        $this->get("/admin/inspection-templates/{$template->id}/edit")->assertOk()
            ->assertSee('Inspection Templates')
            ->assertSee('Edit Template')
            ->assertSee($template->name);
        $this->get('/admin/reports')->assertOk();
        $this->get('/admin/settings')->assertOk();
    }

    public function test_sidebar_has_exactly_the_eight_items_in_order(): void
    {
        $this->actingAs(User::factory()->admin()->create());

        $html = $this->get('/admin')->assertOk()->getContent();
        preg_match_all('/<span[^>]*class="[^"]*fi-sidebar-item-label[^"]*"[^>]*>\s*([^<]+?)\s*</', $html, $m);

        $this->assertSame(
            ['Dashboard', 'Inspections', 'Templates', 'Customers', 'Sites', 'Inspectors', 'Reports', 'Settings'],
            $m[1],
        );
    }

    public function test_admin_can_save_settings(): void
    {
        $this->actingAs(User::factory()->admin()->create());

        Livewire::test(Settings::class)
            ->set('data.company_name', 'Acme Inspections')
            ->set('data.default_recurrence', 'monthly')
            ->call('save')
            ->assertHasNoErrors();

        $this->assertSame('Acme Inspections', Setting::valueOf('company_name'));
        $this->assertSame('monthly', Setting::valueOf('default_recurrence'));
        $this->assertSame('Generated with Inspectly.', Setting::valueOf('report_footer'));
    }

    public function test_template_builder_persists_a_new_section(): void
    {
        $this->actingAs(User::factory()->admin()->create());
        $template = InspectionTemplate::factory()->create(['name' => 'Safety Inspection']);

        $page = Livewire::test(EditInspectionTemplate::class, ['record' => $template->getRouteKey()])
            ->set('name', 'Site Safety Inspection')
            ->set('description', 'General safety inspection for buildings and facilities.')
            ->call('addSection')
            ->assertHasNoErrors();

        $section = $template->fresh()->sections()->first();
        $page->assertSet('openSection', $section->id)
            ->call('renameSection', $section->id, 'Fire Safety')
            ->call('addItem', $section->id);

        $item = $section->checklistItems()->first();
        $page->call('updateItem', $item->id, 'label', 'Fire Extinguisher')
            ->call('updateItem', $item->id, 'help_text', 'Is it mounted?')
            ->call('updateItem', $item->id, 'requires_evidence', true)
            ->assertSee('Fire Safety')
            ->assertSee('1 item');

        $template->refresh();
        $this->assertSame('Site Safety Inspection', $template->name);
        $this->assertSame('General safety inspection for buildings and facilities.', $template->description);
        $this->assertSame('Fire Safety', $section->fresh()->title);
        $item->refresh();
        $this->assertSame(['Fire Extinguisher', 'Is it mounted?', true], [$item->label, $item->help_text, (bool) $item->requires_evidence]);

        $page->call('deleteItem', $item->id)->call('deleteSection', $section->id);
        $this->assertSame(0, $template->sections()->count());
    }

    /** Any day: the demo story is anchored to "today" (QC-020). */
    public static function storyDays(): array
    {
        return [
            'mockup day' => ['2026-09-29 12:00'],
            'real today' => [null],
            'new year' => ['2026-12-31 23:00'],
            'mid 2027' => ['2027-06-15 08:00'],
        ];
    }

    /** @dataProvider storyDays */
    public function test_dashboard_reproduces_the_demo_story(?string $day): void
    {
        if ($day !== null) {
            $this->travelTo(\Illuminate\Support\Carbon::parse($day));
        }
        $this->seed(\Database\Seeders\DemoSeeder::class);
        $this->actingAs(User::where('email', 'admin@inspectly.test')->first());

        $dashboard = new \App\Filament\Pages\Dashboard;
        $stats = collect($dashboard->stats())->keyBy('label');
        // QC-026: the 4th KPI is Open Findings (master mockup: 7, -2%).
        $this->assertSame(['Total Inspections', 'Completed', 'In Progress', 'Open Findings'], $stats->keys()->all());
        $this->assertSame([48, 32, 12, 7], $stats->pluck('value')->all());
        $this->assertSame([12, 8, -2], [$stats['Total Inspections']['trend'], $stats['Completed']['trend'], $stats['Open Findings']['trend']]);
        $this->assertSame(0, Inspection::where('status', 'review')->count());
        $this->assertSame(7, $dashboard->openFindingsCount());

        $risk = $dashboard->riskOverview();
        $this->assertSame([72, 7, 3, 2], [$risk['rate'], $risk['pass'], $risk['attention'], $risk['fail']]);
        $this->assertSame(
            ['Damaged Electrical Panel', 'Leaking Pipe', 'Blocked Emergency Exit'],
            $dashboard->recentFindings()->pluck('title')->all(),
        );
        $this->assertSame(
            ['Riverside Office Complex', 'Westlake Apartments', 'Central Warehouse', 'Maple Industrial Park', 'Oakwood Medical Center'],
            $dashboard->recentInspections()->map(fn ($i) => $i->site->name)->all(),
        );
    }

    public function test_inspection_overview_counts_activity_per_bucket(): void
    {
        $this->seed(\Database\Seeders\DemoSeeder::class);
        $stats = new \App\Support\InspectionStats;
        $all = $stats->inspections();

        foreach (array_keys(\App\Support\InspectionStats::PERIODS) as $period) {
            [, $count, $size] = \App\Support\InspectionStats::PERIODS[$period];
            $overview = $stats->overview($period);
            $this->assertCount($count, $overview['labels']);
            $first = today()->subDays($count * $size - 1);
            $in = fn ($at) => $at !== null && $at->copy()->startOfDay()->between($first, today());
            $this->assertSame($all->filter(fn ($i) => $in($i->completed_at))->count(), array_sum($overview['series']['completed']), $period);
            $this->assertSame($all->filter(fn ($i) => $in($i->started_at))->count(), array_sum($overview['series']['started']), $period);
        }
    }

    public function test_admin_can_schedule_an_inspection_with_the_template_checklist(): void
    {
        $this->seed(\Database\Seeders\DemoSeeder::class);
        $this->actingAs(User::where('email', 'admin@inspectly.test')->first());
        $template = InspectionTemplate::where('name', 'Safety Inspection')->firstOrFail();
        $site = Site::where('name', 'Westlake Apartments')->firstOrFail();
        $inspector = User::where('email', 'sarah.johnson@inspectly.test')->firstOrFail();

        Livewire::test(\App\Filament\Resources\InspectionResource\Pages\ListInspections::class)
            ->callAction('create', [
                'template_id' => $template->id,
                'customer_id' => $site->customer_id,
                'site_id' => $site->id,
                'inspector_id' => $inspector->id,
                'scheduled_at' => now()->addDays(3)->setTime(9, 0)->toDateTimeString(),
                'recurrence' => Inspection::RECURRENCE_ONE_TIME,
            ])
            ->assertHasNoActionErrors();

        $created = Inspection::latest('id')->firstOrFail();
        $this->assertSame([Inspection::STATUS_SCHEDULED, $site->id, $inspector->id], [$created->status, $created->site_id, $created->inspector_id]);
        $this->assertSame(12, $created->items()->count());
        $this->assertSame(0, $created->items()->whereNotNull('result')->count());
    }

    public function test_inspections_list_search_and_filters(): void
    {
        $this->seed(\Database\Seeders\DemoSeeder::class);
        $this->actingAs(User::where('email', 'admin@inspectly.test')->first());
        $page = \App\Filament\Resources\InspectionResource\Pages\ListInspections::class;

        $riverside = Inspection::whereHas('site', fn ($q) => $q->where('name', 'Riverside Office Complex'))->get();
        $others = Inspection::whereHas('site', fn ($q) => $q->where('name', '!=', 'Riverside Office Complex'))->limit(3)->get();
        Livewire::test($page)
            ->set('tableFilters.search.q', 'Riverside')
            ->assertCanSeeTableRecords($riverside->take(10))
            ->assertCanNotSeeTableRecords($others);

        $inProgress = Inspection::where('status', Inspection::STATUS_IN_PROGRESS)->get();
        Livewire::test($page)
            ->filterTable('status', Inspection::STATUS_IN_PROGRESS)
            ->assertCanSeeTableRecords($inProgress->take(10))
            ->assertCountTableRecords($inProgress->count());
    }
}
