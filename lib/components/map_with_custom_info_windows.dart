import 'package:airbnb_app/Components/my_icon_button.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class MapWithCustomInfoWindows extends StatefulWidget {
  const MapWithCustomInfoWindows({super.key});

  @override
  State<MapWithCustomInfoWindows> createState() =>
      _MapWithCustomInfoWindowsState();
}

class _MapWithCustomInfoWindowsState extends State<MapWithCustomInfoWindows> {
  LatLng myCurrentLocation = const LatLng(10.7951, 106.7195); // VN
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  late GoogleMapController googleMapController;

  final CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();

  final CollectionReference placeCollection =
  FirebaseFirestore.instance.collection("myAppCpollection");

  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    // Custom marker icon
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 30)),
      "asset/images/marker.png",
    );

    // Lắng nghe dữ liệu Firestore
    placeCollection.snapshots().listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<Marker> myMarker = [];

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Chuyển imageUrls về List<String
          List<String> images = [];
          if (data['imageUrls'] is String) {
            images = [data['imageUrls']];
          } else if (data['imageUrls'] is List) {
            images = List<String>.from(data['imageUrls']);
          } else if (data['image'] != null) {
            images = [data['image']];
          }

          // Chuyển timestamp sang định dạng dd/MM/yyyy
          String dateText = '';
          if (data['date'] != null) {
            if (data['date'] is Timestamp) {
              final ts = data['date'] as Timestamp;
              final dt = ts.toDate();
              dateText = DateFormat('dd/MM/yyyy').format(dt);
            } else {
              dateText = data['date'].toString();
            }
          }

          myMarker.add(
            Marker(
              markerId: MarkerId(data['address'] ?? doc.id),
              position: LatLng(
                (data['latitude'] ?? 0).toDouble(),
                (data['longitude'] ?? 0).toDouble(),
              ),
              onTap: () {
                final Size size = MediaQuery.of(context).size;

                _customInfoWindowController.addInfoWindow!(
                  Container(
                    height: size.height * 0.36,
                    width: size.width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              height: size.height * 0.22,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                                child: AnotherCarousel(
                                  images: images
                                      .map((url) => NetworkImage(url))
                                      .toList(),
                                  dotSize: 5,
                                  indicatorBgPadding: 5,
                                  dotBgColor: Colors.transparent,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 14,
                              right: 14,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Text(
                                      "Khách yêu thích",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const MyIconButton(
                                    icon: Icons.favorite_border,
                                    radius: 15,
                                  ),
                                  const SizedBox(width: 13),
                                  InkWell(
                                    onTap: () {
                                      _customInfoWindowController.hideInfoWindow!();
                                    },
                                    child: const MyIconButton(
                                      icon: Icons.close,
                                      radius: 15,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['address'] ?? 'Địa chỉ chưa có',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.star, color: Colors.amber),
                                  const SizedBox(width: 5),
                                  Text((data['rating'] ?? 0).toString()),
                                ],
                              ),
                              if (data['bedAndBathroom'] != null)
                                Text(
                                  data['bedAndBathroom'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              if (dateText.isNotEmpty)
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              if (data['vendor'] != null && data['vendorProfession'] != null)
                                Text(
                                  "Ở cùng ${data['vendor']} • ${data['vendorProfession']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              Text.rich(
                                TextSpan(
                                  text: '\$${data['price'] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: ' / đêm',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  LatLng(
                    (data['latitude'] ?? 0).toDouble(),
                    (data['longitude'] ?? 0).toDouble(),
                  ),
                );
              },
              icon: customIcon,
            ),
          );
        }

        setState(() {
          markers = myMarker;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {
        showModalBottomSheet(
          clipBehavior: Clip.none,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return Container(
              color: Colors.white,
              height: size.height * 0.77,
              width: size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition:
                    CameraPosition(target: myCurrentLocation, zoom: 14),
                    onMapCreated: (controller) {
                      googleMapController = controller;
                      _customInfoWindowController.googleMapController = controller;
                    },
                    onTap: (pos) {
                      _customInfoWindowController.hideInfoWindow!();
                    },
                    onCameraMove: (pos) {
                      _customInfoWindowController.onCameraMove!();
                    },
                    markers: markers.toSet(),
                  ),
                  CustomInfoWindow(
                    controller: _customInfoWindowController,
                    height: size.height * 0.36,
                    width: size.width * 0.85,
                    offset: 50,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          children: [
            Text(
              "Bản đồ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.map_outlined, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
