import 'package:flutter/material.dart';
import 'package:my_shop/utils/custom_routes.dart';
import '../screens/user_product_screen.dart';
import '../screens/product_overview_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/order_screen.dart';
import '../screens/edit_product_screen.dart';
import '../screens/auth_screen.dart';

class AppRoutes {
  // static const _initialRoute = '/';
  static const _authScreenRoute = '/auth';
  static const _productOverviewScreenRoute = '/product-overview';
  static const _productDetailRoute = '/product-detail';
  static const _cartScreenRoute = '/cart';
  static const _orderScreenRoute = '/order';
  static const _userProductScreenRoute = '/user-product';
  static const _editProductScreenRoute = '/edit-product';

  static Map<String, Widget Function(BuildContext)> get getRoutes {
    return {
      // _initialRoute: (routeContext) => const ProductOverviewScreen(),
      _authScreenRoute: (routeContext) => const AuthScreen(),
      _productOverviewScreenRoute: (routeContext) =>
          const ProductOverviewScreen(),
      _productDetailRoute: (routeContext) => const ProductDetailScreen(),
      _cartScreenRoute: (routeContext) => const CartScreen(),
      _orderScreenRoute: (routeContext) => const OrderScreen(),
      _userProductScreenRoute: (routeContext) => const UserProductScreen(),
      _editProductScreenRoute: (routeContext) => const EditProductScreen(),
    };
  }

  static void goToProductDetailScreen(BuildContext context, String? id) {
    Navigator.of(context).pushNamed(
      _productDetailRoute,
      arguments: id,
    );
  }

  static void goToAuthScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(_authScreenRoute);
  }

  static void goToProductOverviewScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(_productOverviewScreenRoute);
  }

  static void goToCartScreen(BuildContext context) {
    Navigator.of(context).pushNamed(_cartScreenRoute);
  }

  // static void goToOrderScreen(BuildContext context) {
  //   Navigator.of(context).pushReplacementNamed(_orderScreenRoute);
  // }

  /// Using [CustomRoutes] in individual Pages.
  static void goToOrderScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(CustomRoutes(
      builder: (builderContext) => const OrderScreen(),
    ));
  }

  static void goToUserProductScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(_userProductScreenRoute);
  }

  static void goToEditProductScreen(
      {required BuildContext context, String? id}) {
    Navigator.of(context).pushNamed(_editProductScreenRoute, arguments: id);
  }
}
