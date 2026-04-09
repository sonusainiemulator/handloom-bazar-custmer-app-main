import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'photo_provider.dart'; // Path to your provider file

class PhotoWidget extends StatelessWidget {
  const PhotoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<PhotoProvider>(context, listen: false).fetchPhotos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerHelper()
              .buildBasicShimmer(height: 50); // Show shimmer while loading
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading photos')); // Handle API call errors
        }

        return Consumer<PhotoProvider>(
          builder: (context, photoProvider, child) {
            if (photoProvider.singleBanner.isEmpty) {
              return Center(
                  child: Text('No photos available.')); // No photos fallback
            }

            final photoData = photoProvider.singleBanner[0];

            return GestureDetector(
              onTap: () async {
                final url = photoData.url;
                if (url.isNotEmpty) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    throw 'Could not launch $url';
                  }
                } else {
                  print('URL is empty');
                }
              },
              child: Image.network(photoData.photo),
            );
          },
        );
      },
    );
  }
}
