import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/middlewares/auth_middleware.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/screens/filter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:active_ecommerce_cms_demo_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:one_context/one_context.dart';

import 'package:provider/provider.dart';
import 'package:shared_value/shared_value.dart';

import 'app_config.dart';
import 'custom/aiz_route.dart';

import 'helpers/main_helpers.dart';
import 'lang_config.dart';
import 'my_theme.dart';
import 'other_config.dart';
import 'presenter/cart_counter.dart';
import 'presenter/cart_provider.dart';
import 'presenter/currency_presenter.dart';
import 'presenter/home_presenter.dart';
import 'presenter/select_address_provider.dart';
import 'presenter/unRead_notification_counter.dart';
import 'providers/blog_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/auction/auction_bidded_products.dart';
import 'screens/auction/auction_products.dart';
import 'screens/auction/auction_products_details.dart';
import 'screens/auction/auction_purchase_history.dart';
import 'screens/auth/registration.dart';
import 'screens/brand_products.dart';
import 'screens/category_list_n_product/category_list.dart';
import 'screens/category_list_n_product/category_products.dart';
import 'screens/checkout/cart.dart';
import 'screens/classified_ads/classified_ads.dart';
import 'screens/classified_ads/classified_product_details.dart';
import 'screens/classified_ads/classified_provider.dart';
import 'screens/classified_ads/my_classified_ads.dart';
import 'screens/coupon/coupons.dart';
import 'screens/flash_deal/flash_deal_list.dart';
import 'screens/flash_deal/flash_deal_products.dart';
import 'screens/followed_sellers.dart';
import 'screens/index.dart';
import 'screens/orders/order_details.dart';
import 'screens/orders/order_list.dart';
import 'screens/package/packages.dart';
import 'screens/product/product_details.dart';
import 'screens/product/todays_deal_products.dart';
import 'screens/profile.dart';
import 'screens/seller_details.dart';
import 'services/push_notification_service.dart';
import 'single_banner/photo_provider.dart';

void main() async {
  // Wrap everything in error handling
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      // Continue app execution even if Firebase fails
    }
    
    // Initialize Flutter Downloader with error handling
    if (!kIsWeb) {
      try {
        await FlutterDownloader.initialize(
          debug: false, // Set to false in production to reduce logs
          ignoreSsl: true,
        );
        print('FlutterDownloader initialized successfully');
      } catch (e) {
        print('FlutterDownloader initialization error: $e');
        // Continue app execution
      }
    }
    
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    runApp(SharedValue.wrapApp(MyApp()));
  }, (error, stackTrace) {
    print('Uncaught error: $error');
    print('Stack trace: $stackTrace');
  });
}

var routes = GoRouter(
  overridePlatformDefaultLocation: false,
  navigatorKey: OneContext().key,
  initialLocation: "/",
  routes: [
    GoRoute(
      path: '/',
      name: "Home",
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              MaterialPage(child: Index()),
      routes: [
        GoRoute(
          path: "customer_products",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: MyClassifiedAds()),
        ),
        GoRoute(
          path: "customer-products",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: ClassifiedAds()),
        ),
        GoRoute(
          path: "customer-product/:slug",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: ClassifiedAdsDetails(slug: getParameter(state, "slug")),
              ),
        ),
        GoRoute(
          path: "product/:slug",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: ProductDetails(slug: getParameter(state, "slug")),
              ),
        ),
        GoRoute(
          path: "customer-packages",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: UpdatePackage()),
        ),
        GoRoute(
          path: "auction_product_bids",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: AuthMiddleware(AuctionBiddedProducts()).next(),
              ),
        ),
        GoRoute(
          path: "users/login",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: Login()),
        ),
        GoRoute(
          path: "users/registration",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: Registration()),
        ),
        GoRoute(
          path: "dashboard",
          name: "Profile",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  AIZRoute.rightTransition(Profile()),
        ),
        GoRoute(
          path: "auction-products",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: AuctionProducts()),
        ),
        GoRoute(
          path: "auction-product/:slug",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: AuctionProductsDetails(
                  slug: getParameter(state, "slug"),
                ),
              ),
        ),
        GoRoute(
          path: "auction/purchase_history",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: AuthMiddleware(AuctionPurchaseHistory()).next(),
              ),
        ),
        GoRoute(
          path: "brand/:slug",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: (BrandProducts(slug: getParameter(state, "slug"))),
              ),
        ),
        GoRoute(
          path: "brands",
          name: "Brands",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: Filter(selected_filter: "brands")),
        ),
        GoRoute(
          path: "cart",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: AuthMiddleware(Cart()).next()),
        ),
        GoRoute(
          path: "categories",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: (CategoryList(slug: getParameter(state, "slug"))),
              ),
        ),
        GoRoute(
          path: "category/:slug",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: (CategoryProducts(slug: getParameter(state, "slug"))),
              ),
        ),
        GoRoute(
          path: "flash-deals",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: (FlashDealList())),
        ),
        GoRoute(
          path: "flash-deal/:slug",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: (FlashDealProducts(slug: getParameter(state, "slug"))),
              ),
        ),
        GoRoute(
          path: "followed-seller",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: (FollowedSellers())),
        ),
        GoRoute(
          path: "purchase_history",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: (OrderList())),
        ),
        GoRoute(
          path: "purchase_history/details/:id",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: (OrderDetails(id: int.parse(getParameter(state, "id")))),
              ),
        ),
        GoRoute(
          path: "sellers",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: (Filter(selected_filter: "sellers"))),
        ),
        GoRoute(
          path: "shop/:slug",
          pageBuilder:
              (BuildContext context, GoRouterState state) => MaterialPage(
                child: (SellerDetails(slug: getParameter(state, "slug"))),
              ),
        ),
        GoRoute(
          path: "todays-deal",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: (TodaysDealProducts())),
        ),
        GoRoute(
          path: "coupons",
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: (Coupons())),
        ),
      ],
    ),
  ],
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize push notifications asynchronously without blocking
    _initializePushNotifications();
  }

  Future<void> _initializePushNotifications() async {
    try {
      if (OtherConfig.USE_PUSH_NOTIFICATION) {
        await Future.delayed(Duration(milliseconds: 500)); // Small delay
        PushNotificationService().initialise();
      }
    } catch (e) {
      print('Push notification initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => CartCounter()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => SelectAddressProvider()),
        ChangeNotifierProvider(
          create: (context) => UnReadNotificationCounter(),
        ),
        ChangeNotifierProvider(create: (context) => CurrencyPresenter()),
        ChangeNotifierProvider(create: (_) => HomePresenter()),
        ChangeNotifierProvider(create: (_) => BlogProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => MyClassifiedProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, provider, snapshot) {
          return MaterialApp.router(
            routerConfig: routes,
            title: AppConfig.app_name,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: MyTheme.white,
              scaffoldBackgroundColor: MyTheme.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: "PublicSansSerif",
              textTheme: MyTheme.textTheme1,
              fontFamilyFallback: ['NotoSans'],
              scrollbarTheme: ScrollbarThemeData(
                thumbVisibility: WidgetStateProperty.all<bool>(false),
              ),
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            locale: provider.locale,
            supportedLocales: LangConfig().supportedLocales(),
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (deviceLocale != null && 
                  AppLocalizations.delegate.isSupported(deviceLocale)) {
                return deviceLocale;
              }
              return const Locale('en');
            },
          );
        },
      ),
    );
  }
}
