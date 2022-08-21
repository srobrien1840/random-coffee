import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CoffeeImage extends StatelessWidget {
  const CoffeeImage({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
