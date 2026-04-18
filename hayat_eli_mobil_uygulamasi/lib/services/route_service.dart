import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteService {
  static const String _apiKey = 'AIzaSyA0S2aZt3PcdG5KVDRx_gCmGsw2cPx4wfs';

  Future<Map<String, dynamic>?> getRouteDirections(
      LatLng origin, LatLng destination, {String mode = 'driving'}) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey&language=tr&mode=$mode';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          return _parseRoute(data['routes'][0]);
        }
      }
    } catch (e) {
      debugPrint('RouteService Error: $e');
    }
    return null;
  }

  /// Alternatif rotaları çeker (Google max 3 seçenek döner)
  Future<List<Map<String, dynamic>>> getAlternativeRoutes(
      LatLng origin, LatLng destination, {String mode = 'driving'}) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey&language=tr&mode=$mode&alternatives=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        return routes.map((r) => _parseRoute(r)).toList();
      }
    } catch (e) {
      debugPrint('RouteService Alternatives Error: $e');
    }
    return [];
  }

  Map<String, dynamic> _parseRoute(dynamic route) {
    final polyline = decodePolyline(route['overview_polyline']['points']);
    final leg = route['legs'][0];
    return {
      'polyline': polyline,
      'distance': leg['distance']['text'],
      'duration': leg['duration']['text'],
      'distance_value': leg['distance']['value'] as int, // metre cinsinden
      'end_address': leg['end_address'],
      'steps': leg['steps'],
    };
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
