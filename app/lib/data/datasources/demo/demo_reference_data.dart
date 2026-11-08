import '../../models/app_user.dart';
import '../../models/customer.dart';
import '../../models/enums.dart';
import '../../models/inspection_template.dart';
import '../../models/inspector.dart';
import '../../models/site.dart';

/// Static reference data for Demo Mode. See docs/demo-data.md — this file must
/// stay in sync with that narrative (and with BE/database/seeders which tell
/// the same story server-side).
class DemoReferenceData {
  DemoReferenceData._();

  // --- Users / Inspectors ---------------------------------------------------

  static const avatarMichael = 'assets/images/avatars/michael_carter.jpg';
  static const avatarSarah = 'assets/images/avatars/sarah_johnson.jpg';
  static const avatarDaniel = 'assets/images/avatars/daniel_brooks.jpg';
  static const avatarAdmin = 'assets/images/avatars/admin.jpg';

  static const inspectorMichael = AppUser(
    id: 'user-michael',
    name: 'Michael Carter',
    email: 'michael.carter@inspectly.test',
    role: UserRole.inspector,
    phone: '+1 (415) 555-0148',
    avatarUrl: avatarMichael,
  );

  static const inspectorSarah = AppUser(
    id: 'user-sarah',
    name: 'Sarah Johnson',
    email: 'sarah.johnson@inspectly.test',
    role: UserRole.inspector,
    avatarUrl: avatarSarah,
  );

  static const inspectorDaniel = AppUser(
    id: 'user-daniel',
    name: 'Daniel Brooks',
    email: 'daniel.brooks@inspectly.test',
    role: UserRole.inspector,
    avatarUrl: avatarDaniel,
  );

  static const admin = AppUser(
    id: 'user-admin',
    name: 'Admin',
    email: 'admin@inspectly.test',
    role: UserRole.admin,
    avatarUrl: avatarAdmin,
  );

  static const users = [
    inspectorMichael,
    inspectorSarah,
    inspectorDaniel,
    admin,
  ];

  static const inspectors = [
    Inspector(
      id: 'inspector-michael',
      userId: 'user-michael',
      name: 'Michael Carter',
      email: 'michael.carter@inspectly.test',
      phone: '+1 (415) 555-0148',
      avatarUrl: avatarMichael,
    ),
    Inspector(
      id: 'inspector-sarah',
      userId: 'user-sarah',
      name: 'Sarah Johnson',
      email: 'sarah.johnson@inspectly.test',
      avatarUrl: avatarSarah,
    ),
    Inspector(
      id: 'inspector-daniel',
      userId: 'user-daniel',
      name: 'Daniel Brooks',
      email: 'daniel.brooks@inspectly.test',
      avatarUrl: avatarDaniel,
    ),
  ];

  // --- Customers -------------------------------------------------------------

  static const customers = [
    Customer(
      id: 'cust-northbridge',
      name: 'Northbridge Facilities',
      contactName: 'Rachel Kim',
      email: 'rachel.kim@northbridgefacilities.com',
      phone: '+1 (212) 555-0110',
    ),
    Customer(
      id: 'cust-westlake',
      name: 'Westlake Holdings',
      contactName: 'Marcus Webb',
      email: 'marcus.webb@westlakeholdings.com',
      phone: '+1 (312) 555-0166',
    ),
    Customer(
      id: 'cust-centralwh',
      name: 'Central Warehouse Group',
      contactName: 'Priya Anand',
      email: 'priya.anand@centralwarehousegroup.com',
      phone: '+1 (773) 555-0121',
    ),
    Customer(
      id: 'cust-oakwood',
      name: 'Oakwood Health Partners',
      contactName: 'Elena Brooks',
      email: 'elena.brooks@oakwoodhealthpartners.com',
      phone: '+1 (617) 555-0192',
    ),
  ];

  // --- Sites -------------------------------------------------------------

  static const siteRiverside = Site(
    id: 'site-riverside',
    customerId: 'cust-northbridge',
    customerName: 'Northbridge Facilities',
    name: 'Riverside Office Complex',
    address: '480 Riverside Dr, New York, NY',
    latitude: 40.7712,
    longitude: -73.9542,
    qrCode: 'INSPECTLY:SITE:RIVERSIDE-001',
    coverImageUrl: 'assets/images/sites/riverside_office_complex.jpg',
  );

  static const siteWestlakeApartments = Site(
    id: 'site-westlake-apts',
    customerId: 'cust-westlake',
    customerName: 'Westlake Holdings',
    name: 'Westlake Apartments',
    address: '1220 Westlake Ave, Chicago, IL',
    latitude: 41.8859,
    longitude: -87.6295,
    qrCode: 'INSPECTLY:SITE:WESTLAKE-001',
    coverImageUrl: 'assets/images/sites/westlake_apartments.jpg',
  );

