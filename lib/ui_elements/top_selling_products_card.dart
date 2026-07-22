import 'package:active_ecommerce_cms_demo_app/screens/product/product_details.dart';
import 'package:flutter/material.dart';

import '../helpers/main_helpers.dart';
import '../my_theme.dart';

// ignore: must_be_immutable
class TopSellingProductsCard extends StatefulWidget {
  int? id;
  String slug;
  String? image;
  String? name;
  String? main_price;
  String? stroked_price;
  bool? has_discount;

  TopSellingProductsCard(
      {super.key,
      this.id,
      required this.slug,
      this.image,
      this.name,
      this.main_price,
      this.stroked_price,
      this.has_discount});

  @override
  _TopSellingProductsCardState createState() => _TopSellingProductsCardState();
}

class _TopSellingProductsCardState extends State<TopSellingProductsCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(
            slug: widget.slug,
          );
        }));
      },
      child: Container(
        height: 102,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 0.8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 85,
              height: 102,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(11), right: Radius.zero),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/placeholder.png',
                  image: widget.image ?? 'assets/placeholder.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                          color: Color(0xff1E2022),
                          fontFamily: 'Public Sans',
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          convertPrice(widget.main_price ?? ''),
                          maxLines: 1,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        if (widget.has_discount ?? false) ...[
                          const SizedBox(width: 8),
                          Text(
                            convertPrice(widget.stroked_price ?? ''),
                            maxLines: 1,
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontFamily: 'Public Sans',
                                color: Color(0xffA8AFB3),
                                fontSize: 12,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
