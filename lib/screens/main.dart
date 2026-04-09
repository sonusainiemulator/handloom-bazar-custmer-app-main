import 'dart:io';

import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/main.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/bottom_appbar_index.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/cart_counter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/category_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/checkout/cart.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home.dart';
import 'package:active_ecommerce_cms_demo_app/screens/profile.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class Main extends StatefulWidget {
  Main({super.key, this.go_back = true}); // Not const
  late final bool go_back;
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  late final List<Widget> _children;
  final CartCounter counter = CartCounter();
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();

    _children = [
      Home(),
      CategoryList(slug: "", is_base_category: true),
      Cart(
        has_bottomnav: true,
        from_navigation: true,
        counter: counter,
      ),
      Profile(),
    ];

    // Reappear status bar in case it was not visible on the previous page
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAll();
    });
  }

  void fetchAll() {
    getCartCount();
  }

  void getCartCount() {
    Provider.of<CartCounter>(context, listen: false).getCount();
  }

  void onTapped(int i) {
    if (guest_checkout_status.$ && i == 2) {
      // Handle guest checkout
    } else if (!guest_checkout_status.$ && i == 2 && !is_logged_in.$) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
      return;
    }

    if (i == 3) {
      routes.push("/dashboard");
      return;
    }

    _currentIndex.value = i;
  }

  Future<bool> willPop() async {
    if (_currentIndex.value != 0) {
      _currentIndex.value = 0;
    } else {
      if (_dialogShowing) {
        return Future.value(false); // Dialog already showing
      }

      setState(() {
        _dialogShowing = true;
      });

      final shouldPop = (await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Directionality(
                textDirection:
                    app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
                child: AlertDialog(
                  content: Text(
                      AppLocalizations.of(context)!.do_you_want_close_the_app),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Platform.isAndroid ? SystemNavigator.pop() : exit(0);
                      },
                      child: Text(AppLocalizations.of(context)!.yes_ucf),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(AppLocalizations.of(context)!.no_ucf),
                    ),
                  ],
                ),
              );
            },
          )) ??
          false;

      setState(() {
        _dialogShowing = false;
      });

      return shouldPop;
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPop,
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          extendBody: true,
          body: ValueListenableBuilder<int>(
            valueListenable: _currentIndex,
            builder: (context, index, _) {
              return _children[index];
            },
          ),
      bottomNavigationBar: LayoutBuilder(
  builder: (context, constraints) {
    return SizedBox(
      height: 70,
      child: ValueListenableBuilder<int>(
        valueListenable: _currentIndex,
        builder: (context, currentIndex, _) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: onTapped,
            currentIndex: currentIndex,  // Use the listenable value
            backgroundColor: Colors.white.withOpacity(0.95),
            unselectedItemColor: const Color.fromRGBO(168, 175, 179, 1),
            selectedItemColor: MyTheme.accent_color,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.asset(
                    "assets/home.png",
                    color: currentIndex == 0
                        ? MyTheme.accent_color
                        : const Color.fromRGBO(153, 153, 153, 1),
                    height: 16,
                  ),
                ),
                label: AppLocalizations.of(context)!.home_ucf,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.asset(
                    "assets/categories.png",
                    color: currentIndex == 1
                        ? MyTheme.accent_color
                        : const Color.fromRGBO(153, 153, 153, 1),
                    height: 16,
                  ),
                ),
                label: AppLocalizations.of(context)!.categories_ucf,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: badges.Badge(
                    badgeStyle: badges.BadgeStyle(
                      shape: badges.BadgeShape.circle,
                      badgeColor: MyTheme.accent_color,
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.all(5),
                    ),
                    badgeContent: Builder(
                      builder: (context) {
                        final count = Provider.of<CartCounter>(context).cartCounter;
                        return Text(
                          "$count",
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        );
                      },
                    ),
                    child: Image.asset(
                      "assets/cart.png",
                      color: currentIndex == 2
                          ? MyTheme.accent_color
                          : const Color.fromRGBO(153, 153, 153, 1),
                      height: 16,
                    ),
                  ),
                ),
                label: AppLocalizations.of(context)!.cart_ucf,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.asset(
                    "assets/profile.png",
                    color: currentIndex == 3
                        ? MyTheme.accent_color
                        : const Color.fromRGBO(153, 153, 153, 1),
                    height: 16,
                  ),
                ),
                label: AppLocalizations.of(context)!.profile_ucf,
              ),
            ],
          );
        },
      ),
    );
  },
),

        ),
      ),
    );
  }
}
