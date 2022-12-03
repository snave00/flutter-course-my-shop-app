import 'package:flutter/material.dart';
import '../provider/product_provider.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedProduct = ProductModel(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  /// Used didChangeDependencies workaround since ModalRoute.of was not working
  /// in initState().
  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final productId = ModalRoute.of(context)?.settings.arguments as String;
        _editedProduct = Provider.of<ProductProvider>(context, listen: false)
            .findById(productId);
        _initValues = {
          'title': _editedProduct.title ?? '',
          'description': _editedProduct.description ?? '',
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl ?? '',
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl!;
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // To avoid memory leaks
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  Future<void> _saveForm() async {
    // Logic validation can be moved to provider/viewmodel
    // You can use 'autovalidate' to trigger validate in every keystroke
    var isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }

    // Gets the values from the Form
    _form.currentState?.save();

    setLoading(true);

    if (_editedProduct.id != null) {
      await updateToList();
    } else {
      // New Item. Save to list.
      await saveToList2();
    }

    setLoading(false);
    // Checks if context is mounted to avoid crashing.
    // If removed, lint will detect popping is not recommeded in async
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> updateToList() async {
    // If there's an id found => Existed before so it would be in Edit mode.
    await Provider.of<ProductProvider>(context, listen: false)
        .updateProduct(_editedProduct.id ?? '', _editedProduct);
  }

  /// Saving to list using the Future with async and await.
  /// Not sure why it used the Future<void> in lecture.
  /// Lesson 248 Working with 'async' & 'await'
  Future<void> saveToList2() async {
    try {
      await Provider.of<ProductProvider>(context, listen: false)
          .addProduct2(_editedProduct);
    } catch (error) {
      // will catch the error in 'addProduct'
      print('saveToList2 error: $error');

      await showDialog(
        context: context,
        builder: (buildContext) => AlertDialog(
          title: const Text('An error occured!'),
          content: const Text('Something went wrong'),
          actions: [
            TextButton(
              onPressed: () {
                // use the builderContext
                Navigator.of(buildContext).pop();
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
    }
  }

  // Saving to list using the Future '.then(){}'
  void saveToList() {
    Provider.of<ProductProvider>(context, listen: false)
        .addProduct(_editedProduct)
        .catchError((error) {
      print('CATCH ERRORRRR');
      // will catch the error in 'addProduct'
      return showDialog<Null>(
        // return showDialog - it's a Future so when the okay button is pressed, .then will be executed.
        context: context,
        builder: (buildContext) => AlertDialog(
          title: const Text('An error occured!'),
          content: const Text('Something went wrong'),
          actions: [
            TextButton(
              onPressed: () {
                // use the builderContext
                Navigator.of(buildContext).pop();
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
    }).then(
      (_) {
        // this is will still run after catch error.
        setLoading(false);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          // Refactor - validation can be moved to provider logic.
                          if (value!.isEmpty) {
                            return 'Please input a title.';
                          }
                          // return null => means no error
                          return null;
                        },
                        onSaved: (newValue) => _editedProduct = ProductModel(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: newValue,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        ),
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          // Refactor - validation can be moved to provider logic.
                          if (value!.isEmpty) {
                            return 'Please input a price.';
                          }
                          // Checks if parsing has error.
                          if (double.tryParse(value) == null) {
                            return 'Please input a valid price.';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a price greater than zero.';
                          }
                          // return null => means no error
                          return null;
                        },
                        onSaved: (newValue) => _editedProduct = ProductModel(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(newValue!),
                          imageUrl: _editedProduct.imageUrl,
                        ),
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          // Refactor - validation can be moved to provider logic.
                          if (value!.isEmpty) {
                            return 'Please input a description.';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 characters.';
                          }
                          // return null => means no error
                          return null;
                        },
                        onSaved: (newValue) => _editedProduct = ProductModel(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: newValue,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              child: _imageUrlController.text.isEmpty
                                  ? const Text('Enter a URL')
                                  : FittedBox(
                                      alignment: Alignment.center,
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onEditingComplete: () {
                                // Check or done button is pressed in keyboard. It will update.
                                setState(() {});
                              },
                              onFieldSubmitted: (value) => _saveForm(),
                              validator: (value) {
                                // Refactor - validation can be moved to provider logic.
                                if (value!.isEmpty) {
                                  return 'Please input an image URL.';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter a valid URL.';
                                }
                                // if (!value.endsWith('.png') &&
                                //     !value.endsWith('.jpg') &&
                                //     !value.endsWith('jpeg')) {
                                //   return 'Not a valid image URL';
                                // }
                                // return null => means no error
                                return null;
                              },
                              onSaved: (newValue) =>
                                  _editedProduct = ProductModel(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: newValue,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
