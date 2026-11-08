# Inspectly — Demo Data Narrative

The Flutter demo data (`app/lib/data/datasources/demo/`) and the Laravel seeder
(`BE/database/seeders/DemoSeeder.php`) implement the same story. It is built so
the app's real calculations reproduce the numbers shown in the approved mockup
(`docs/design/inspectly_master_mockup.png`) — no widget hardcodes a value.
Both sides are locked by tests (`app/test/data/demo_data_store_test.dart`,
`BE/tests/Feature/FilamentAdminPanelTest.php`).

## How the numbers are calculated

| Shown | Definition |
|---|---|
| Overall Compliance (risk ring, admin donut centre) | 100 − Σ deductions per finding: Critical 8, High 5, Medium 2, Low 1 (min 0) |
| Passed / Needs Attention / Failed | Passed items; failed items whose findings are only medium/low; failed items with a critical/high finding |
| Home "Today's Inspections" tiles | The signed-in inspector's scheduled / in-progress / review inspections |
| Admin Total / In Progress / Completed | Current counts (drafts excluded) |
| Admin Open Findings | Open findings on each site's most recent performed inspection |
| Admin trends | Last 30 days vs the 30 before, day-based: inspections scheduled / started / completed, findings raised |
| Admin Risk Overview | The most recently completed inspection |
| Admin Recent Findings | Newest open finding at each site, most recent site first |
| Site history | Completed inspections only |

## Dates

The story is written as if today were Sep 29 (the mockup day): site history on
Jul 3, Aug 12, Sep 27 (and Sep 23–26 site records), next visits on Dec 5 /
Dec 27 / Jan 14, work items today and tomorrow.

- **Laravel (`DemoSeeder`)**: every story day keeps its distance to the day you
  seed (Sep 27 = 2 days ago, Dec 27 = in 89 days …), so the admin dashboard
  shows the mockup numbers on any date. Dates on screen are therefore relative
  to the seeding day, not literally "Sep 27".
- **Flutter Demo Mode**: site history stays on the literal calendar days of the
  most recent year in which Sep 27 has passed; work items are relative to today.

## People, customers, sites, templates

- Inspectors: Michael Carter (default login), Sarah Johnson, Daniel Brooks; Admin. Password `password`.
- Customers: Northbridge Facilities, Westlake Holdings, Central Warehouse Group, Oakwood Health Partners.
- Sites: Riverside Office Complex, Westlake Apartments, Central Warehouse, Maple Industrial Park, Oakwood Medical Center.
- Templates (3 sections each): Safety 12 items (Fire Safety 4, Electrical Safety 3, General Condition 5), Property 10, Equipment 8, Vehicle 9.

## Key inspections

| Inspection | Status | Mockup screen it drives |
|---|---|---|
| Riverside · Safety · today 09:30 (Michael) | In progress, 7/12, 3 findings, 14 photos | Home, List, Detail, Checklist |
| Westlake · Property · today 14:00 (Michael) | Scheduled | Home, List, admin Recent Inspections |
| Central Warehouse · Equipment · tomorrow 09:00 (Michael) | Review (performed Sep 24) | Home, List, admin |
| Maple · Safety · tomorrow 10:30 (Daniel) | Completed early (Sep 25), 1 open finding: Blocked Emergency Exit | List, admin |
| Oakwood · Property · Dec 5 08:00 (Michael) | Scheduled | List |
| Riverside · Safety · Sep 27 (Michael) | Completed: 7 pass / 3 attention / 2 failed, findings 1C 3H 2M 1L → 72%, next Dec 27 | Findings, Evidence, Risk Summary, Comparison, admin donut |
| Riverside · Safety · Aug 12 | Completed: Damaged Electrical Panel (H), Flickering Emergency Light (M) | Comparison "Previous" |
| Riverside · Equipment · Jul 3 | Completed, all pass | History |
| Westlake · Property · Sep 26 (Daniel) | Completed: Loose Stair Handrail (L), Leaking Pipe (M) | admin Recent Findings |

Sep 27 findings in logged order: Damaged Electrical Panel (High, 2 photos),
Leaking Pipe (Medium, 3), Blocked Emergency Exit (High, 1), Roof Damage (Low, 2),
Exposed Live Wiring (Critical, 1), Exit Sign Not Illuminated (High, 1),
Water-Stained Ceiling (Medium, 1).

Michael also has a Central Warehouse Safety inspection scheduled Jan 14 and an
Oakwood inspection in progress since yesterday — together: 3 scheduled, 2 in
progress, 1 review.

## Routine history

37 earlier inspections at Westlake, Central Warehouse, Maple and Oakwood
(`planFillers()` / `seedFillers()`), all dated before Sep 24 with their findings
resolved. Their number and dates are derived from the targets so the admin
dashboard shows 48 inspections (12 in progress, 32 completed, 7 open findings)
and, for the last 30 days vs the 30 before: scheduled 19 vs 17 (+12%),
completed 14 vs 13 (+8%), findings raised 40 vs 41 (−2%).
