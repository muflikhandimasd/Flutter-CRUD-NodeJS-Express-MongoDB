import 'package:flutter/material.dart';
import 'package:flutter_crud_node_mongo/services/api_service.dart';
import 'package:flutter_crud_node_mongo/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:snippet_coder_utils/ProgressHUD.dart';

import 'product_item.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  // List<ProductModel> products = List<ProductModel>.empty(growable: true);
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();

    // products.add(
    //   ProductModel(
    //       id: "1",
    //       productName: "Macbook Pro 2021",
    //       productImage:
    //           "https://www.apple.com/v/macbook-pro-14-and-16/b/images/overview/hero/hero_intro_endframe__e6khcva4hkeq_large.jpg",
    //       productPrice: 27000),
    // );

    // products.add(
    //   ProductModel(
    //       id: "2",
    //       productName: "Macbook Pro 2019",
    //       productImage:
    //           "https://asset.kompas.com/crops/_NZIc-wqK0tzracOVKScOmx4waI=/39x20:719x473/750x500/data/photo/2019/07/11/2767177487.png",
    //       productPrice: 20000),
    // );
  }

  Widget productList(products) {
    return SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                onPrimary: Colors.white,
                primary: Colors.green,
                minimumSize: const Size(88, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/add-product");
              },
              child: Text(
                "Add Product",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductItem(
                  model: products[index],
                  onDelete: (ProductModel model) {
                    setState(() {
                      isApiCallProcess = true;
                    });

                    APIService.deleteProduct(model.id).then((response) {
                      setState(() {
                        isApiCallProcess = false;
                      });
                    });
                  },
                );
              },
            )
          ],
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NodeJS & Flutter - CRUD APP"),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[200],
      body: ProgressHUD(
        child: loadProducts(),
        inAsyncCall: isApiCallProcess,
        opacity: .3,
        key: UniqueKey(),
      ),
    );
  }

  Widget loadProducts() {
    return FutureBuilder(
        future: APIService.getProducts(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<ProductModel>?> model,
        ) {
          if (model.hasData) {
            return productList(model.data);
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
