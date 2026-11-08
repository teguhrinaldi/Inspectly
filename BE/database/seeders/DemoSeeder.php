<?php

namespace Database\Seeders;

use App\Models\Activity;
use App\Models\Customer;
use App\Models\Evidence;
use App\Models\Finding;
use App\Models\Inspection;
use App\Models\InspectionItem;
use App\Models\InspectionTemplate;
use App\Models\Inspector;
use App\Models\Signature;
use App\Models\Site;
use App\Models\TemplateChecklistItem;
use App\Models\TemplateSection;
use App\Models\User;
use App\Support\TrendWindow;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Hash;

/**
 * The demo story from docs/demo-data.md, mirrored 1:1 by the Flutter app's
 * demo data (app/lib/data/datasources/demo). Image paths point at photos
 * bundled with the mobile app (assets/...), which it renders directly.
 */
class DemoSeeder extends Seeder
{
    private const EV = 'assets/images/evidence/';

    public function run(): void
    {
        $day = fn (int $offset, int $h, int $m) => Carbon::today()->addDays($offset)->setTime($h, $m);
        // The story was written for "today" = Sep 29, 2026 (the mockup day).
        // Every fixed day keeps its distance to today (Sep 27 = 2 days ago,
        // Dec 27 = in 89 days ...), so the dashboard numbers are the mockup's
        // on any date the demo is seeded (QC-020).
        $storyToday = Carbon::create(2026, 9, 29);
        $story = fn (int $year, int $month, int $d, int $h, int $m) => Carbon::today()
            ->addDays((int) $storyToday->diffInDays(Carbon::create($year, $month, $d), false))
            ->setTime($h, $m);
        $hist = fn (int $month, int $d, int $h, int $m) => $story(2026, $month, $d, $h, $m);

        // Users / inspectors ------------------------------------------------
        User::create([
            'name' => 'Admin',
            'email' => 'admin@inspectly.test',
            'password' => Hash::make('password'),
            'role' => User::ROLE_ADMIN,
            'avatar_url' => 'assets/images/avatars/admin.jpg',
            'status' => 'active',
            'email_verified_at' => now(),
        ]);
        $michael = $this->createInspector('Michael Carter', 'michael.carter@inspectly.test', '+1 (415) 555-0148', 'michael_carter');
        $sarah = $this->createInspector('Sarah Johnson', 'sarah.johnson@inspectly.test', null, 'sarah_johnson');
        $daniel = $this->createInspector('Daniel Brooks', 'daniel.brooks@inspectly.test', null, 'daniel_brooks');

        // Customers ------------------------------------------------------------
        $northbridge = $this->customer('Northbridge Facilities', 'Rachel Kim', 'rachel.kim@northbridgefacilities.com', '+1 (212) 555-0110');
        $westlakeHoldings = $this->customer('Westlake Holdings', 'Marcus Webb', 'marcus.webb@westlakeholdings.com', '+1 (312) 555-0166');
        $centralGroup = $this->customer('Central Warehouse Group', 'Priya Anand', 'priya.anand@centralwarehousegroup.com', '+1 (773) 555-0121');
        $oakwoodHealth = $this->customer('Oakwood Health Partners', 'Elena Brooks', 'elena.brooks@oakwoodhealthpartners.com', '+1 (617) 555-0192');

        // Sites ------------------------------------------------------------
        $riverside = $this->site($northbridge, 'Riverside Office Complex', '480 Riverside Dr, New York, NY', 40.7712, -73.9542, 'RIVERSIDE-001', 'riverside_office_complex');
        $westlake = $this->site($westlakeHoldings, 'Westlake Apartments', '1220 Westlake Ave, Chicago, IL', 41.8859, -87.6295, 'WESTLAKE-001', 'westlake_apartments');
        $central = $this->site($centralGroup, 'Central Warehouse', '900 Distribution Pkwy, Chicago, IL', 41.8656, -87.6771, 'CENTRALWH-001', 'central_warehouse');
        $maple = $this->site($northbridge, 'Maple Industrial Park', '55 Maple Industrial Rd, Newark, NJ', 40.7357, -74.1724, 'MAPLE-001', 'maple_industrial_park');
        $oakwood = $this->site($oakwoodHealth, 'Oakwood Medical Center', '1500 Oakwood Blvd, Boston, MA', 42.3389, -71.1066, 'OAKWOOD-001', 'oakwood_medical_center');

        // Templates ------------------------------------------------------------
        $safety = $this->createTemplate('Safety Inspection', 'safety', 'General safety inspection for buildings and facilities.', [
            'Fire Safety' => [
                ['Fire Extinguisher', 'Is the extinguisher accessible and properly mounted?', true],
                ['Emergency Exits', 'Are emergency exits unobstructed and clearly signed?', true],
                ['Smoke Detectors', 'Do smoke detectors respond to the test button?', false],
                ['Emergency Lighting', 'Does emergency lighting hold steady when tested?', false],
            ],
            'Electrical Safety' => [
                ['Electrical Panel', 'Is the panel secured, labeled and free of damage?', true],
                ['Wiring', 'Is all wiring enclosed with no exposed conductors?', false],
                ['GFCI Outlets', 'Do GFCI outlets trip and reset correctly?', false],
            ],
            'General Condition' => [
                ['Plumbing', 'Are pipes and fixtures free of leaks?', true],
                ['Walls & Ceilings', 'Are walls and ceilings free of water stains or damage?', false],
                ['Roof & Drainage', 'Is the roof free of damage and are drains clear?', true],
                ['Walkways', 'Are walkways dry and free of trip hazards?', false],
                ['Safety Signage', 'Is required safety signage posted and legible?', false],
            ],
        ]);
        $property = $this->createTemplate('Property Inspection', 'property', 'General condition of the property, exterior and interior.', [
            'Exterior' => [
                ['Roof', 'Is the roof covering intact with no missing sections?', false],
                ['Facade', 'Is the facade free of cracks and loose cladding?', false],
                ['Parking Lot', 'Is the parking surface free of potholes and hazards?', false],
                ['Signage', 'Is exterior signage intact and legible?', true],
            ],
            'Interior' => [
                ['Flooring', 'Is flooring secure with no trip hazards?', false],
                ['Walls & Ceilings', 'Are walls and ceilings free of damage or stains?', false],
                ['Doors & Locks', 'Do doors close and lock correctly?', false],
            ],
            'Building Services' => [
                ['HVAC Filters', 'Are HVAC filters clean and within service date?', false],
                ['Water Heater', 'Is the water heater free of leaks and corrosion?', false],
                ['Common Area Lighting', 'Are all common area lights working?', false],
            ],
        ]);
        $equipment = $this->createTemplate('Equipment Inspection', 'equipment', 'HVAC, backup power and lifting equipment check.', [
            'HVAC' => [
                ['HVAC Unit', 'Is the unit operating normally?', false],
                ['Filters', 'Are filters within their service life?', false],
                ['Noise & Vibration', 'Is the unit free of unusual noise or vibration?', false],
            ],
            'Electrical Systems' => [
                ['Backup Generator', 'Does the backup generator start and hold load?', true],
                ['Panel Breakers', 'Are panel breakers labeled and undamaged?', false],
                ['UPS Battery', 'Is the UPS battery within its test date?', false],
            ],
            'Lifting Equipment' => [
                ['Forklift', 'Has the forklift passed its pre-use check?', true],
                ['Dock Leveler', 'Does the dock leveler raise and lower smoothly?', false],
            ],
        ]);
        $this->createTemplate('Vehicle Inspection', 'vehicle', 'Fleet vehicle exterior, tires and safety equipment check.', [
            'Exterior & Tires' => [
                ['Tire Tread', 'Is tire tread depth above the legal minimum?', false],
                ['Body Damage', 'Is the body free of new damage?', true],
                ['Lights', 'Are all exterior lights functional?', false],
            ],
            'Interior & Safety' => [
                ['Seatbelts', 'Do all seatbelts latch and retract?', false],
                ['First Aid Kit', 'Is a stocked first aid kit on board?', false],
                ['Fire Extinguisher', 'Is a charged extinguisher on board?', false],
            ],
            'Mechanical' => [
                ['Brakes', 'Do brakes respond without noise or pulling?', false],
                ['Fluid Levels', 'Are oil, coolant and washer fluid at level?', false],
                ['Horn & Wipers', 'Do the horn and wipers work?', false],
            ],
        ]);

        $pass = InspectionItem::RESULT_PASS;
        $fail = InspectionItem::RESULT_FAIL;

        // Riverside — Equipment — Jul 3, all pass -----------------------------
        $jul = $hist(7, 3, 10, 15);
        $jul03 = $this->inspection($equipment, $riverside, $daniel, Inspection::STATUS_COMPLETED, [
            'scheduled_at' => $hist(7, 3, 9, 30), 'started_at' => $hist(7, 3, 9, 35), 'completed_at' => $jul,
        ]);
        $this->answer($jul03, [], $pass);
        $this->sign($jul03, 'Daniel Brooks', $jul);
        $this->finish($jul03, $daniel);

        // Riverside — Safety — Aug 12 ------------------------------------------
        $aug = $hist(8, 12, 11, 20);
        $aug12 = $this->inspection($safety, $riverside, $michael, Inspection::STATUS_COMPLETED, [
            'scheduled_at' => $hist(8, 12, 10, 30), 'started_at' => $hist(8, 12, 10, 30), 'completed_at' => $aug,
            'recurrence' => Inspection::RECURRENCE_QUARTERLY,
        ]);
        $augItems = $this->answer($aug12, [
            'Emergency Lighting' => [$fail, 'Emergency light flickers in stairwell B.'],
            'Electrical Panel' => [$fail, 'Level 2 panel cover dented and missing a screw.'],
        ], $pass);
        $this->finding($aug12, $augItems['Electrical Panel'], 'Damaged Electrical Panel', 'high', 'Building A · Floor 2',
            'Level 2 electrical panel cover is dented and missing a retaining screw.',
            'Replace panel cover and re-label circuits within 14 days.', ['electrical_panel_damage.jpg'], $aug);
        $this->finding($aug12, $augItems['Emergency Lighting'], 'Flickering Emergency Light', 'medium', 'Building A · Stairwell B',
            'Emergency lighting in stairwell B flickers during the test.',
            'Replace the ballast/fixture in stairwell B and retest.', [], $aug);
        $this->sign($aug12, 'Michael Carter', $aug);
        $this->finish($aug12, $michael);

        // Riverside — Safety — Sep 27: 7 pass · 3 needs attention · 2 failed;
        // findings 1 critical · 3 high · 2 medium · 1 low → compliance 72%.
        $sepStart = $hist(9, 27, 9, 0);
        $sep = $hist(9, 27, 10, 5);
        $sep27 = $this->inspection($safety, $riverside, $michael, Inspection::STATUS_COMPLETED, [
            'scheduled_at' => $sepStart, 'started_at' => $sepStart, 'completed_at' => $sep,
            'recurrence' => Inspection::RECURRENCE_QUARTERLY,
            'next_due_at' => $story(2026, 12, 27, 9, 0),
            'location_lat' => $riverside->latitude, 'location_lng' => $riverside->longitude, 'location_captured_at' => $sepStart,
        ]);
        $sepItems = $this->answer($sep27, [
            'Electrical Panel' => [$fail, 'Still not repaired since the last visit.'],
            'Emergency Exits' => [$fail, 'Floor 3 east exit blocked; exit sign out.'],
            'Plumbing' => [$fail, 'Active drip at the Building B riser joint.'],
            'Walls & Ceilings' => [$fail, 'Stained tiles below the riser.'],
            'Roof & Drainage' => [$fail, 'Missing shingles on the Building C roof edge.'],
        ], $pass);
        $this->finding($sep27, $sepItems['Electrical Panel'], 'Damaged Electrical Panel', 'high', 'Building A · Floor 2',
            'Level 2 panel cover remains dented and loosely secured — not repaired since the previous inspection.',
            'Escalate: replace the panel cover and re-label circuits.', ['electrical_panel_current.jpg', 'electrical_room.jpg'], $sepStart);
        $this->finding($sep27, $sepItems['Plumbing'], 'Leaking Pipe', 'medium', 'Building B · Floor 1',
            'Active drip at the riser joint in the Building B plant room.',
            'Replace the joint seal and check for corrosion.', ['leaking_pipe.jpg', 'leaking_pipe_2.jpg', 'leaking_pipe_3.jpg'], $sepStart);
        $this->finding($sep27, $sepItems['Emergency Exits'], 'Blocked Emergency Exit', 'high', 'Building A · Floor 3',
            'Stored pallets obstruct the Floor 3 east emergency exit door.',
            'Clear the exit route and mark a no-storage zone.', ['blocked_exit.jpg'], $sepStart);
        $this->finding($sep27, $sepItems['Roof & Drainage'], 'Roof Damage', 'low', 'Building C · Roof',
            'Several shingles are missing along the roof edge.',
            'Schedule shingle replacement before winter.', ['roof_damage.jpg', 'roof_damage_2.jpg'], $sepStart);
        $this->finding($sep27, $sepItems['Electrical Panel'], 'Exposed Live Wiring', 'critical', 'Building A · Floor 2',
            'Live conductors are exposed below the damaged panel enclosure.',
            'Isolate the circuit immediately and terminate the conductors.', ['exposed_wiring.jpg'], $sepStart);
        $this->finding($sep27, $sepItems['Emergency Exits'], 'Exit Sign Not Illuminated', 'high', 'Building A · Floor 3',
            'The illuminated exit sign above the Floor 3 east exit is out.',
            'Replace the lamp and battery pack.', ['exit_sign.jpg'], $sepStart);
        $this->finding($sep27, $sepItems['Walls & Ceilings'], 'Water-Stained Ceiling', 'medium', 'Building B · Floor 1',
            'Ceiling tiles below the leaking riser show water staining.',
            'Replace stained tiles once the leak is repaired.', ['water_stained_ceiling.jpg'], $sepStart);
        $this->sign($sep27, 'Michael Carter', $sep);
        $this->finish($sep27, $michael, true);

        // Riverside — Safety follow-up — IN PROGRESS today 09:30: 7 / 12
        // answered, 3 findings, 14 photos.
        $fuStart = $day(0, 9, 30);
        $followUp = $this->inspection($safety, $riverside, $michael, Inspection::STATUS_IN_PROGRESS, [
            'scheduled_at' => $fuStart, 'started_at' => $fuStart,
            'location_lat' => $riverside->latitude, 'location_lng' => $riverside->longitude, 'location_captured_at' => $fuStart,
        ]);
        $fu = $this->answer($followUp, [
            'Fire Extinguisher' => [$pass, null],
            'Emergency Exits' => [$fail, 'Pallets back in front of the exit.'],
            'Smoke Detectors' => [$pass, null],
            'Emergency Lighting' => [$pass, null],
            'Electrical Panel' => [$fail, 'Cover still not replaced.'],
            'Wiring' => [$pass, null],
            'Walls & Ceilings' => [$fail, 'New staining next to the riser.'],
        ], null);
        $this->itemPhotos($followUp, $fu['Fire Extinguisher'], ['fire_extinguisher_expired.jpg', 'electrical_room.jpg'], $fuStart);
        $this->itemPhotos($followUp, $fu['Emergency Exits'], ['exit_sign.jpg'], $fuStart);
        $this->itemPhotos($followUp, $fu['Smoke Detectors'], ['smoke_detector.jpg'], $fuStart);
        $this->itemPhotos($followUp, $fu['Emergency Lighting'], ['exit_sign.jpg'], $fuStart);
        $this->itemPhotos($followUp, $fu['Electrical Panel'], ['electrical_panel_damage.jpg', 'exposed_wiring.jpg'], $fuStart);
        $this->itemPhotos($followUp, $fu['Wiring'], ['electrical_room.jpg'], $fuStart);
        $this->itemPhotos($followUp, $fu['Walls & Ceilings'], ['water_stained_ceiling.jpg', 'leaking_pipe_3.jpg'], $fuStart);
        $this->finding($followUp, $fu['Walls & Ceilings'], 'Water-Stained Ceiling', 'medium', 'Building B · Floor 1',
            'Fresh staining next to the riser — the leak has not been fixed.',
            'Chase the plumbing repair before replacing tiles.', ['water_stained_ceiling.jpg'], $fuStart);
        $this->finding($followUp, $fu['Emergency Exits'], 'Blocked Emergency Exit', 'high', 'Building A · Floor 3',
            'Pallets are stored in front of the Floor 3 east exit again.',
            'Remove the pallets today and brief the warehouse team.', ['blocked_exit.jpg'], $fuStart);
        $this->finding($followUp, $fu['Electrical Panel'], 'Damaged Electrical Panel', 'high', 'Building A · Floor 2',
            'Level 2 panel cover still dented; temporary tape applied by facilities.',
            'Replace the panel cover this week.', ['electrical_panel_current.jpg', 'exposed_wiring.jpg'], $fuStart);
        $this->logActivity($followUp, Activity::TYPE_STARTED, 'Inspection started.', $michael, $fuStart);

        // Site records just before Sep 27 ------------------------------------
        $wlDone = $hist(9, 26, 14, 10);
        $westlakeLast = $this->inspection($property, $westlake, $daniel, Inspection::STATUS_COMPLETED, [
            'scheduled_at' => $hist(9, 26, 13, 0), 'started_at' => $hist(9, 26, 13, 0), 'completed_at' => $wlDone,
            'recurrence' => Inspection::RECURRENCE_MONTHLY,
        ]);
        $wl = $this->answer($westlakeLast, [
            'Doors & Locks' => [$fail, 'Stairwell handrail loose.'],
            'Water Heater' => [$fail, 'Drip under the heater inlet.'],
        ], $pass);
        $this->finding($westlakeLast, $wl['Doors & Locks'], 'Loose Stair Handrail', 'low', 'Block 2 · Stairwell',
            'The stairwell handrail moves when leaned on.', 'Re-anchor the handrail brackets.', [], $hist(9, 26, 13, 0));
        $this->finding($westlakeLast, $wl['Water Heater'], 'Leaking Pipe', 'medium', 'Block 1 · Plant Room',
            'The water heater inlet pipe drips at the fitting.',
            'Replace the fitting and check the pressure valve.', ['leaking_pipe_2.jpg'], $hist(9, 26, 13, 0));
        $this->sign($westlakeLast, 'Daniel Brooks', $wlDone);
        $this->finish($westlakeLast, $daniel);

        $mapleDone = $hist(9, 25, 16, 0);
        $mapleInspection = $this->inspection($safety, $maple, $daniel, Inspection::STATUS_COMPLETED, [
            'scheduled_at' => $day(1, 10, 30), 'started_at' => $hist(9, 25, 15, 0), 'completed_at' => $mapleDone,
            'recurrence' => Inspection::RECURRENCE_QUARTERLY,
        ]);
        $mp = $this->answer($mapleInspection, ['Emergency Exits' => [$fail, 'Loading bay exit blocked.']], $pass);
        $this->finding($mapleInspection, $mp['Emergency Exits'], 'Blocked Emergency Exit', 'high', 'Unit 4 · Loading Bay',
            'A forklift is parked across the loading-bay emergency exit.',
            'Mark a no-parking zone in front of the exit.', ['blocked_exit.jpg'], $hist(9, 25, 15, 0));
        $this->sign($mapleInspection, 'Daniel Brooks', $mapleDone);
        $this->finish($mapleInspection, $daniel);

        $centralReview = $this->inspection($equipment, $central, $michael, Inspection::STATUS_IN_PROGRESS, [
            'scheduled_at' => $day(1, 9, 0), 'started_at' => $hist(9, 24, 7, 0), 'recurrence' => Inspection::RECURRENCE_MONTHLY,
        ]);
        $cr = $this->answer($centralReview, ['Forklift' => [$fail, 'Forklift horn inoperative.']], $pass);
        $this->finding($centralReview, $cr['Forklift'], 'Forklift Horn Inoperative', 'medium', 'Loading Dock 2',
            'The warning horn on forklift FL-02 does not sound.', 'Tag out FL-02 until the horn is repaired.', [], $hist(9, 24, 7, 0));

        // With "review" gone (QC-026) the Central Warehouse visit above counts
        // as in progress, so the planner adds one filler less; this upcoming
        // visit keeps the story at the mockup's 48 inspections.
        $this->inspection($safety, $westlake, $sarah, Inspection::STATUS_SCHEDULED, [
            'scheduled_at' => $story(2027, 2, 10, 10, 0), 'recurrence' => Inspection::RECURRENCE_QUARTERLY,
        ]);

        // Upcoming / open work (Michael) --------------------------------------
        $this->inspection($property, $westlake, $michael, Inspection::STATUS_SCHEDULED, [
            'scheduled_at' => $day(0, 14, 0), 'recurrence' => Inspection::RECURRENCE_MONTHLY,
        ]);
        $this->inspection($property, $oakwood, $michael, Inspection::STATUS_SCHEDULED, [
            'scheduled_at' => $story(2026, 12, 5, 8, 0), 'recurrence' => Inspection::RECURRENCE_QUARTERLY,
        ]);
        $this->inspection($safety, $central, $michael, Inspection::STATUS_SCHEDULED, [
            'scheduled_at' => $story(2027, 1, 14, 9, 0), 'recurrence' => Inspection::RECURRENCE_QUARTERLY,
        ]);
        $oakIp = $this->inspection($property, $oakwood, $michael, Inspection::STATUS_IN_PROGRESS, [
            'scheduled_at' => $day(-1, 8, 0), 'started_at' => $day(-1, 8, 10),
        ]);
        $this->answer($oakIp, [
            'Roof' => [$pass, null], 'Facade' => [$pass, null], 'Parking Lot' => [$pass, null], 'Signage' => [$pass, null],
        ], null);

        // Earlier routine inspections at the other sites ----------------------
        $this->seedFillers(
            Carbon::today(),
            $hist(9, 23, 17, 0),
            [[$westlake, $property], [$central, $equipment], [$maple, $safety], [$oakwood, $property]],
            [$sarah, $daniel, $michael],
            [$sarah, $daniel],
        );
    }

