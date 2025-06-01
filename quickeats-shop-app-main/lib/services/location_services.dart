import 'package:geolocator/geolocator.dart';

class LocationServices {
  Future<Position> determinePosition() async {
    await requestPermission();
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );
  }

  Future<String> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled';
    }

    // Request permission
    permission = await Geolocator.requestPermission();

    // Check permission status
    if (permission == LocationPermission.denied) {
      return 'Location permissions are denied';
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permissions are permanently denied';
    }

    return 'Location permission granted and service enabled';
  }
}
