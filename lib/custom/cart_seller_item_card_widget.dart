import 'package:flutter/material.dart';

import '../helpers/system_config.dart';
import '../my_theme.dart';
import '../presenter/cart_provider.dart';
import 'box_decorations.dart';
import 'device_info.dart';

class CartSellerItemCardWidget extends StatelessWidget {
  final int sellerIndex;
  final int itemIndex;
  final CartProvider cartProvider;

  const CartSellerItemCardWidget(
      {super.key,
      required this.cartProvider,
      required this.sellerIndex,
      required this.itemIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
                width: DeviceInfo(context).width! / 4,
                height: 120,
                child: ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(6), right: Radius.zero),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: cartProvider.shopList[sellerIndex]
                          .cartItems[itemIndex].productThumbnailImage,
                      fit: BoxFit.contain,
                    ))),
            SizedBox(
              //color: Colors.red,
              width: DeviceInfo(context).width! / 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cartProvider.shopList[sellerIndex].cartItems[itemIndex]
                          .productName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 23.0),
                      child: Row(
                        children: [
                          Text(
                            SystemConfig.systemCurrency != null
                                ? cartProvider.shopList[sellerIndex]
                                    .cartItems[itemIndex].price
                                    .replaceAll(
                                        SystemConfig.systemCurrency!.code,
                                        SystemConfig.systemCurrency!.symbol)
                                : cartProvider.shopList[sellerIndex]
                                    .cart_items[itemIndex].price,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ////////////////////////////////////////////////
                  GestureDetector(
                    onTap: () async {
                      cartProvider.onPressDelete(
                        context,
                        cartProvider
                            .shopList[sellerIndex].cartItems[itemIndex].id
                            .toString(),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: Image.asset(
                        'assets/trash.png',
                        height: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (cartProvider.shopList[sellerIndex]
                              .cartItems[itemIndex].auctionProduct ==
                          0) {
                        cartProvider.onQuantityIncrease(
                            context, sellerIndex, itemIndex);
                      }
                      return;
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.add,
                        color: cartProvider.shopList[sellerIndex]
                                    .cartItems[itemIndex].auctionProduct ==
                                0
                            ? MyTheme.accent_color
                            : MyTheme.grey_153,
                        size: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      cartProvider
                          .shopList[sellerIndex].cartItems[itemIndex].quantity
                          .toString(),
                      style:
                          TextStyle(color: MyTheme.accent_color, fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (cartProvider.shopList[sellerIndex]
                              .cartItems[itemIndex].auctionProduct ==
                          0) {
                        cartProvider.onQuantityDecrease(
                            context, sellerIndex, itemIndex);
                      }
                      return;
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.remove,
                        color: cartProvider.shopList[sellerIndex]
                                    .cartItems[itemIndex].auctionProduct ==
                                0
                            ? MyTheme.accent_color
                            : MyTheme.grey_153,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
    );
  }
}
