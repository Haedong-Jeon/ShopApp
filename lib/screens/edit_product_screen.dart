import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class EditProdcutScreen extends StatefulWidget {
  static const String routeName = './screens/edit_product_screen';
  @override
  _EditProdcutScreenState createState() => _EditProdcutScreenState();
}

class _EditProdcutScreenState extends State<EditProdcutScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocustNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Map<String, String> _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imgURL': '',
  };
  bool _isInit = true;
  Product _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imgURL: '',
  );

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String productId =
          ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imgURL': '',
        };
        _imageUrlController.text = _editedProduct.imgURL;
        super.didChangeDependencies();
        _isInit = false;
      }
    }
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (isValid) {
      _form.currentState.save();
      if (_editedProduct.id != null) {
        Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } else {
        Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _descriptionFocustNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'title'),
                initialValue: _initValues['title'],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    title: value,
                    price: _editedProduct.price,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                    description: _editedProduct.description,
                    imgURL: _editedProduct.imgURL,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return '\'title\' is empty';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'price'),
                initialValue: _initValues['price'],
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocustNode);
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: double.parse(value),
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                    description: _editedProduct.description,
                    imgURL: _editedProduct.imgURL,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) return '\'price\' is empty';
                  if (double.tryParse(value) == null)
                    return 'invalid input in \'price\'';
                  if (double.parse(value) <= 0)
                    return 'price must higher than 0';
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'description'),
                initialValue: _initValues['description'],
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocustNode,
                onSaved: (value) {
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                    description: value,
                    imgURL: _editedProduct.imgURL,
                  );
                },
                validator: (value) {
                  if (value.isEmpty)
                    return '\'description\' is empty';
                  else if (value.length < 5) return 'too short description';
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(
                      top: 8,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Text('Enter url')
                        : FittedBox(
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'image url'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          isFavorite: _editedProduct.isFavorite,
                          id: _editedProduct.id,
                          description: _editedProduct.description,
                          imgURL: value,
                        );
                      },
                      onFieldSubmitted: (_) => _saveForm(),
                      validator: (value) {
                        if (value.isEmpty) {
                          return '\'image url\' is empty';
                        }
                        if (!value.startsWith('http') &&
                            !value.startsWith('https')) {
                          return 'this is invalid url';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
