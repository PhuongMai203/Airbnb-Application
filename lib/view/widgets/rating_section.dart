import 'package:airbnb_app/Components/star_rating.dart';
import 'package:flutter/material.dart';

class RatingSection extends StatelessWidget {
  final dynamic place;
  const RatingSection({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    if (place["isActive"] == true) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  "${place['rating'] ?? 0}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                StarRating(rating: (place['rating'] ?? 0).toDouble()),

              ],
            ),
            Stack(
              children: [
                Image.network(
                  "https://wallpapers.com/images/hd/golden-laurel-wreathon-teal-background-k5791qxis5rtcx7w-k5791qxis5rtcx7w.png",
                  height: 50,
                  width: 130,
                  color: Colors.amber,
                ),
                const Positioned(
                  left: 35,
                  child: Text(
                    "Guest\nfavorite",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "${place['review'] ?? 0}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const Text(
                  "Reviews",
                  style: TextStyle(
                    height: 0.7,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          children: [
            const Icon(Icons.star),
            const SizedBox(width: 5),
            Text(
              "${place['rating'] ?? 0} . ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              "${place['review'] ?? 0} reviews",
              style: const TextStyle(
                fontSize: 17,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      );
    }
  }
}
