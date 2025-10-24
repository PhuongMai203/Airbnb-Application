import 'package:airbnb_app/Components/location_in_map.dart';
import 'package:airbnb_app/Provider/favorite_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'widgets/detail_image_and_icon.dart';
import 'widgets/place_property_list.dart';
import 'widgets/rating_section.dart';
import 'widgets/price_and_reserve.dart';

class PlaceDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> place;
  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = FavoriteProvider.of(context);

    // Format date
    String formattedDate = '';
    if (widget.place['date'] != null) {
      if (widget.place['date'] is Timestamp) {
        formattedDate = DateFormat('dd/MM/yyyy')
            .format((widget.place['date'] as Timestamp).toDate());
      } else {
        formattedDate = widget.place['date'].toString();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailImageAndIcon(place: widget.place, provider: provider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.place['title'] ?? '',
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 25,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    "Phòng tại ${widget.place['address'] ?? ''}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.place['bedAndBathroom'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            RatingSection(place: widget.place),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlacePropertyList(
                    image:
                    "https://static.vecteezy.com/system/resources/previews/018/923/486/original/diamond-symbol-icon-png.png",
                    title: "Đây là một nơi hiếm",
                    subtitle:
                    "${widget.place['vendor'] ?? 'Chủ'} thường được đặt kín chỗ.",
                  ),
                  const Divider(),
                  PlacePropertyList(
                    image: widget.place['vendorProfile'] ?? '',
                    title: "Ở cùng ${widget.place['vendor'] ?? ''}",
                    subtitle:
                    "Superhost • ${widget.place['yearOfHosting'] ?? ''} năm lưu trú",
                  ),
                  const Divider(),
                  PlacePropertyList(
                    image:
                    "https://cdn-icons-png.flaticon.com/512/6192/6192020.png",
                    title: "Phòng trong căn hộ cho thuê",
                    subtitle:
                    "Phòng riêng trong nhà, có thể sử dụng các khu vực chung.",
                  ),
                  const Divider(),
                  const Text(
                    "Về nơi này",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
                  ),
                  const Divider(),
                  const Text(
                    "Vị trí",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.place['address'] ?? ''),
                  SizedBox(
                    height: 400,
                    width: size.width,
                    child: LocationInMap(place: widget.place),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: PriceAndReserve(
        place: widget.place,
        formattedDate: formattedDate,
      ),
    );
  }
}
