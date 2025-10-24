import 'package:airbnb_app/Provider/favorite_provider.dart';
import 'package:airbnb_app/view/place_detail_screen.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayPlace extends StatefulWidget {
  const DisplayPlace({super.key});

  @override
  State<DisplayPlace> createState() => _DisplayPlaceState();
}

class _DisplayPlaceState extends State<DisplayPlace> {
  final CollectionReference placeCollection =
  FirebaseFirestore.instance.collection("myAppCpollection");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = FavoriteProvider.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: placeCollection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final places = snapshot.data!.docs;

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            final data = place.data() as Map<String, dynamic>;

            // Kiểm tra imageUrls có phải là string hay list
            List<String> images = [];

// Nếu imageUrls là String -> tạo List chứa 1 phần tử
            if (data['imageUrls'] is String) {
              images = [data['imageUrls']];
            }
// Nếu imageUrls là List -> chuyển sang List<String>
            else if (data['imageUrls'] is List) {
              images = List<String>.from(data['imageUrls']);
            }
// Nếu không có imageUrls nhưng có image -> dùng image
            else if (data['image'] != null) {
              images = [data['image']];
            }

            // Chuyển date sang string
            String dateText = '';
            if (data['date'] != null && data['date'] is Timestamp) {
              final ts = data['date'] as Timestamp;
              final dt = ts.toDate();
              dateText =
              "${dt.day}/${dt.month}/${dt.year}"; // ví dụ hiển thị dd/mm/yyyy
            } else if (data['date'] != null) {
              dateText = data['date'].toString();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceDetailScreen(place: place),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SizedBox(
                            height: 375,
                            width: double.infinity,
                            child: AnotherCarousel(
                              images: images.map((url) => NetworkImage(url)).toList(),
                              dotSize: 6,
                              indicatorBgPadding: 5,
                              dotBgColor: Colors.transparent,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 15,
                          right: 15,
                          child: Row(
                            children: [
                              data['isActive'] == true
                                  ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  child: Text(
                                    "Ưa thích của khách",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                                  : SizedBox(width: size.width * 0.03),
                              const Spacer(),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.favorite_outline_rounded,
                                    size: 34,
                                    color: Colors.white,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      provider.toggleFavorite(place);
                                    },
                                    child: Icon(
                                      Icons.favorite,
                                      size: 30,
                                      color: provider.isExist(place)
                                          ? Colors.red
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        vendorProfile(place),
                      ],
                    ),
                    SizedBox(height: size.height * 0.01),
                    Row(
                      children: [
                        Text(
                          data['address'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star),
                        const SizedBox(width: 5),
                        Text(
                          (data['rating'] ?? 0).toString(),
                        ),
                      ],
                    ),
                    Text(
                      "Ở cùng ${data['vendor']} . ${data['vendorProfession']}",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16.5,
                      ),
                    ),
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontSize: 16.5,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: size.height * 0.007),
                    RichText(
                      text: TextSpan(
                        text: "\$${data['price'] ?? 0}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: const [
                          TextSpan(
                            text: " / đêm",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Positioned vendorProfile(QueryDocumentSnapshot<Object?> place) {
    final data = place.data() as Map<String, dynamic>;
    return Positioned(
      bottom: 11,
      left: 10,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: Image.asset(
              "asset/images/book_cover.png",
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                data['vendorProfile'] ?? '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
