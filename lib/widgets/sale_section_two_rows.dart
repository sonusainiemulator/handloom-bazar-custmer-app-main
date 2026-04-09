import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../single_banner/photo_provider.dart';

class SaleSectionTwoRows extends StatelessWidget {
  const SaleSectionTwoRows({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<PhotoProvider>(context, listen: false).fetchPhotos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
            child: Column(
              children: [
                ShimmerHelper().buildBasicShimmer(height: 120),
                SizedBox(height: 12),
                ShimmerHelper().buildBasicShimmer(height: 120),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox.shrink();
        }

        return Consumer<PhotoProvider>(
          builder: (context, photoProvider, child) {
            if (photoProvider.singleBanner.isEmpty) {
              return SizedBox.shrink();
            }

            final photoData = photoProvider.singleBanner[0];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
              child: Column(
                children: [
                  // First Row - Two equal columns
                  Row(
                    children: [
                      Expanded(
                        child: _buildSaleCard(
                          context,
                          photoData.photo,
                          photoData.url,
                          'SUPER SALE',
                          'SHOPPING NOW',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildSaleCard(
                          context,
                          photoData.photo,
                          photoData.url,
                          'HOT SALE',
                          'SAREE',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Second Row - Two equal columns
                  Row(
                    children: [
                      Expanded(
                        child: _buildSaleCard(
                          context,
                          photoData.photo,
                          photoData.url,
                          'MEGA SALE',
                          'DRESS MATERIAL',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildSaleCard(
                          context,
                          photoData.photo,
                          photoData.url,
                          'BIG SALE',
                          'MEN\'S WEAR',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSaleCard(
    BuildContext context,
    String imageUrl,
    String targetUrl,
    String title,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () async {
        if (targetUrl.isNotEmpty) {
          final uri = Uri.parse(targetUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xffE91E63),
                          Color(0xffF06292),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Text content
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xffE91E63),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'VISIT NOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
