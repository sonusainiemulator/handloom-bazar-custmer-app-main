// To parse this JSON data, do
//
//     final cartResponse = cartResponseFromJson(jsonString);

import 'dart:convert';

CartResponse cartResponseFromJson(String str) =>
    CartResponse.fromJson(json.decode(str));

String cartResponseToJson(CartResponse data) => json.encode(data.toJson());

class CartResponse {
  String? grandTotal;
  List<Datum>? data;
  bool? success;
  int? status;

  CartResponse({
    this.grandTotal,
    this.data,
    this.success,
    this.status,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) => CartResponse(
        grandTotal: json["grand_total"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "grand_total": grandTotal,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "success": success,
        "status": status,
      };
}

class Datum {
  String? name;
  int? ownerId;
  String? subTotal;
  List<CartItem>? cartItems;

  Datum({
    this.name,
    this.ownerId,
    this.subTotal,
    this.cartItems,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        name: json["name"],
        ownerId: json["owner_id"],
        subTotal: json["sub_total"],
        cartItems: json["cart_items"] == null
            ? []
            : List<CartItem>.from(
                json["cart_items"]!.map((x) => CartItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "owner_id": ownerId,
        "sub_total": subTotal,
        "cart_items": cartItems == null
            ? []
            : List<dynamic>.from(cartItems!.map((x) => x.toJson())),
      };
}

class CartItem {
  int? id;
  int? ownerId;
  int? userId;
  int? productId;
  String? productName;
  int? auctionProduct;
  String? productThumbnailImage;
  String? variation;
  String? price;
  String? currencySymbol;
  String? tax;
  int? shippingCost;
  int? quantity;
  int? lowerLimit;
  int? upperLimit;

  CartItem({
    this.id,
    this.ownerId,
    this.userId,
    this.productId,
    this.productName,
    this.auctionProduct,
    this.productThumbnailImage,
    this.variation,
    this.price,
    this.currencySymbol,
    this.tax,
    this.shippingCost,
    this.quantity,
    this.lowerLimit,
    this.upperLimit,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json["id"] is String ? int.tryParse(json["id"]) : json["id"],
        ownerId: json["owner_id"] is String ? int.tryParse(json["owner_id"]) : json["owner_id"],
        userId: json["user_id"] is String ? int.tryParse(json["user_id"]) : json["user_id"],
        productId: json["product_id"] is String ? int.tryParse(json["product_id"]) : json["product_id"],
        productName: json["product_name"],
        auctionProduct: json["auction_product"] is String ? int.tryParse(json["auction_product"]) : json["auction_product"],
        productThumbnailImage: json["product_thumbnail_image"],
        variation: json["variation"],
        price: json["price"],
        currencySymbol: json["currency_symbol"],
        tax: json["tax"],
        shippingCost: json["shipping_cost"] is String ? int.tryParse(json["shipping_cost"]) ?? 0 : json["shipping_cost"],
        quantity: json["quantity"] is String ? int.tryParse(json["quantity"]) : json["quantity"],
        lowerLimit: json["lower_limit"] is String ? int.tryParse(json["lower_limit"]) : json["lower_limit"],
        upperLimit: json["upper_limit"] is String ? int.tryParse(json["upper_limit"]) : json["upper_limit"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner_id": ownerId,
        "user_id": userId,
        "product_id": productId,
        "product_name": productName,
        "auction_product": auctionProduct,
        "product_thumbnail_image": productThumbnailImage,
        "variation": variation,
        "price": price,
        "currency_symbol": currencySymbol,
        "tax": tax,
        "shipping_cost": shippingCost,
        "quantity": quantity,
        "lower_limit": lowerLimit,
        "upper_limit": upperLimit,
      };
}
