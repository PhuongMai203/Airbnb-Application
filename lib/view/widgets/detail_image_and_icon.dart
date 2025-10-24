import 'package:airbnb_app/Components/my_icon_button.dart';
import 'package:flutter/material.dart';

class DetailImageAndIcon extends StatelessWidget {
  final dynamic place;
  final dynamic provider;

  const DetailImageAndIcon({super.key, required this.place, required this.provider});

  @override
  Widget build(BuildContext context) {
    final imageUrl = place['image'] ?? '';
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        SizedBox(
          height: size.height * 0.35,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
              ),
            ),
          ),
        ),
        Positioned(
          top: 25,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const MyIconButton(icon: Icons.arrow_back_ios_new),
                ),
                const Spacer(),
                const MyIconButton(icon: Icons.share_outlined),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () => provider.toggleFavorite(place),
                  child: MyIconButton(
                    icon: provider.isExist(place)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    iconColor:
                    provider.isExist(place) ? Colors.red : Colors.black,
                  ),
                ),
              ],
            )

          ),
        ),
      ],
    );
  }
}
