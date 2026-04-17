// import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
// import 'package:active_ecommerce_cms_demo_app/custom/text_styles.dart';
// import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
// import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
// import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
// import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
// import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
// import 'package:active_ecommerce_cms_demo_app/presenter/cart_counter.dart';
// import 'package:flutter/material.dart';
// import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
// import 'package:provider/provider.dart';

// import '../../custom/cart_seller_item_list_widget.dart';
// import '../../presenter/cart_provider.dart';

// class Cart extends StatefulWidget {
//   Cart(
//       {Key? key,
//       this.has_bottomnav,
//       this.from_navigation = false,
//       this.counter})
//       : super(key: key);
//   final bool? has_bottomnav;
//   final bool from_navigation;
//   final CartCounter? counter;

//   @override
//   _CartState createState() => _CartState();
// }

// class _CartState extends State<Cart> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<CartProvider>(context, listen: false).initState(context);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CartProvider>(builder: (context, cartProvider, _) {
//       return Directionality(
//         textDirection:
//             app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
//         child: Scaffold(
//           key: cartProvider.scaffoldKey,
//           backgroundColor: Color(0xffF2F1F6),
//           appBar: buildAppBar(context),
//           body: Stack(
//             children: [
//               RefreshIndicator(
//                 color: MyTheme.accent_color,
//                 backgroundColor: Colors.white,
//                 onRefresh: () => cartProvider.onRefresh(context),
//                 displacement: 0,
//                 child: CustomScrollView(
//                   controller: cartProvider.mainScrollController,
//                   physics: const BouncingScrollPhysics(
//                       parent: AlwaysScrollableScrollPhysics()),
//                   slivers: [
//                     SliverList(
//                       delegate: SliverChildListDelegate(
//                         [
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//                             child: buildCartSellerList(cartProvider, context),
//                           ),
//                           Container(
//                             height: widget.has_bottomnav! ? 140 : 100,
//                           )
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: buildBottomContainer(cartProvider),
//               )
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Container buildBottomContainer(cartProvider) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color(0xffF2F1F6),
//       ),

//       height: widget.has_bottomnav! ? 200 : 120,
//       //color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
//         child: Column(
//           children: [
//             Container(
//               height: 40,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(6.0),
//                   color: MyTheme.soft_accent_color),
//               child: Row(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     child: Text(
//                       AppLocalizations.of(context)!.total_amount_ucf,
//                       style: TextStyle(
//                           color: MyTheme.dark_font_grey,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700),
//                     ),
//                   ),
//                   Spacer(),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Text(cartProvider.cartTotalString,
//                         style: TextStyle(
//                             color: MyTheme.accent_color,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600)),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Container(
//                     height: 58,
//                     width: (MediaQuery.of(context).size.width - 48),
//                     // width: (MediaQuery.of(context).size.width - 48) * (2 / 3),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(color: MyTheme.accent_color, width: 1),
//                       borderRadius: app_language_rtl.$!
//                           ? const BorderRadius.only(
//                               topLeft: const Radius.circular(6.0),
//                               bottomLeft: const Radius.circular(6.0),
//                               topRight: const Radius.circular(6.0),
//                               bottomRight: const Radius.circular(6.0),
//                             )
//                           : const BorderRadius.only(
//                               topLeft: const Radius.circular(6.0),
//                               bottomLeft: const Radius.circular(6.0),
//                               topRight: const Radius.circular(6.0),
//                               bottomRight: const Radius.circular(6.0),
//                             ),
//                     ),
//                     child: Btn.basic(
//                       minWidth: MediaQuery.of(context).size.width,
//                       color: MyTheme.accent_color,
//                       shape: app_language_rtl.$!
//                           ? RoundedRectangleBorder(
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: const Radius.circular(6.0),
//                                 bottomLeft: const Radius.circular(6.0),
//                                 topRight: const Radius.circular(0.0),
//                                 bottomRight: const Radius.circular(0.0),
//                               ),
//                             )
//                           : RoundedRectangleBorder(
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: const Radius.circular(0.0),
//                                 bottomLeft: const Radius.circular(0.0),
//                                 topRight: const Radius.circular(6.0),
//                                 bottomRight: const Radius.circular(6.0),
//                               ),
//                             ),
//                       child: Text(
//                         AppLocalizations.of(context)!.proceed_to_shipping_ucf,
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700),
//                       ),
//                       onPressed: () {
//                         cartProvider.onPressProceedToShipping(context);
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   AppBar buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Color(0xffF2F1F6),
//       leading: Builder(
//         builder: (context) => widget.from_navigation
//             ? UsefulElements.backToMain(context, go_back: false)
//             : UsefulElements.backButton(context),
//       ),
//       title: Text(
//         AppLocalizations.of(context)!.shopping_cart_ucf,
//         style: TextStyles.buildAppBarTexStyle(),
//       ),
//       elevation: 0.0,
//       titleSpacing: 0,
//       scrolledUnderElevation: 0.0,
//     );
//   }

