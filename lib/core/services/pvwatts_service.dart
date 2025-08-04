import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for interacting with the NREL PVWatts V8 API
class PVWattsService {
  static const String _baseUrl = 'https://developer.nrel.gov/api/pvwatts/v8';
  static const String _apiKey =
      'mz7EP8r1LLmzzN1HZFPiM5FRBtF46MrH3hi5voVb'; // mz7EP8r1LLmzzN1HZFPiM5FRBtF46MrH3hi5voVb

  /// PVWatts API response model
  static Future<PVWattsResponse> calculateProduction({
    required double systemCapacity,
    required double latitude,
    required double longitude,
    required int moduleType,
    required int arrayType,
    required double tilt,
    required double azimuth,
    required double losses,
    double? dcAcRatio,
    double? invEff,
    double? gcr,
    double? bifaciality,
    double? albedo,
    List<double>? soiling,
    String dataset = 'nsrdb',
    int radius = 100,
  }) async {
    try {
      // ===== DEBUG SECTION START - COMMENT OUT FOR PRODUCTION =====
      print('=== PVWatts API DEBUG START ===');
      print('API Call Parameters:');
      print('  System Capacity: ${systemCapacity.toStringAsFixed(2)} kW');
      print('  Latitude: $latitude');
      print('  Longitude: $longitude');
      print('  Module Type: $moduleType');
      print('  Array Type: $arrayType');
      print('  Tilt: ${tilt.toStringAsFixed(1)}°');
      print('  Azimuth: ${azimuth.toStringAsFixed(1)}°');
      print('  Losses: ${losses.toStringAsFixed(1)}%');
      print('  Dataset: $dataset');
      print('  Radius: $radius miles');
      if (dcAcRatio != null) print('  DC/AC Ratio: $dcAcRatio');
      if (invEff != null)
        print('  Inverter Efficiency: ${invEff.toStringAsFixed(1)}%');
      if (gcr != null) print('  Ground Coverage Ratio: $gcr');
      if (bifaciality != null) print('  Bifaciality: $bifaciality');
      if (albedo != null) print('  Albedo: $albedo');
      if (soiling != null) print('  Soiling: ${soiling.join('|')}');
      print('');

      // Build query parameters
      final queryParams = {
        'format': 'json',
        'api_key': _apiKey,
        'system_capacity': systemCapacity.toString(),
        'module_type': moduleType.toString(),
        'array_type': arrayType.toString(),
        'tilt': tilt.toString(),
        'azimuth': azimuth.toString(),
        'losses': losses.toString(),
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'dataset': dataset,
        'radius': radius.toString(),
      };

      // Add optional parameters
      if (dcAcRatio != null) queryParams['dc_ac_ratio'] = dcAcRatio.toString();
      if (invEff != null) queryParams['inv_eff'] = invEff.toString();
      if (gcr != null) queryParams['gcr'] = gcr.toString();
      if (bifaciality != null)
        queryParams['bifaciality'] = bifaciality.toString();
      if (albedo != null) queryParams['albedo'] = albedo.toString();
      if (soiling != null) {
        queryParams['soiling'] = soiling.join('|');
      }

      // Build URL
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      print('API URL: ${uri.toString()}');
      print('');

      // Make API call
      print('Making API call...');
      final response = await http.get(uri);
      print('API Response Status: ${response.statusCode}');
      print('API Response Body Length: ${response.body.length} characters');
      print('');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ===== DEBUG SECTION START - COMMENT OUT FOR PRODUCTION =====
        print('API Response Data:');
        if (data['errors'] != null && (data['errors'] as List).isNotEmpty) {
          print('  Errors: ${data['errors']}');
        }
        if (data['warnings'] != null && (data['warnings'] as List).isNotEmpty) {
          print('  Warnings: ${data['warnings']}');
        }
        if (data['outputs'] != null) {
          final outputs = data['outputs'];
          print(
              '  Annual AC Output: ${outputs['ac_annual']?.toStringAsFixed(2)} kWh');
          print(
              '  Capacity Factor: ${(outputs['capacity_factor'] * 100)?.toStringAsFixed(2)}%');
          print(
              '  Annual Solar Radiation: ${outputs['solrad_annual']?.toStringAsFixed(2)} kWh/m²/day');
        }
        print('=== PVWatts API DEBUG END ===');
        // ===== DEBUG SECTION END - COMMENT OUT FOR PRODUCTION =====

        return PVWattsResponse.fromJson(data);
      } else {
        print('API Error Response: ${response.body}');
        print('=== PVWatts API DEBUG END ===');
        throw Exception(
            'PVWatts API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('API Exception: $e');
      print('=== PVWatts API DEBUG END ===');
      throw Exception('Failed to calculate production: $e');
    }
  }
}

/// Response model for PVWatts API
class PVWattsResponse {
  final Map<String, dynamic> inputs;
  final List<String> errors;
  final List<String> warnings;
  final String version;
  final Map<String, dynamic> sscInfo;
  final StationInfo stationInfo;
  final PVWattsOutputs outputs;

