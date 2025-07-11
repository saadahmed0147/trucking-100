import 'package:lucide_icons/lucide_icons.dart';

final List<Map<String, dynamic>> poiCategories = [
  {'label': 'Fuel', 'icon': LucideIcons.fuel, 'types': 'gas_station'},
  {
    'label': 'Convenience',
    'icon': LucideIcons.shoppingCart,
    'types': 'convenience_store|store|supermarket',
  },
  {'label': 'Truck Stops', 'icon': LucideIcons.truck, 'keyword': 'truck stop'},
  {
    'label': 'Food',
    'icon': LucideIcons.utensils,
    'types': 'restaurant|food|cafe',
  },
  {'label': 'Parking', 'icon': LucideIcons.parkingCircle, 'types': 'parking'},
  {'label': 'Truck Wash', 'icon': LucideIcons.showerHead, 'types': 'car_wash'},
  {'label': 'Walmart', 'icon': LucideIcons.store, 'keyword': 'Walmart'},
  {'label': 'Gym', 'icon': LucideIcons.dumbbell, 'types': 'gym'},
  {
    'label': 'ATM/Bank',
    'icon': LucideIcons.banknote,
    'types': 'atm|bank|finance',
  },
  {
    'label': 'Weigh Station',
    'icon': LucideIcons.scale,
    'keyword': 'weigh station',
  },
  {'label': 'Mechanics', 'icon': LucideIcons.wrench, 'types': 'car_repair'},
  {
    'label': 'Medical',
    'icon': LucideIcons.heartPulse,
    'types': 'hospital|doctor|pharmacy',
  },
  {'label': 'Rest/Hotels', 'icon': LucideIcons.bedDouble, 'types': 'lodging'},
  {
    'label': 'EV Charging',
    'icon': LucideIcons.batteryCharging,
    'types': 'electric_vehicle_charging_station',
  },
  {
    'label': 'Warehouses',
    'icon': LucideIcons.package,
    'types': 'storage|moving_company',
  },
  {'label': 'Border/Toll', 'icon': LucideIcons.shieldCheck, 'keyword': 'toll'},
];