//   buildCartSellerList(cartProvider, context) {
//     // for guest checkout log in to see cart items is disabled.
//     // if (is_logged_in.$ == false) {
//     //   return Container(
//     //       height: 100,
//     //       child: Center(
//     //           child: Text(
//     //         AppLocalizations.of(context)!.please_log_in_to_see_the_cart_items,
//     //         style: TextStyle(color: MyTheme.font_grey),
//     //       )));
//     // } else
//     if (cartProvider.isInitial && cartProvider.shopList.length == 0) {
//       return SingleChildScrollView(
//           child: ShimmerHelper()
//               .buildListShimmer(item_count: 5, item_height: 100.0));
//     } else if (cartProvider.shopList.length > 0) {
//       return SingleChildScrollView(
//         child: ListView.separated(
//           separatorBuilder: (context, index) => SizedBox(
//             height: 26,
//           ),
//           itemCount: cartProvider.shopList.length,
//           scrollDirection: Axis.vertical,
//           physics: NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           itemBuilder: (context, index) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 14.0),
//                   child: Row(
//                     children: [
//                       Text(
//                         cartProvider.shopList[index].name,
//                         style: TextStyle(
//                             color: MyTheme.dark_font_grey,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12),
//                       ),
//                       Spacer(),
//                       Text(
//                         cartProvider.shopList[index].subTotal.replaceAll(
//                                 SystemConfig.systemCurrency!.code,
//                                 SystemConfig.systemCurrency!.symbol) ??
//                             '',
//                         style: TextStyle(
//                             color: MyTheme.accent_color,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ),
//                 CartSellerItemListWidget(
//                   sellerIndex: index,
//                   cartProvider: cartProvider,
//                   context: context,
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     } else if (!cartProvider.isInitial && cartProvider.shopList.length == 0) {
//       return Container(
//           height: 100,
//           child: Center(
//               child: Text(
//             AppLocalizations.of(context)!.cart_is_empty,
//             style: TextStyle(color: MyTheme.font_grey),
//           )));
//     }
//   }
// }

import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/text_styles.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/cart_counter.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../custom/cart_seller_item_list_widget.dart';
import '../../presenter/cart_provider.dart';

class Cart extends StatefulWidget {
  const Cart({
    super.key,
    this.has_bottomnav,
    this.from_navigation = false,
    this.counter,
  });

  final bool? has_bottomnav;
  final bool from_navigation;
  final CartCounter? counter;

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      // Always fetch fresh cart data when screen loads
      cartProvider.reset(); // Clear previous cart state
      cartProvider.fetchData(context); // Fetch fresh data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cartProvider, _) {
      return Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xffF2F1F6),
          appBar: buildAppBar(context),
          body: Stack(
            children: [
              RefreshIndicator(
                color: MyTheme.accent_color,
                backgroundColor: Colors.white,
                onRefresh: () => cartProvider.onRefresh(context),
                displacement: 0,
                child: CustomScrollView(
                  controller: cartProvider.mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: buildCartSellerList(cartProvider, context),
                          ),
                        Container(
  height: widget.has_bottomnav != null && widget.has_bottomnav!
      ? MediaQuery.of(context).size.height * 0.2
      : 100,
)

                        ],
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: buildBottomContainer(cartProvider),
              ),
            ],
          ),
        ),
      );
    });
  }

  Container buildBottomContainer(CartProvider cartProvider) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffF2F1F6),
      ),
      height: widget.has_bottomnav! ? 200 : 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: MyTheme.soft_accent_color,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      AppLocalizations.of(context)!.total_amount_ucf,
                      style: TextStyle(
                          color: MyTheme.dark_font_grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(cartProvider.cartTotalString,
                        style: const TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    height: 58,
                    width: (MediaQuery.of(context).size.width - 48),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: MyTheme.accent_color, width: 1),
                        borderRadius: app_language_rtl.$!
                            ? BorderRadius.circular(6.0)
                            : BorderRadius.circular(6.0)),
                    child: Btn.basic(
                      minWidth: MediaQuery.of(context).size.width,
                      color: cartProvider.shopList.isNotEmpty
                          ? MyTheme.accent_color
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.proceed_to_shipping_ucf,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: cartProvider.shopList.isNotEmpty
                          ? () => cartProvider.onPressProceedToShipping(context)
                          : null,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xffF2F1F6),
      leading: Builder(
        builder: (context) => widget.from_navigation
            ? UsefulElements.backToMain(context, go_back: false)
            : UsefulElements.backButton(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.shopping_cart_ucf,
        style: TextStyles.buildAppBarTexStyle(),
      ),
      elevation: 0.0,
    );
  }

  Widget buildCartSellerList(CartProvider cartProvider, BuildContext context) {
    if (cartProvider.isInitial && cartProvider.shopList.isEmpty) {
      return ShimmerHelper()
          .buildListShimmer(item_count: 5, item_height: 100.0);
    } else if (cartProvider.shopList.isNotEmpty) {
      return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 26),
        itemCount: cartProvider.shopList.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Row(
                  children: [
                    Text(
                      cartProvider.shopList[index].name,
                      style: TextStyle(
                          color: MyTheme.dark_font_grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      cartProvider.shopList[index].subTotal.replaceAll(
                              SystemConfig.systemCurrency!.code,
                              SystemConfig.systemCurrency!.symbol) ??
                          '',
                      style: const TextStyle(
                          color: MyTheme.accent_color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              CartSellerItemListWidget(
                sellerIndex: index,
                cartProvider: cartProvider,
                context: context,
              ),
            ],
          );
        },
      );
    } else if (!cartProvider.isInitial && cartProvider.shopList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.cart_is_empty,
              style: const TextStyle(color: MyTheme.font_grey),
            ),
          ],
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
