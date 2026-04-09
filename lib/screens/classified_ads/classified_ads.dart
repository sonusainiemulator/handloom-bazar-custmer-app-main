import 'package:active_ecommerce_cms_demo_app/custom/lang_text.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/classified_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../repositories/classified_product_repository.dart';
//
// class ClassifiedAds extends StatefulWidget {
//   ClassifiedAds({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _ClassifiedAdsState createState() => _ClassifiedAdsState();
// }
//
// class _ClassifiedAdsState extends State<ClassifiedAds> {
//   ScrollController _mainScrollController = ScrollController();
//
//   //init
//   bool _dataFetch = false;
//   dynamic _classifiedProducts = [];
//   int page = 1;
//
//   @override
//   void initState() {
//     fetchData();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _mainScrollController.dispose();
//     super.dispose();
//   }
//
//   reset() {
//     _dataFetch = false;
//     _classifiedProducts.clear();
//     setState(() {});
//   }
//
//   fetchData() async {
//     var classifiedProductRes =
//         await ClassifiedProductRepository().getClassifiedProducts(page: page);
//
//     _classifiedProducts.addAll(classifiedProductRes.data);
//     _dataFetch = true;
//     setState(() {});
//   }
//
//   Future<void> _onPageRefresh() async {
//     reset();
//     fetchData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection:
//           app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
//       child: Scaffold(
//         backgroundColor: MyTheme.mainColor,
//         appBar: buildAppBar(context),
//         body: body(),
//       ),
//     );
//   }
//
//   bool? shouldProductBoxBeVisible(product_name, search_key) {
//     if (search_key == "") {
//       return true; //do not check if the search key is empty
//     }
//     return StringHelper().stringContains(product_name, search_key);
//   }
//
//   AppBar buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: MyTheme.mainColor,
//       scrolledUnderElevation: 0.0,
//       centerTitle: false,
//       leading: UsefulElements.backButton(context),
//       title: Text(
//         AppLocalizations.of(context)!.classified_ads_ucf,
//         style: TextStyle(
//             fontSize: 16,
//             color: MyTheme.dark_font_grey,
//             fontWeight: FontWeight.bold),
//       ),
//       elevation: 0.0,
//       titleSpacing: 0,
//     );
//   }
//
//   Widget body() {
//     if (!_dataFetch) {
//       return ShimmerHelper()
//           .buildProductGridShimmer(scontroller: _mainScrollController);
//     }
//
//     if (_classifiedProducts.length == 0) {
//       return Center(
//         child: Text(LangText(context).local.no_data_is_available),
//       );
//     }
//     return RefreshIndicator(
//       onRefresh: _onPageRefresh,
//       child: SingleChildScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         child: MasonryGridView.count(
//           crossAxisCount: 2,
//           mainAxisSpacing: 14,
//           crossAxisSpacing: 14,
//           itemCount: _classifiedProducts.length,
//           shrinkWrap: true,
//           padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
//           physics: NeverScrollableScrollPhysics(),
//           itemBuilder: (context, index) {
//             // 3
//             return ClassifiedAdsCard(
//               id: _classifiedProducts[index].id,
//               slug: _classifiedProducts[index].slug,
//               image: _classifiedProducts[index].thumbnailImage,
//               name: _classifiedProducts[index].name,
//               unit_price: _classifiedProducts[index].unitPrice,
//               condition: _classifiedProducts[index].condition,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class ClassifiedAds extends StatefulWidget {
//   ClassifiedAds({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _ClassifiedAdsState createState() => _ClassifiedAdsState();
// }
//
// class _ClassifiedAdsState extends State<ClassifiedAds> {
//   ScrollController _mainScrollController = ScrollController();
//
//   //init
//   bool _dataFetch = false;
//   dynamic _classifiedProducts = [];
//   int page = 1;
//   bool _showSearchBar = false;
//   String _searchQuery = "";
//
//   @override
//   void initState() {
//     fetchData();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _mainScrollController.dispose();
//     super.dispose();
//   }
//
//   reset() {
//     _dataFetch = false;
//     _classifiedProducts.clear();
//     setState(() {});
//   }
//
//   fetchData() async {
//     var classifiedProductRes =
//     await ClassifiedProductRepository().getClassifiedProducts(page: page);
//
//     _classifiedProducts.addAll(classifiedProductRes.data);
//     _dataFetch = true;
//     setState(() {});
//   }
//
//   Future<void> _onPageRefresh() async {
//     reset();
//     fetchData();
//   }
//
//   void _toggleSearchBar() {
//     setState(() {
//       _showSearchBar = !_showSearchBar;
//       if (!_showSearchBar) {
//         _searchQuery = ""; // Clear search query when hiding the search bar
//       }
//     });
//   }
//
//   void _onSearchTextChanged(String text) {
//     setState(() {
//       _searchQuery = text;
//     });
//   }
//
//   List<dynamic> getFilteredProducts() {
//     if (_searchQuery.isEmpty) {
//       return _classifiedProducts; // Return all products if the search query is empty
//     } else {
//       return _classifiedProducts.where((product) {
//         // Ensure the product name is a String and check if it contains the search query
//         return product.name.toString().toLowerCase().contains(_searchQuery.toLowerCase());
//       }).toList(); // Convert the filtered iterable to a list
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection:
//       app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
//       child: Scaffold(
//         backgroundColor: MyTheme.mainColor,
//         appBar: buildAppBar(context),
//         body: body(),
//       ),
//     );
//   }
//
//   AppBar buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: MyTheme.mainColor,
//       scrolledUnderElevation: 0.0,
//       centerTitle: false,
//       leading: UsefulElements.backButton(context),
//       title: _showSearchBar
//           ? Material(
//         color: Colors.white, // Background color of the search bar
//         borderRadius: BorderRadius.circular(8), // Rounded corners
//         child: TextField(
//           autofocus: true,
//           autocorrect: false, // Disable spell check
//           enableSuggestions: false, // Disable word suggestions
//           textCapitalization: TextCapitalization.none, // Avoid unwanted capitalization
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             hintStyle: TextStyle(color: Colors.black),
//             filled: true,
//             fillColor: Colors.transparent,
//             border: InputBorder.none,
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide.none,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//           ),
//           style: TextStyle(color: Colors.green),
//           onChanged: _onSearchTextChanged,
//         )
//
//       )
//           : Text(
//         AppLocalizations.of(context)!.classified_ads_ucf,
//         style: TextStyle(
//             fontSize: 16,
//             color: MyTheme.dark_font_grey,
//             fontWeight: FontWeight.bold),
//       ),
//       elevation: 0.0,
//       titleSpacing: 0,
//       actions: [
//         IconButton(
//           icon: Icon(_showSearchBar ? Icons.close : Icons.search),
//           onPressed: _toggleSearchBar,
//         ),
//       ],
//     );
//   }
//
//
//
//   Widget body() {
//     if (!_dataFetch) {
//       return ShimmerHelper()
//           .buildProductGridShimmer(scontroller: _mainScrollController);
//     }
//
//     if (_classifiedProducts.length == 0) {
//       return Center(
//         child: Text(LangText(context).local.no_data_is_available),
//       );
//     }
//
//     final filteredProducts = getFilteredProducts();
//
//     return RefreshIndicator(
//       onRefresh: _onPageRefresh,
//       child: SingleChildScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         child: MasonryGridView.count(
//           crossAxisCount: 2,
//           mainAxisSpacing: 14,
//           crossAxisSpacing: 14,
//           itemCount: filteredProducts.length,
//           shrinkWrap: true,
//           padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
//           physics: NeverScrollableScrollPhysics(),
//           itemBuilder: (context, index) {
//             return ClassifiedAdsCard(
//               id: filteredProducts[index].id,
//               slug: filteredProducts[index].slug,
//               image: filteredProducts[index].thumbnailImage,
//               name: filteredProducts[index].name,
//               unit_price: filteredProducts[index].unitPrice,
//               condition: filteredProducts[index].condition,
//             );
//           },
//         ),
//       ),
//     );
//   }
//}
//
// class ClassifiedAds extends StatefulWidget {
//   ClassifiedAds({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _ClassifiedAdsState createState() => _ClassifiedAdsState();
// }
//
// class _ClassifiedAdsState extends State<ClassifiedAds> {
//   ScrollController _mainScrollController = ScrollController();
//
//   //init
//   bool _dataFetch = false;
//   dynamic _classifiedProducts = [];
//   int page = 1;
//   bool _showSearchBar = false;
//   String _searchQuery = "";
//
//   @override
//   void initState() {
//     fetchData();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _mainScrollController.dispose();
//     super.dispose();
//   }
//
//   reset() {
//     _dataFetch = false;
//     _classifiedProducts.clear();
//     setState(() {});
//   }
//
//   fetchData() async {
//     var classifiedProductRes =
//     await ClassifiedProductRepository().getClassifiedProducts(page: page);
//
//     _classifiedProducts.addAll(classifiedProductRes.data);
//     _dataFetch = true;
//     setState(() {});
//   }
//
//   Future<void> _onPageRefresh() async {
//     reset();
//     fetchData();
//   }
//
//   void _toggleSearchBar() {
//     setState(() {
//       _showSearchBar = !_showSearchBar;
//       if (!_showSearchBar) {
//         _searchQuery = ""; // Clear search query when hiding the search bar
//       }
//     });
//   }
//
//   void _onSearchTextChanged(String text) {
//     setState(() {
//       _searchQuery = text;
//     });
//   }
//
//   List<dynamic> getFilteredProducts() {
//     if (_searchQuery.isEmpty) {
//       return _classifiedProducts; // Return all products if the search query is empty
//     } else {
//       return _classifiedProducts.where((product) {
//         // Ensure the product name is a String and check if it contains the search query
//         return product.name.toString().toLowerCase().contains(_searchQuery.toLowerCase());
//       }).toList(); // Convert the filtered iterable to a list
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection:
//       app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
//       child: Scaffold(
//         backgroundColor: MyTheme.mainColor,
//         appBar: buildAppBar(context),
//         body: body(),
//       ),
//     );
//   }
//
//   AppBar buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: MyTheme.mainColor,
//       scrolledUnderElevation: 0.0,
//       centerTitle: false,
//       leading: UsefulElements.backButton(context),
//       title: _showSearchBar
//           ? Material(
//           color: Colors.white, // Background color of the search bar
//           borderRadius: BorderRadius.circular(8), // Rounded corners
//           child: TextField(
//             autofocus: true,
//             autocorrect: false, // Disable spell check
//             enableSuggestions: false, // Disable word suggestions
//             textCapitalization: TextCapitalization.none, // Avoid unwanted capitalization
//             decoration: InputDecoration(
//               hintText: 'Search...',
//               hintStyle: TextStyle(color: Colors.black),
//               filled: true,
//               fillColor: Colors.transparent,
//               border: InputBorder.none,
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide.none,
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//             ),
//             style: TextStyle(color: Colors.green),
//             onChanged: _onSearchTextChanged,
//           )
//
//       )
//           : Text(
//         AppLocalizations.of(context)!.classified_ads_ucf,
//         style: TextStyle(
//             fontSize: 16,
//             color: MyTheme.dark_font_grey,
//             fontWeight: FontWeight.bold),
//       ),
//       elevation: 0.0,
//       titleSpacing: 0,
//       actions: [
//         IconButton(
//           icon: Icon(_showSearchBar ? Icons.close : Icons.search),
//           onPressed: _toggleSearchBar,
//         ),
//       ],
//     );
//   }
//
//
//
//   Widget body() {
//     if (!_dataFetch) {
//       return ShimmerHelper()
//           .buildProductGridShimmer(scontroller: _mainScrollController);
//     }
//
//     if (_classifiedProducts.length == 0) {
//       return Center(
//         child: Text(LangText(context).local.no_data_is_available),
//       );
//     }
//
//     final filteredProducts = getFilteredProducts();
//
//     return RefreshIndicator(
//       onRefresh: _onPageRefresh,
//       child: SingleChildScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         child: MasonryGridView.count(
//           crossAxisCount: 2,
//           mainAxisSpacing: 14,
//           crossAxisSpacing: 14,
//           itemCount: filteredProducts.length,
//           shrinkWrap: true,
//           padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
//           physics: NeverScrollableScrollPhysics(),
//           itemBuilder: (context, index) {
//             return ClassifiedAdsCard(
//               id: filteredProducts[index].id,
//               slug: filteredProducts[index].slug,
//               image: filteredProducts[index].thumbnailImage,
//               name: filteredProducts[index].name,
//               unit_price: filteredProducts[index].unitPrice,
//               condition: filteredProducts[index].condition,
//             );
//           },
//         ),
//       ),
//     );
//   }}


 class ClassifiedAds extends StatefulWidget {
   const ClassifiedAds({
     super.key,
   });

   @override
   _ClassifiedAdsState createState() => _ClassifiedAdsState();
 }
