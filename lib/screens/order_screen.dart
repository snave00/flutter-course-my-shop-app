import 'package:flutter/material.dart';
import 'package:my_shop/widgets/order_item.dart';
import 'package:provider/provider.dart';

import '../provider/order_provider.dart';
import '../widgets/my_drawer.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Obtaining Future earky would help to prevent to call
  // -the Provider every time the widget rebuilts.
  // This would save api calls and will help in Firebase Optimization
  // -avoiding expensive api calls.
  late Future _ordersFuture;

  Future _obtainOrdersFuture() async {
    return Provider.of<OrderProvider>(context, listen: false)
        .fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // this provider will get infinite loop with FutureBuilder
    // it will trigger the build() method, making the FutureBuilder to trigger again.
    // final orders = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const MyDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (builderContext, snapshot) {
          // Youtube Johannes Milke
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text('An error has occured'),
                );
              } else {
                print('ORDERS MO: ${snapshot.data}');
                return Consumer<OrderProvider>(
                  builder: (context, value, child) => ListView.builder(
                    itemCount: value.getOrders.length,
                    itemBuilder: (context, index) =>
                        OrderItem(orderItemModel: value.getOrders[index]),
                  ),
                );
              }
          }
          // UDEMY
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(child: CircularProgressIndicator());
          // } else {
          //   if (snapshot.error != null) {
          //     // Do error Handling here.
          //     return const Center(
          //       child: Text('An error has occured'),
          //     );
          //   } else {
          //     return Consumer<OrderProvider>(
          //       builder: (context, value, child) => ListView.builder(
          //         itemCount: value.getOrders.length,
          //         itemBuilder: (context, index) =>
          //             OrderItem(orderItemModel: value.getOrders[index]),
          //       ),
          //     );
          //   }
          // }
        },
      ),
    );
  }
}