  static const siteCentralWarehouse = Site(
    id: 'site-centralwh',
    customerId: 'cust-centralwh',
    customerName: 'Central Warehouse Group',
    name: 'Central Warehouse',
    address: '900 Distribution Pkwy, Chicago, IL',
    latitude: 41.8656,
    longitude: -87.6771,
    qrCode: 'INSPECTLY:SITE:CENTRALWH-001',
    coverImageUrl: 'assets/images/sites/central_warehouse.jpg',
  );

  static const siteMaple = Site(
    id: 'site-maple',
    customerId: 'cust-northbridge',
    customerName: 'Northbridge Facilities',
    name: 'Maple Industrial Park',
    address: '55 Maple Industrial Rd, Newark, NJ',
    latitude: 40.7357,
    longitude: -74.1724,
    qrCode: 'INSPECTLY:SITE:MAPLE-001',
    coverImageUrl: 'assets/images/sites/maple_industrial_park.jpg',
  );

  static const siteOakwood = Site(
    id: 'site-oakwood',
    customerId: 'cust-oakwood',
    customerName: 'Oakwood Health Partners',
    name: 'Oakwood Medical Center',
    address: '1500 Oakwood Blvd, Boston, MA',
    latitude: 42.3389,
    longitude: -71.1066,
    qrCode: 'INSPECTLY:SITE:OAKWOOD-001',
    coverImageUrl: 'assets/images/sites/oakwood_medical_center.jpg',
  );

  static const sites = [
    siteRiverside,
    siteWestlakeApartments,
    siteCentralWarehouse,
    siteMaple,
    siteOakwood,
  ];

  // --- Templates -------------------------------------------------------------

  static InspectionTemplate _template(
    String id,
    String name,
    String description,
    String category,
    List<(String, String, List<(String, String, String, bool)>)> sections,
  ) {
    return InspectionTemplate(
      id: id,
      name: name,
      description: description,
      category: category,
      sections: [
        for (final (i, (sectionId, title, items)) in sections.indexed)
          TemplateSection(
            id: sectionId,
            templateId: id,
            title: title,
            sortOrder: i,
            items: [
              for (final (j, (itemId, label, help, evidence)) in items.indexed)
                TemplateChecklistItem(
                  id: itemId,
                  sectionId: sectionId,
                  label: label,
                  helpText: help,
                  requiresEvidence: evidence,
                  sortOrder: j,
                ),
            ],
          ),
      ],
    );
  }

  static final templateSafety = _template(
    'tmpl-safety',
    'Safety Inspection',
    'General safety inspection for buildings and facilities.',
    'safety',
    [
      (
        'sec-safety-fire',
        'Fire Safety',
        [
          (
            'item-safety-fire-extinguishers',
            'Fire Extinguisher',
            'Is the extinguisher accessible and properly mounted?',
            true,
          ),
          (
            'item-safety-fire-exits',
            'Emergency Exits',
            'Are emergency exits unobstructed and clearly signed?',
            true,
          ),
          (
            'item-safety-smoke-detectors',
            'Smoke Detectors',
            'Do smoke detectors respond to the test button?',
            false,
          ),
          (
            'item-safety-emergency-lighting',
            'Emergency Lighting',
            'Does emergency lighting hold steady when tested?',
            false,
          ),
        ],
      ),
      (
        'sec-safety-electrical',
        'Electrical Safety',
        [
          (
            'item-safety-elec-panels',
            'Electrical Panel',
            'Is the panel secured, labeled and free of damage?',
            true,
          ),
          (
            'item-safety-elec-wiring',
            'Wiring',
            'Is all wiring enclosed with no exposed conductors?',
            false,
          ),
          (
            'item-safety-elec-gfci',
            'GFCI Outlets',
            'Do GFCI outlets trip and reset correctly?',
            false,
          ),
        ],
      ),
      (
        'sec-safety-general',
        'General Condition',
        [
          (
            'item-safety-gen-plumbing',
            'Plumbing',
            'Are pipes and fixtures free of leaks?',
            true,
          ),
          (
            'item-safety-gen-ceilings',
            'Walls & Ceilings',
            'Are walls and ceilings free of water stains or damage?',
            false,
          ),
          (
            'item-safety-gen-roof',
            'Roof & Drainage',
            'Is the roof free of damage and are drains clear?',
            true,
          ),
          (
            'item-safety-gen-walkways',
            'Walkways',
            'Are walkways dry and free of trip hazards?',
            false,
          ),
          (
            'item-safety-gen-signage',
            'Safety Signage',
            'Is required safety signage posted and legible?',
            false,
          ),
        ],
      ),
    ],
  );

