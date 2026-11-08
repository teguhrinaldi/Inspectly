# Inspectly — Asset Sources & Licensing

All demo imagery is sourced from [Pexels](https://www.pexels.com), used under the
[Pexels License](https://www.pexels.com/license/) (free for commercial and
non-commercial use, no attribution required — attribution is listed below anyway
as good practice). No AI-generated imagery is used for product demo assets.
Every image is bundled locally; nothing is hotlinked at runtime.

Photos were cropped/resized for their slot by `app/tool/process_assets.dart`
(run against the original downloads). The Oakwood photo is cropped so that a
third-party hotel sign in the original frame is not visible.

## Welcome screen (`app/assets/images/demo/`)

| File | Subject | Photographer | Source |
|---|---|---|---|
| `hero_inspector.jpg` | Engineer in hard hat and hi-vis vest with a tablet, outdoors | Mikael Blomkvist | https://www.pexels.com/photo/8961018/ |

## Avatars (`app/assets/images/avatars/`)

| File | Used for | Photographer | Source |
|---|---|---|---|
| `michael_carter.jpg` | Michael Carter (demo inspector) | artepixel prostudio | https://www.pexels.com/photo/28442318/ |
| `sarah_johnson.jpg` | Sarah Johnson (demo inspector) | image149 studio | https://www.pexels.com/photo/38707525/ |
| `daniel_brooks.jpg` | Daniel Brooks (demo inspector) | Nikolai Kyrychenko | https://www.pexels.com/photo/6942776/ |
| `admin.jpg` | Admin (demo) | John Stephenson | https://www.pexels.com/photo/5308640/ |

The people shown are stock models; the demo names are fictional.

## Site cover photos (`app/assets/images/sites/`)

| File | Subject | Photographer | Source |
|---|---|---|---|
| `riverside_office_complex.jpg` | Glass office building with trees | Zulfugarkarimov | https://www.pexels.com/photo/33719778/ |
| `westlake_apartments.jpg` | Modern apartment building exterior | Alejandro Robles Duque | https://www.pexels.com/photo/exterior-of-a-modern-apartment-building-in-city-17672408/ |
| `central_warehouse.jpg` | Warehouse interior | Andrea Piacquadio | https://www.pexels.com/photo/modern-interior-of-spacious-empty-warehouse-3831826/ |
| `maple_industrial_park.jpg` | Industrial/factory building exterior | Robert So | https://www.pexels.com/photo/exterior-of-a-factory-14601103/ |
| `oakwood_medical_center.jpg` | Modern building exterior (cropped) | Calvin Seng | https://www.pexels.com/photo/31836902/ |

## Evidence photos (`app/assets/images/evidence/`)

Stand-ins for what an inspector's own camera would capture on the seeded demo
findings (see `docs/demo-data.md`). Evidence captured in the app always uses
the device camera or gallery, never a bundled photo.

| File | Subject | Photographer | Source |
|---|---|---|---|
| `electrical_panel_damage.jpg` | Open electrical panel/switchbox | Ksenia Chernaya | https://www.pexels.com/photo/an-opened-switchbox-5767595/ |
| `electrical_panel_current.jpg` | Breaker panel with coloured wiring | Ranjeet | https://www.pexels.com/photo/28950842/ |
| `electrical_room.jpg` | Industrial room with labeled fuse boxes | Kostiantyn Klymovets | https://www.pexels.com/photo/13172736/ |
| `exposed_wiring.jpg` | Exposed wires on a wall | DeeanaCreates | https://www.pexels.com/photo/12224405/ |
| `fire_extinguisher_expired.jpg` | Wall-mounted fire extinguisher | Ian Panelo | https://www.pexels.com/photo/red-fire-extinguisher-against-wall-4805958/ |
| `blocked_exit.jpg` | Fire exit doors with chairs in front | ADU | https://www.pexels.com/photo/5613865/ |
| `leaking_pipe.jpg` | Leaking pipe with dripping water | Swastika Rora | https://www.pexels.com/photo/15206136/ |
| `leaking_pipe_2.jpg` | Dripping outdoor pipe | Khanh Dang | https://www.pexels.com/photo/36571568/ |
| `roof_damage.jpg` | Old roof with missing shingles | Mat Reding | https://www.pexels.com/photo/6931459/ |
| `roof_damage_2.jpg` | House with a broken roof | Peter Dyllong | https://www.pexels.com/photo/36237047/ |
| `smoke_detector.jpg` | Ceiling-mounted fire alarm | Caleb Oquendo | https://www.pexels.com/photo/39183052/ |
| `water_stained_ceiling.jpg` | Damaged, stained ceiling | Eikenaar | https://www.pexels.com/photo/14032089/ |
| `exit_sign.jpg` | Illuminated exit sign in a hallway | wanxianren | https://www.pexels.com/photo/5036652/ |
| `leaking_pipe_3.jpg` | Rusted pipe dripping water | Eberhard Gross | https://www.pexels.com/photo/4406597/ |

## Demo signatures (`app/assets/images/demo/`)

`signature_inspector.png` and `signature_customer.png` are programmatically
generated stroke drawings (not photographs, `app/tool/gen_signatures.dart`),
used only on the seeded historical inspections. They do not depict or imitate
any real person's signature. Signatures captured in the app are drawn by the
user on the signature pad.

## Font

Inter 4.1 by Rasmus Andersson (`app/assets/fonts/Inter-*.ttf`), licensed under
the SIL Open Font License 1.1 — full text in
`app/assets/fonts/Inter-OFL-LICENSE.txt`.

## Icons

Lucide icon family via the `lucide_icons_flutter` package (ISC license). The
original `lucide_icons` package no longer compiles against current Flutter SDKs
(`IconData` became a `final` class).

## Brand mark

The Inspectly shield-and-check logo is drawn in code
(`app/lib/core/widgets/inspectly_logo.dart`) — no image file, no third-party
artwork.

## Web admin copy (`BE/public/demo-assets/`)

The seeded database rows point at the app's bundled paths (`assets/images/...`).
The same avatar, site, evidence and signature files are copied to
`BE/public/demo-assets/` so the Filament admin can display them
(`App\Support\MediaUrl` maps one path to the other). Same sources and license
as above.
