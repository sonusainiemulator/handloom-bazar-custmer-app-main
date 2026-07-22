import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/other_config.dart';
import 'package:active_ecommerce_cms_demo_app/services/google_places_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleReviewsSection extends StatefulWidget {
  final String? title;
  const GoogleReviewsSection({super.key, this.title});

  @override
  State<GoogleReviewsSection> createState() => _GoogleReviewsSectionState();
}

class _GoogleReviewsSectionState extends State<GoogleReviewsSection>
    with SingleTickerProviderStateMixin {
  late Future<PlaceDetails?> _future;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Try placeId first if present; otherwise resolve by address string
    final placeId = OtherConfig.GOOGLE_PLACE_ID;
    final address = OtherConfig.GOOGLE_PLACE_TEXT_QUERY.trim();
    _future = GooglePlacesService.fetchPlaceDetails(
      placeId: placeId.isEmpty ? null : placeId,
      address: (placeId.isEmpty && address.isNotEmpty) ? address : null,
    );
    
    _animationController.forward();
  }



  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (OtherConfig.GOOGLE_PLACE_ID.isEmpty) {
      return const SizedBox.shrink();
    }    
   
 return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 12.0, bottom: 4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MyTheme.accent_color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.reviews_outlined,
                      color: MyTheme.accent_color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title ?? 'What our customers say',
                          style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),          
              const SizedBox(height: 4),
                        Text(
                          'Real reviews from Google',
                          style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            FutureBuilder<PlaceDetails?>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: MyTheme.accent_color,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading reviews...',
                            style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade300,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Unable to load reviews',
                            style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }   
             
                final details = snapshot.data;
                final reviews = details?.reviews ?? [];
                if (reviews.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Enhanced Header with rating only
                final ratingHeader = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber[700], size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${details!.rating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Excellent Rating',
                        style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () async {
                          final url = details.url;
                          if (url.isNotEmpty) {
                            try {
                              await launchUrl(Uri.parse(url));
                            } catch (e) {
                              // Handle error silently
                            }
                          }
                        },
                        icon: Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: MyTheme.accent_color,
                        ), 
                       label: const Text(
                          'View on Google',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: MyTheme.accent_color,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                );

                // Simple Manual Swipe Carousel
                return Column(
                  children: [
                    ratingHeader,
                    const SizedBox(height: 16),
                    
                    // Manual swipe instruction
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swipe_left,
                            color: MyTheme.font_grey,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Swipe to see more reviews',
                            style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${reviews.length} reviews',
                            style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Responsive horizontal ListView with dynamic height
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate responsive dimensions
                        final screenWidth = MediaQuery.of(context).size.width;
                        final screenHeight = MediaQuery.of(context).size.height;
                        final cardWidth = screenWidth * 0.85; // 85% of screen width
                        final cardHeight = screenHeight * 0.20; // 20% of screen height for tight compact cards
                        final minHeight = 150.0; // Tight minimum height
                        final maxHeight = 220.0; // Tight maximum height
                        final finalHeight = cardHeight.clamp(minHeight, maxHeight);
                        
                        return SizedBox(
                          height: finalHeight,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: reviews.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final r = reviews[index];
                              
                              return Container(
                                width: cardWidth.clamp(300.0, 400.0), // Responsive width
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // User info and rating - Fixed height section
                                      SizedBox(
                                        height: 48,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundImage: r.profilePhotoUrl != null
                                                  ? NetworkImage(r.profilePhotoUrl!)
                                                  : null,
                                              backgroundColor: MyTheme.accent_color.withOpacity(0.1),
                                              child: r.profilePhotoUrl == null
                                                  ? Icon(
                                                      Icons.person,
                                                      size: 20,
                                                      color: MyTheme.accent_color,
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    r.authorName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    r.relativeTimeDescription ?? _formatTime(r.time),
                                                    style: TextStyle(
                                                      color: MyTheme.font_grey,
                                                      fontSize: 11,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 6),
                                      
                                      // Star rating - Fixed height section
                                      SizedBox(
                                        height: 24,
                                        child: Row(
                                          children: [
                                            ...List.generate(5, (i) {
                                              final filled = r.rating >= i + 1;
                                              final half = r.rating > i && r.rating < i + 1;
                                              return Icon(
                                                filled
                                                    ? Icons.star
                                                    : half
                                                        ? Icons.star_half
                                                        : Icons.star_border,
                                                color: Colors.amber[600],
                                                size: 18,
                                              );
                                            }),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${r.rating.toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // Review text - Flexible section that adapts to content
                                      Flexible(
                                        child: Container(
                                          width: double.infinity,
                                          constraints: const BoxConstraints(
                                            minHeight: 36, // Compact minimum height
                                            maxHeight: 120, // Maximum height for long reviews
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: SingleChildScrollView(
                                            physics: const BouncingScrollPhysics(),
                                            child: Text(
                                              r.text,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                height: 1.4,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // Bottom info - Fixed height section
                                      Container(
                                        height: 32,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: MyTheme.accent_color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.verified,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Verified Google Review',
                                                style: TextStyle(
                                                  color: MyTheme.accent_color,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return 'Recently';
    
    try {
      final now = DateTime.now();
      final reviewTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      final difference = now.difference(reviewTime);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '${years} year${years > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '${months} month${months > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return 'Recently';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
