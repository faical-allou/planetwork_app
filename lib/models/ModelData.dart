Map<String, String> listInput = {
  'sked': 'Schedule',
  'config': 'Aircraft Configuration',
  'aircraft_fix_cost': 'Aircraft Fixed Cost',
  'airport_cost': 'Airport Cost',
  'route_cost': 'Route Cost',
};

Map<String, String> listData = {
  'comp': 'Competition',
  'demand': 'Market sizes',
  'demand_curve': 'Demand Curve',
};

Map<String, String> listParam = {
  'connections': 'Connection Parameters',
  'preferences': 'Market Preferences',
};

Map<String, String> fullList = listInput
  ..addAll(listParam)
  ..addAll(listData);