    /**
     * Mockup targets for the admin dashboard, reproduced by real counting:
     * 48 inspections (12 in progress, 32 completed); last 30 days vs the 30
     * before — scheduled 19 vs 17 (+12%), completed 14 vs 13 (+8%),
     * findings raised 40 vs 41 (−2%). Mirrors planFillers() in the app.
     */
    private const TARGETS = [
        'completed' => 32, 'in_progress' => 12,
        'scheduled_last' => 19, 'scheduled_prev' => 17,
        'completed_last' => 14, 'completed_prev' => 13,
        'findings_last' => 40, 'findings_prev' => 41,
    ];

    private const FILLER_ISSUES = [
        ['Worn Floor Marking', 'low'],
        ['Missing Inspection Tag', 'medium'],
        ['Loose Cable Tray', 'medium'],
        ['Obstructed Walkway', 'high'],
        ['Faded Safety Sign', 'low'],
        ['Dripping Valve', 'medium'],
    ];

    /**
     * @param  array<int, array{0: Site, 1: InspectionTemplate}>  $sites
     * @param  array<int, User>  $completers
     * @param  array<int, User>  $starters
     */
    private function seedFillers(Carbon $today, Carbon $latestAllowed, array $sites, array $completers, array $starters): void
    {
        $anchors = Inspection::withCount('findings')->get();
        $count = fn (callable $only, string $w, string $column) => $anchors
            ->filter(fn (Inspection $i) => $only($i) && TrendWindow::of($i->{$column}, $today) === $w)->count();
        $findingsIn = fn (string $w) => $anchors
            ->filter(fn (Inspection $i) => TrendWindow::of(TrendWindow::activityDate($i), $today) === $w)
            ->sum('findings_count');
        $completed = fn (Inspection $i) => $i->status === Inspection::STATUS_COMPLETED;
        $nonDraft = fn (Inspection $i) => $i->status !== Inspection::STATUS_DRAFT;
        $t = self::TARGETS;

        $compLast = max(0, $t['completed_last'] - $count($completed, TrendWindow::LAST, 'completed_at'));
        $compPrev = max(0, $t['completed_prev'] - $count($completed, TrendWindow::PREV, 'completed_at'));
        $compOld = max(0, $t['completed'] - $anchors->filter($completed)->count() - $compLast - $compPrev);
        $ipTotal = max(0, $t['in_progress'] - $anchors->where('status', Inspection::STATUS_IN_PROGRESS)->count());
        $ipLast = min($ipTotal, max(0, $t['scheduled_last'] - $count($nonDraft, TrendWindow::LAST, 'scheduled_at') - $compLast));
        $ipPrev = min($ipTotal - $ipLast, max(0, $t['scheduled_prev'] - $count($nonDraft, TrendWindow::PREV, 'scheduled_at') - $compPrev));
        $ipOld = $ipTotal - $ipLast - $ipPrev;

        $spread = function (int $total, int $slots): array {
            $out = [];
            for ($k = 0; $k < $slots; $k++) {
                $out[] = intdiv($total, $slots) + ($k < $total % $slots ? 1 : 0);
            }

            return $out;
        };
        $slots = [];
        $window = function (int $comp, int $ip, array $findings, int $youngest, int $oldest) use (&$slots, $today) {
            $total = $comp + $ip;
            for ($k = 0; $k < $total; $k++) {
                $age = $total === 1 ? $youngest : $youngest + intdiv(($oldest - $youngest) * $k, $total - 1);
                $slots[] = [
                    $k < $comp ? Inspection::STATUS_COMPLETED : Inspection::STATUS_IN_PROGRESS,
                    $today->copy()->subDays($age)->setTime(9 + $k % 6, 0),
                    $findings[$k] ?? 0,
                ];
            }
        };
        $youngestLast = min(29, max(0, (int) $latestAllowed->copy()->startOfDay()->diffInDays($today, false)));
        $window($compLast, $ipLast, $spread(max(0, $t['findings_last'] - $findingsIn(TrendWindow::LAST)), $compLast + $ipLast), $youngestLast, 29);
        $window($compPrev, $ipPrev, $spread(max(0, $t['findings_prev'] - $findingsIn(TrendWindow::PREV)), $compPrev + $ipPrev), 30, 59);
        $window($compOld, $ipOld, [], 62, 120);

        foreach ($slots as $n => [$status, $at, $findings]) {
            [$site, $template] = $sites[$n % count($sites)];
            $done = $status === Inspection::STATUS_COMPLETED;
            $inspector = $done ? $completers[$n % count($completers)] : $starters[$n % count($starters)];
            $end = $at->copy()->addMinutes(70);
            $inspection = $this->inspection($template, $site, $inspector, $status, [
                'scheduled_at' => $at, 'started_at' => $at, 'completed_at' => $done ? $end : null,
            ]);
            $items = $inspection->items()->orderBy('sort_order')->get()->values();
            foreach ($items as $k => $item) {
                $result = match (true) {
                    $k < $findings => InspectionItem::RESULT_FAIL,
                    $done, $k < $findings + 2 => InspectionItem::RESULT_PASS,
                    default => null,
                };
                $item->update(['result' => $result]);
            }
            for ($k = 0; $k < $findings; $k++) {
                [$title, $severity] = self::FILLER_ISSUES[($n + $k) % count(self::FILLER_ISSUES)];
                Finding::create([
                    'inspection_id' => $inspection->id,
                    'inspection_item_id' => $items[$k]->id,
                    'title' => $title,
                    'description' => 'Recorded during a routine inspection.',
                    'severity' => $severity,
                    'recommendation' => 'Repair and verify at the next visit.',
                    'location' => 'Main building',
                    'status' => Finding::STATUS_RESOLVED,
                ]);
            }
            if ($done) {
                $this->sign($inspection, $inspector->name, $end);
                $inspection->update(['pass_percentage' => $inspection->fresh('items')->computePassPercentage()]);
            }
        }
    }