class _ClassifiedAdsState extends State<ClassifiedAds> {
  final ScrollController _mainScrollController = ScrollController();

  bool _dataFetch = false;
  final dynamic _classifiedProducts = [];
  int page = 1;
  bool _showSearchBar = false;
  String _searchQuery = "";
  bool _loadingMore = false; // Track whether more data is being loaded

  @override
  void initState() {
    super.initState();
    fetchData();

    // Listen for scroll events
    _mainScrollController.addListener(() {
      if (_mainScrollController.position.pixels == _mainScrollController.position.maxScrollExtent) {
        // If we reached the bottom, load more data
        if (!_loadingMore) {
          loadMoreProducts();
        }
      }
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  reset() {
    _dataFetch = false;
    _classifiedProducts.clear();
    setState(() {});
  }

  fetchData() async {
    var classifiedProductRes = await ClassifiedProductRepository().getClassifiedProducts(page: page);
    _classifiedProducts.addAll(classifiedProductRes.data);
    _dataFetch = true;
    setState(() {});
  }

  loadMoreProducts() async {
    if (_loadingMore) return; // Prevent multiple loads
    setState(() {
      _loadingMore = true;
    });

    page++;
    var classifiedProductRes = await ClassifiedProductRepository().getClassifiedProducts(page: page);
    if (classifiedProductRes.data!.isNotEmpty) {
      _classifiedProducts.addAll(classifiedProductRes.data);
      setState(() {});
    }

    setState(() {
      _loadingMore = false;
    });
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchData();
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchQuery = ""; // Clear search query when hiding the search bar
      }
    });
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchQuery = text;
    });
  }

  List<dynamic> getFilteredProducts() {
    if (_searchQuery.isEmpty) {
      return _classifiedProducts;
    } else {
      return _classifiedProducts.where((product) {
        return product.name.toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        body: body(),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: UsefulElements.backButton(context),
      title: _showSearchBar
          ? Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: TextField(
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
          style: TextStyle(color: Colors.green),
          onChanged: _onSearchTextChanged,
        ),
      )
          : Text(
        AppLocalizations.of(context)!.classified_ads_ucf,
        style: TextStyle(fontSize: 16, color: MyTheme.dark_font_grey, fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: [
        IconButton(
          icon: Icon(_showSearchBar ? Icons.close : Icons.search),
          onPressed: _toggleSearchBar,
        ),
      ],
    );
  }

  Widget body() {
    if (!_dataFetch) {
      return ShimmerHelper().buildProductGridShimmer(scontroller: _mainScrollController);
    }

    if (_classifiedProducts.length == 0) {
      return Center(child: Text(LangText(context).local.no_data_is_available));
    }

    final filteredProducts = getFilteredProducts();

    return RefreshIndicator(
      onRefresh: _onPageRefresh,
      child: SingleChildScrollView(
        controller: _mainScrollController,
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              itemCount: filteredProducts.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ClassifiedAdsCard(
                  id: filteredProducts[index].id,
                  slug: filteredProducts[index].slug,
                  image: filteredProducts[index].thumbnailImage,
                  name: filteredProducts[index].name,
                  unit_price: filteredProducts[index].unitPrice,
                  condition: filteredProducts[index].condition,
                );
              },
            ),
            if (_loadingMore)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