  PVWattsResponse({
    required this.inputs,
    required this.errors,
    required this.warnings,
    required this.version,
    required this.sscInfo,
    required this.stationInfo,
    required this.outputs,
  });

  factory PVWattsResponse.fromJson(Map<String, dynamic> json) {
    return PVWattsResponse(
      inputs: json['inputs'] ?? {},
      errors: List<String>.from(json['errors'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      version: json['version'] ?? '',
      sscInfo: json['ssc_info'] ?? {},
      stationInfo: StationInfo.fromJson(json['station_info'] ?? {}),
      outputs: PVWattsOutputs.fromJson(json['outputs'] ?? {}),
    );
  }

  /// Check if the response has errors
  bool get hasErrors => errors.isNotEmpty;

  /// Get the first error message
  String? get firstError => errors.isNotEmpty ? errors.first : null;
}

/// Station information from PVWatts API
class StationInfo {
  final double latitude;
  final double longitude;
  final double elevation;
  final double timezone;
  final String location;
  final String city;
  final String state;
  final String solarResourceFile;
  final int distance;
  final String weatherDataSource;

  StationInfo({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.timezone,
    required this.location,
    required this.city,
    required this.state,
    required this.solarResourceFile,
    required this.distance,
    required this.weatherDataSource,
  });

  factory StationInfo.fromJson(Map<String, dynamic> json) {
    return StationInfo(
      latitude: (json['lat'] ?? 0.0).toDouble(),
      longitude: (json['lon'] ?? 0.0).toDouble(),
      elevation: (json['elev'] ?? 0.0).toDouble(),
      timezone: (json['tz'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      solarResourceFile: json['solar_resource_file'] ?? '',
      distance: json['distance'] ?? 0,
      weatherDataSource: json['weather_data_source'] ?? '',
    );
  }
}

/// Output data from PVWatts API
class PVWattsOutputs {
  final List<double> poaMonthly;
  final List<double> dcMonthly;
  final List<double> acMonthly;
  final double acAnnual;
  final List<double> solradMonthly;
  final double solradAnnual;
  final double capacityFactor;

  PVWattsOutputs({
    required this.poaMonthly,
    required this.dcMonthly,
    required this.acMonthly,
    required this.acAnnual,
    required this.solradMonthly,
    required this.solradAnnual,
    required this.capacityFactor,
  });

  factory PVWattsOutputs.fromJson(Map<String, dynamic> json) {
    return PVWattsOutputs(
      poaMonthly: List<double>.from(json['poa_monthly'] ?? []),
      dcMonthly: List<double>.from(json['dc_monthly'] ?? []),
      acMonthly: List<double>.from(json['ac_monthly'] ?? []),
      acAnnual: (json['ac_annual'] ?? 0.0).toDouble(),
      solradMonthly: List<double>.from(json['solrad_monthly'] ?? []),
      solradAnnual: (json['solrad_annual'] ?? 0.0).toDouble(),
      capacityFactor: (json['capacity_factor'] ?? 0.0).toDouble(),
    );
  }

  /// Get monthly AC production in kWh
  double getMonthlyProduction(int month) {
    if (month >= 1 && month <= 12 && month <= acMonthly.length) {
      return acMonthly[month - 1];
    }
    return 0.0;
  }

  /// Get average monthly production
  double get averageMonthlyProduction {
    if (acMonthly.isEmpty) return 0.0;
    return acAnnual / 12;
  }

  /// Get average daily production
  double get averageDailyProduction {
    return acAnnual / 365;
  }
}

/// Module types for PVWatts API
class ModuleType {
  static const int standard = 0;
  static const int premium = 1;
  static const int thinFilm = 2;
}

/// Array types for PVWatts API
class ArrayType {
  static const int fixedOpenRack = 0;
  static const int fixedRoofMounted = 1;
  static const int oneAxis = 2;
  static const int oneAxisBacktracking = 3;
  static const int twoAxis = 4;
}
