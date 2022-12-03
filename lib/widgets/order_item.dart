import 'dart:math';
import 'package:flutter/material.dart';
import '../models/order_item_model.dart';
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  const OrderItem({super.key, required this.orderItemModel});

  final OrderItemModel orderItemModel;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(children: [
        ListTile(
          title: Text('\$${widget.orderItemModel.amount}'),
          subtitle: Text(
            DateFormat('dd/MM/yyyy hh:mm')
                .format(widget.orderItemModel.dateTime),
          ),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
          ),
        ),
        if (_expanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            height: min(widget.orderItemModel.products.length * 20 + 10, 180),
            child: ListView.builder(
              itemCount: widget.orderItemModel.products.length,
              itemBuilder: (context, index) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.orderItemModel.products[index].title ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.orderItemModel.products[index].quantity} x \$${widget.orderItemModel.products[index].price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
      ]),
    );
  }
}
