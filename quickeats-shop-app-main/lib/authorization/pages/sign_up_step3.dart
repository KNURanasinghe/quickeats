import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/authorization/custom_widgets/custom_painter.dart';
import 'package:shop_app/custom_widgets/image_viewer.dart';
import 'package:shop_app/authorization/models/register/shop_documents.dart';
import 'package:shop_app/authorization/pages/sign_up_step4.dart';
import 'package:shop_app/authorization/provider/authorization_provider.dart';
import 'package:shop_app/custom_widgets/search_bar.dart';
import 'package:shop_app/services/location_services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shop_app/custom_widgets/custom_backarrow.dart';

class SignUpStep3 extends StatefulWidget {
  const SignUpStep3({
    super.key,
  });

  @override
  State<SignUpStep3> createState() => _SignUpStep3State();
}

class _SignUpStep3State extends State<SignUpStep3> {
  File? businessCertificate;
  File? shopLogo;
  File? shopBanner;
  LatLng? _selectedLocation;
  bool _isMapOpen = false;
  bool _isLoading = false;
  late AuthorizationProvider authorizationProvider;

  void _openLocationPicker() async {
    setState(() {
      _isMapOpen = true;
    });

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationPicker(
        onLocationConfirmed: (selectedLocation) {
          setState(() {
            _selectedLocation = selectedLocation;
          });
        },
      ),
    );

    setState(() {
      _isMapOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    authorizationProvider = Provider.of<AuthorizationProvider>(context);

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CustomPaint(
                            size: Size(MediaQuery.of(context).size.width, 200),
                            painter: RPSCustomPainter(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CustomBackArrow(),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -75),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sign Up As Shop Owner',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 28),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Fill in your shop details',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          ImageViewer(
                            label: 'Upload Business Certificate',
                            image: businessCertificate,
                            setImage: (image) {
                              setState(() {
                                businessCertificate = image;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          ImageViewer(
                            label: 'Upload Shop Logo',
                            image: shopLogo,
                            setImage: (image) {
                              setState(() {
                                shopLogo = image;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          ImageViewer(
                            label: 'Upload Shop Banner',
                            image: shopBanner,
                            setImage: (image) {
                              setState(() {
                                shopBanner = image;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Select the location of your shop',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _openLocationPicker,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedLocation == null
                                  ? const Color.fromARGB(255, 255, 196, 10)
                                  : Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                            ),
                            child: Text(
                              _selectedLocation == null
                                  ? "Select Your Location via Map"
                                  : "Location is Selected",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black)
                                : ElevatedButton(
                                    onPressed: () async {
                                      if (businessCertificate == null ||
                                          shopLogo == null ||
                                          shopBanner == null ||
                                          _selectedLocation == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Please complete all fields"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      try {
                                        setState(() => _isLoading = true);

                                        ShopDocuments shopDocuments =
                                            ShopDocuments(
                                          shopId: authorizationProvider.shopId!,
                                          certificateFile: '',
                                          latitude: _selectedLocation!.latitude,
                                          longitude:
                                              _selectedLocation!.longitude,
                                        );

                                        String? message =
                                            await authorizationProvider
                                                .step3ShopDocuments(
                                          shopDocuments,
                                          businessCertificate!,
                                          shopLogo!,
                                          shopBanner!,
                                        );

                                        setState(() => _isLoading = false);

                                        if (context.mounted) {
                                          print('message: $message');
                                          if (message ==
                                              'Documents uploaded successfully') {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(message ??
                                                    'Documents uploaded successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );

                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const SignUpStep4()),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(message ??
                                                    'Failed to save documents'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        setState(() => _isLoading = false);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignUpStep4()),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 196, 10),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 30),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Next",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 17,
                                              color: Colors.white),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(Icons.arrow_forward,
                                            color: Colors.white),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isMapOpen)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withAlpha(100)),
          ),
      ],
    );
  }
}

class _LocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationConfirmed;

  const _LocationPicker({required this.onLocationConfirmed});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<_LocationPicker> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng? _pickedLocation;
  double _zoomLevel = 12.0;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel += 1;
    });
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel -= 1;
    });
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Position position = await LocationServices().determinePosition();

      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _isLoading = false;

        _pickedLocation = currentLatLng;
        _markers.clear();
        _markers.add(Marker(
            markerId: MarkerId('currentLocation'), position: currentLatLng));
      });

      _mapController
          .animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 15));
    } catch (e) {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _searchLocation(String query) async {
    if (query.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          LatLng newLocation =
              LatLng(locations.first.latitude, locations.first.longitude);

          _mapController
              .animateCamera(CameraUpdate.newLatLngZoom(newLocation, 15));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text("Search result found! Tap on the map to select.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No results found. Try another query.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error searching location. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      primary: false,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchBox(
                    height: 50,
                    hiddenText: 'Search location...',
                    search: (value) {
                      _searchLocation(value);
                    }),
              ),
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: const LatLng(6.9271, 79.8612),
                        zoom: _zoomLevel,
                      ),
                      markers: _markers,
                      zoomControlsEnabled: false,
                      onTap: (position) {
                        setState(() {
                          _pickedLocation = position;
                          _markers.clear();
                          _markers.add(Marker(
                              markerId: MarkerId('selected'),
                              position: position));
                        });
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: "zoom_in",
                            mini: true,
                            backgroundColor: Colors.white,
                            onPressed: _zoomIn,
                            child: Icon(Icons.add, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: "zoom_out",
                            mini: true,
                            backgroundColor: Colors.white,
                            onPressed: _zoomOut,
                            child: Icon(Icons.remove, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: "current_location",
                            mini: true,
                            backgroundColor: Colors.white,
                            onPressed: _getCurrentLocation,
                            child: Icon(Icons.my_location, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? CircularProgressIndicator(color: Colors.black)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 196, 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        if (_pickedLocation != null) {
                          widget.onLocationConfirmed(_pickedLocation!);
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Please  Tap on the map to select location.")),
                          );
                          return;
                        }
                      },
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
