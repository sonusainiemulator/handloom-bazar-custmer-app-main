import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchasedDigitalProductCard extends StatefulWidget
    with WidgetsBindingObserver {
  final int? id;
  final String? image;
  final String? name;

  PurchasedDigitalProductCard({super.key, this.id, this.image, this.name});

  @override
  _PurchasedDigitalProductCardState createState() =>
      _PurchasedDigitalProductCardState();
}

class _PurchasedDigitalProductCardState
    extends State<PurchasedDigitalProductCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: SizedBox(
              width: double.infinity,
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(10),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/placeholder.png',
                  image: widget.image ?? 'assets/placeholder.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
            child: Text(
              widget.name ?? 'No name',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                color: Color(0xff6B7377),
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          InkWell(
            onTap: requestDownload,
            child: Container(
              height: 24,
              width: 170,
              margin: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Color(0xffE5411C),
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Center(
                child: Text(
                  'Download',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> requestDownload() async {
    final uri = Uri.parse(
      '${AppConfig.BASE_URL}/purchased-products/download/${widget.id}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      ToastComponent.showDialog("Unable to open download link.");
    }
  }
}