  static final templateProperty = _template(
    'tmpl-property',
    'Property Inspection',
    'General condition of the property, exterior and interior.',
    'property',
    [
      (
        'sec-property-exterior',
        'Exterior',
        [
          (
            'item-property-roof',
            'Roof',
            'Is the roof covering intact with no missing sections?',
            false,
          ),
          (
            'item-property-facade',
            'Facade',
            'Is the facade free of cracks and loose cladding?',
            false,
          ),
          (
            'item-property-parking',
            'Parking Lot',
            'Is the parking surface free of potholes and hazards?',
            false,
          ),
          (
            'item-property-signage',
            'Signage',
            'Is exterior signage intact and legible?',
            true,
          ),
        ],
      ),
      (
        'sec-property-interior',
        'Interior',
        [
          (
            'item-property-flooring',
            'Flooring',
            'Is flooring secure with no trip hazards?',
            false,
          ),
          (
            'item-property-walls',
            'Walls & Ceilings',
            'Are walls and ceilings free of damage or stains?',
            false,
          ),
          (
            'item-property-doors',
            'Doors & Locks',
            'Do doors close and lock correctly?',
            false,
          ),
        ],
      ),
      (
        'sec-property-services',
        'Building Services',
        [
          (
            'item-property-hvac-filters',
            'HVAC Filters',
            'Are HVAC filters clean and within service date?',
            false,
          ),
          (
            'item-property-water-heater',
            'Water Heater',
            'Is the water heater free of leaks and corrosion?',
            false,
          ),
          (
            'item-property-lighting',
            'Common Area Lighting',
            'Are all common area lights working?',
            false,
          ),
        ],
      ),
    ],
  );

  static final templateEquipment = _template(
    'tmpl-equipment',
    'Equipment Inspection',
    'HVAC, backup power and lifting equipment check.',
    'equipment',
    [
      (
        'sec-equipment-hvac',
        'HVAC',
        [
          (
            'item-equipment-hvac-unit',
            'HVAC Unit',
            'Is the unit operating normally?',
            false,
          ),
          (
            'item-equipment-hvac-filters',
            'Filters',
            'Are filters within their service life?',
            false,
          ),
          (
            'item-equipment-hvac-noise',
            'Noise & Vibration',
            'Is the unit free of unusual noise or vibration?',
            false,
          ),
        ],
      ),
      (
        'sec-equipment-electrical',
        'Electrical Systems',
        [
          (
            'item-equipment-elec-generator',
            'Backup Generator',
            'Does the backup generator start and hold load?',
            true,
          ),
          (
            'item-equipment-elec-panels',
            'Panel Breakers',
            'Are panel breakers labeled and undamaged?',
            false,
          ),
          (
            'item-equipment-elec-ups',
            'UPS Battery',
            'Is the UPS battery within its test date?',
            false,
          ),
        ],
      ),
      (
        'sec-equipment-lifting',
        'Lifting Equipment',
        [
          (
            'item-equipment-forklift',
            'Forklift',
            'Has the forklift passed its pre-use check?',
            true,
          ),
          (
            'item-equipment-dock-leveler',
            'Dock Leveler',
            'Does the dock leveler raise and lower smoothly?',
            false,
          ),
        ],
      ),
    ],
  );

  static final templateVehicle = _template(
    'tmpl-vehicle',
    'Vehicle Inspection',
    'Fleet vehicle exterior, tires and safety equipment check.',
    'vehicle',
    [
      (
        'sec-vehicle-exterior',
        'Exterior & Tires',
        [
          (
            'item-vehicle-tires',
            'Tire Tread',
            'Is tire tread depth above the legal minimum?',
            false,
          ),
          (
            'item-vehicle-damage',
            'Body Damage',
            'Is the body free of new damage?',
            true,
          ),
          (
            'item-vehicle-lights',
            'Lights',
            'Are all exterior lights functional?',
            false,
          ),
        ],
      ),
      (
        'sec-vehicle-interior',
        'Interior & Safety',
        [
          (
            'item-vehicle-seatbelts',
            'Seatbelts',
            'Do all seatbelts latch and retract?',
            false,
          ),
          (
            'item-vehicle-firstaid',
            'First Aid Kit',
            'Is a stocked first aid kit on board?',
            false,
          ),
          (
            'item-vehicle-extinguisher',
            'Fire Extinguisher',
            'Is a charged extinguisher on board?',
            false,
          ),
        ],
      ),
      (
        'sec-vehicle-mechanical',
        'Mechanical',
        [
          (
            'item-vehicle-brakes',
            'Brakes',
            'Do brakes respond without noise or pulling?',
            false,
          ),
          (
            'item-vehicle-fluids',
            'Fluid Levels',
            'Are oil, coolant and washer fluid at level?',
            false,
          ),
          (
            'item-vehicle-horn',
            'Horn & Wipers',
            'Do the horn and wipers work?',
            false,
          ),
        ],
      ),
    ],
  );

  static final templates = [
    templateSafety,
    templateProperty,
    templateEquipment,
    templateVehicle,
  ];
}