    private function createInspector(string $name, string $email, ?string $phone, string $avatar): User
    {
        $avatarUrl = "assets/images/avatars/{$avatar}.jpg";
        $user = User::create([
            'name' => $name,
            'email' => $email,
            'password' => Hash::make('password'),
            'role' => User::ROLE_INSPECTOR,
            'phone' => $phone,
            'avatar_url' => $avatarUrl,
            'status' => 'active',
            'email_verified_at' => now(),
        ]);
        Inspector::create([
            'user_id' => $user->id,
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'avatar_url' => $avatarUrl,
            'status' => 'active',
        ]);

        return $user;
    }

    private function customer(string $name, string $contact, string $email, string $phone): Customer
    {
        return Customer::create([
            'name' => $name,
            'contact_name' => $contact,
            'email' => $email,
            'phone' => $phone,
            'status' => 'active',
        ]);
    }

    private function site(Customer $customer, string $name, string $address, float $lat, float $lng, string $code, string $image): Site
    {
        return Site::create([
            'customer_id' => $customer->id,
            'name' => $name,
            'address' => $address,
            'latitude' => $lat,
            'longitude' => $lng,
            'qr_code' => "INSPECTLY:SITE:{$code}",
            'cover_image_url' => "assets/images/sites/{$image}.jpg",
            'status' => 'active',
        ]);
    }

