import 'package:active_ecommerce_cms_demo_app/helpers/addons_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/business_setting_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/currency_presenter.dart';
import 'package:active_ecommerce_cms_demo_app/providers/locale_provider.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:active_ecommerce_cms_demo_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Index extends StatefulWidget {
  Index({super.key, this.goBack = true});
  bool? goBack;

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  Future<String?> getSharedValueHelperData() async {
    try {
      // Load access token asynchronously
      await access_token.load();
      
      // Fetch auth data in background
      AuthHelper().fetch_and_set();
      
      // Load all data in parallel to speed up loading
      await Future.wait<void>([
        AddonsHelper().setAddonsData().then((_) {}),
        BusinessSettingHelper().setBusinessSettingData().then((_) {}),
        app_language.load().then((_) {}),
        app_mobile_language.load().then((_) {}),
        app_language_rtl.load().then((_) {}),
        system_currency.load().then((_) {}),
      ]);
      
      // Fetch currency data
      if (mounted) {
        Provider.of<CurrencyPresenter>(context, listen: false).fetchListData();
      }

      return app_mobile_language.$;
    } catch (e) {
      print('Error loading shared value helper data: $e');
      _errorMessage = e.toString();
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final language = await getSharedValueHelperData();
      
      // Reduced splash delay from 3s to 1s
      await Future.delayed(Duration(seconds: 1));
      
      if (mounted) {
        SystemConfig.isShownSplashScreed = true;
        
        if (language != null) {
          Provider.of<LocaleProvider>(context, listen: false)
              .setLocale(language);
        }
        
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemConfig.context ??= context;
    
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Failed to load app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage ?? 'Unknown error',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = true;
                  });
                  _initializeApp();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      body: _isLoading
          ? SplashScreen()
          : Main(go_back: widget.goBack!),
    );
  }
}
