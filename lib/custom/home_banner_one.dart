import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../app_config.dart';
import '../helpers/shimmer_helper.dart';
import '../my_theme.dart';
import '../presenter/home_presenter.dart';
import 'aiz_image.dart';

class HomeBannerOne extends StatefulWidget {
  final HomePresenter? homeData;
  final BuildContext? context;

  const HomeBannerOne({super.key, this.homeData, this.context});

  @override
  State<HomeBannerOne> createState() => _HomeBannerOneState();
}

class _HomeBannerOneState extends State<HomeBannerOne> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentPage = 0;

  Widget _buildBannerItem(dynamic banner, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0xff000000).withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            var url = banner.url?.split(AppConfig.DOMAIN_PATH).last;
            if (url != null && url.isNotEmpty) {
              GoRouter.of(context).go(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Invalid URL'),
              ));
            }
          },
          child: AIZImage.radiusImage(banner.photo, 6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Null safety check for homeData
    if (widget.homeData == null) {
      return SizedBox(
        height: 100,
        child: Center(child: Text('No data available')),
      );
    }

    // When data is loading and no images are available
    if (widget.homeData!.isBannerOneInitial &&
        widget.homeData!.bannerOneImageList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: ShimmerHelper().buildBasicShimmer(height: 250),
      );
    }

    // When banner images are available - Auto-sliding carousel
    else if (widget.homeData!.bannerOneImageList.isNotEmpty) {
      // Group banners into pages of 6 (2 rows x 3 columns)
      final allBanners = widget.homeData!.bannerOneImageList;
      final List<List<dynamic>> pages = [];

      for (int i = 0; i < allBanners.length; i += 6) {
        pages.add(allBanners.skip(i).take(6).toList());
      }

      return Column(
        children: [
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              // Keep enough vertical space for 2x120 cards + row gap + page padding.
              height: 268,
              viewportFraction: 1.0,
              enableInfiniteScroll: pages.length > 1,
              autoPlay: pages.length > 1,
              autoPlayInterval: Duration(seconds: 4),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
            items: pages.map((pageBanners) {
              final firstRow = pageBanners.take(3).toList();
              final secondRow = pageBanners.skip(3).take(3).toList();

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
                child: Column(
                  children: [
                    // First Row - 3 columns
                    if (firstRow.isNotEmpty)
                      Row(
                        children: firstRow.asMap().entries.map((entry) {
                          final index = entry.key;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index < firstRow.length - 1 ? 8 : 0,
                              ),
                              child: SizedBox(
                                height: 120,
                                child: _buildBannerItem(entry.value, context),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    // Spacing between rows
                    if (firstRow.isNotEmpty && secondRow.isNotEmpty)
                      SizedBox(height: 8),

                    // Second Row - 3 columns
                    if (secondRow.isNotEmpty)
                      Row(
                        children: secondRow.asMap().entries.map((entry) {
                          final index = entry.key;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index < secondRow.length - 1 ? 8 : 0,
                              ),
                              child: SizedBox(
                                height: 120,
                                child: _buildBannerItem(entry.value, context),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),

          // Page indicators
          if (pages.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pages.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == entry.key
                        ? MyTheme.accent_color
                        : Colors.grey.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
        ],
      );
    }

    // When images are not found and loading is complete
    else if (!widget.homeData!.isBannerOneInitial &&
        widget.homeData!.bannerOneImageList.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    }

    // Default container if no condition matches
    else {
      return Container(height: 100);
    }
  }
}