    /**
     * @param  array<string, array<int, array{0: string, 1: string, 2: bool}>>  $sections
     */
    private function createTemplate(string $name, string $category, string $description, array $sections): InspectionTemplate
    {
        $template = InspectionTemplate::create([
            'name' => $name,
            'description' => $description,
            'category' => $category,
            'is_active' => true,
        ]);

        $sectionOrder = 0;
        foreach ($sections as $title => $items) {
            $section = TemplateSection::create([
                'template_id' => $template->id,
                'title' => $title,
                'sort_order' => $sectionOrder++,
            ]);
            foreach (array_values($items) as $i => [$label, $help, $evidence]) {
                TemplateChecklistItem::create([
                    'section_id' => $section->id,
                    'label' => $label,
                    'help_text' => $help,
                    'requires_evidence' => $evidence,
                    'sort_order' => $i,
                ]);
            }
        }

        return $template->fresh('sections.checklistItems');
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    private function inspection(InspectionTemplate $template, Site $site, User $inspector, string $status, array $attributes): Inspection
    {
        $inspection = Inspection::create(array_merge([
            'template_id' => $template->id,
            'customer_id' => $site->customer_id,
            'site_id' => $site->id,
            'inspector_id' => $inspector->id,
            'status' => $status,
            'recurrence' => Inspection::RECURRENCE_ONE_TIME,
        ], $attributes));

        $order = 0;
        foreach ($template->sections as $section) {
            foreach ($section->checklistItems as $checklistItem) {
                InspectionItem::create([
                    'inspection_id' => $inspection->id,
                    'template_checklist_item_id' => $checklistItem->id,
                    'label' => $checklistItem->label,
                    'sort_order' => $order++,
                ]);
            }
        }

        return $inspection;
    }

    /**
     * @param  array<string, array{0: string, 1: ?string}>  $results
     * @return Collection<string, InspectionItem>
     */
    private function answer(Inspection $inspection, array $results, ?string $default): Collection
    {
        $items = $inspection->items()->orderBy('sort_order')->get()->keyBy('label');
        foreach ($items as $label => $item) {
            [$result, $note] = $results[$label] ?? [$default, null];
            $item->update(['result' => $result, 'note' => $note]);
        }

        return $items;
    }

    /**
     * @param  array<int, string>  $photos
     */
    private function finding(Inspection $inspection, ?InspectionItem $item, string $title, string $severity, string $location, string $description, string $recommendation, array $photos, Carbon $at): Finding
    {
        $finding = Finding::create([
            'inspection_id' => $inspection->id,
            'inspection_item_id' => $item?->id,
            'title' => $title,
            'description' => $description,
            'severity' => $severity,
            'recommendation' => $recommendation,
            'location' => $location,
            'status' => Finding::STATUS_OPEN,
        ]);
        foreach ($photos as $i => $photo) {
            Evidence::create([
                'inspection_id' => $inspection->id,
                'finding_id' => $finding->id,
                'file_path' => self::EV.$photo,
                'latitude' => $inspection->site->latitude,
                'longitude' => $inspection->site->longitude,
                'captured_at' => $at->copy()->addMinutes(10 + $i),
            ]);
        }
        $this->logActivity($inspection, Activity::TYPE_FINDING_ADDED, sprintf('Finding "%s" added (%s).', $title, $severity), $inspection->inspector, $at->copy()->addMinutes(10));

        return $finding;
    }

    /**
     * @param  array<int, string>  $photos
     */
    private function itemPhotos(Inspection $inspection, InspectionItem $item, array $photos, Carbon $at): void
    {
        foreach ($photos as $i => $photo) {
            Evidence::create([
                'inspection_id' => $inspection->id,
                'inspection_item_id' => $item->id,
                'file_path' => self::EV.$photo,
                'latitude' => $inspection->site->latitude,
                'longitude' => $inspection->site->longitude,
                'captured_at' => $at->copy()->addMinutes(5 + $i),
            ]);
        }
    }

    private function sign(Inspection $inspection, string $inspector, Carbon $at): void
    {
        Signature::create([
            'inspection_id' => $inspection->id,
            'type' => Signature::TYPE_INSPECTOR,
            'signer_name' => $inspector,
            'file_path' => 'assets/images/demo/signature_inspector.png',
            'signed_at' => $at,
        ]);
        Signature::create([
            'inspection_id' => $inspection->id,
            'type' => Signature::TYPE_CUSTOMER,
            'signer_name' => 'Rachel Kim',
            'file_path' => 'assets/images/demo/signature_customer.png',
            'signed_at' => $at,
        ]);
    }

    private function finish(Inspection $inspection, User $actor, bool $withReport = false): void
    {
        $this->logActivity($inspection, Activity::TYPE_STARTED, 'Inspection started.', $actor, $inspection->started_at);
        $this->logActivity($inspection, Activity::TYPE_SIGNATURE_CAPTURED, "Inspector signature captured ({$actor->name}).", $actor, $inspection->completed_at->copy()->subMinutes(3));
        $this->logActivity($inspection, Activity::TYPE_SIGNATURE_CAPTURED, 'Customer signature captured (Rachel Kim).', $actor, $inspection->completed_at->copy()->subMinute());
        $this->logActivity($inspection, Activity::TYPE_COMPLETED, 'Inspection completed.', $actor, $inspection->completed_at);
        if ($withReport) {
            $this->logActivity($inspection, Activity::TYPE_REPORT_GENERATED, 'Report generated.', $actor, $inspection->completed_at->copy()->addMinute());
        }
        $inspection->update(['pass_percentage' => $inspection->fresh('items')->computePassPercentage()]);
    }

    private function logActivity(Inspection $inspection, string $type, string $description, User $actor, Carbon $occurredAt): Activity
    {
        return Activity::create([
            'inspection_id' => $inspection->id,
            'type' => $type,
            'description' => $description,
            'actor_user_id' => $actor->id,
            'occurred_at' => $occurredAt,
        ]);
    }
}
