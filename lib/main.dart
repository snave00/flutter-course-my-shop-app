import 'package:flutter/material.dart';
import './provider/auth_provider.dart';
import 'package:provider/provider.dart';

import './utils/app_routes.dart';
import './provider/product_provider.dart';
import './provider/cart_provider.dart';
import '../provider/order_provider.dart';
import './screens/product_overview_screen.dart';
import './screens/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('AUTH BA rebuilding Main.');
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (providerContext) => AuthProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
              create: (providerContext) => ProductProvider(),
              update: (updateContext, auth, previous) {
                var previousProducts = previous;
                previousProducts?.authToken = auth.token ?? '';
                previousProducts == null ? [] : previousProducts.getItems;
                previousProducts?.userId = auth.userId ?? '';
                return previousProducts!;
                // Alternative short way
                // return previous!..authToken = auth.token!;
              }),
          ChangeNotifierProvider(
            create: (providerContext) => CartProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
            create: (providerContext) => OrderProvider(),
            update: (updateContext, auth, previous) {
              var previousOrders = previous;
              previousOrders?.authToken = auth.token ?? '';
              previousOrders?.userId = auth.userId ?? '';
              previousOrders == null ? [] : previousOrders.getOrders;
              return previousOrders!;
            },
          ),
        ],
        child: Consumer<AuthProvider>(
          builder: (builderContext, auth, builderChild) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Shop',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                  .copyWith(secondary: Colors.deepOrange),
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? const ProductOverviewScreen()
                : const AuthScreen(),
            // initialRoute: '/auth',
            routes: AppRoutes.getRoutes,
          ),
        ));
  }
}
