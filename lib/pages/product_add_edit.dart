import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_crud_node_mongo/services/api_service.dart';
import 'package:flutter_crud_node_mongo/config/config.dart';
import 'package:flutter_crud_node_mongo/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

class ProductAddEdit extends StatefulWidget {
  const ProductAddEdit({Key? key}) : super(key: key);

  @override
  _ProductAddEditState createState() => _ProductAddEditState();
}

class _ProductAddEditState extends State<ProductAddEdit> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool isApiCallProcess = false;
  ProductModel? productModel;
  List<Object> images = [];
  bool isEditMode = false;
  bool isImageSelected = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("NodeJS & Flutter - CRUD APP"),
          elevation: 0,
        ),
        backgroundColor: Colors.grey[200],
        body: ProgressHUD(
          child: Form(
            key: globalKey,
            child: productForm(),
          ),
          inAsyncCall: isApiCallProcess,
          opacity: .3,
          key: UniqueKey(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    productModel = ProductModel();

    Future.delayed(Duration.zero, () {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;

        productModel = arguments["model"];
        isEditMode = true;
        setState(() {});
      }
    });
  }

  Widget productForm() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 18,
          ),
          Center(
            child: Text(
              "Form Tambah atau Edit Data",
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10),
            child: Text("Product Name",
                style: GoogleFonts.poppins(color: Colors.black)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 5),
            child: FormHelper.inputFieldWidget(
                context,
                const Icon(Icons.ac_unit),
                "ProductName",
                "Product Name", (onValidateVal) {
              if (onValidateVal.isEmpty) {
                return "ProductName can't be empty";
              }
              return null;
            }, (onSavedVal) {
              productModel!.productName = onSavedVal;
            },
                initialValue: productModel!.productName ?? "",
                borderColor: Colors.black,
                borderFocusColor: Colors.deepPurpleAccent,
                textColor: Colors.black,
                hintColor: Colors.black.withOpacity(.7),
                borderRadius: 10,
                showPrefixIcon: false),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text("Product Price",
                style: GoogleFonts.poppins(color: Colors.black)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 5),
            child: FormHelper.inputFieldWidget(
              context,
              const Icon(Icons.ac_unit),
              "ProductPrice",
              "Product Price",
              (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return "Product Price can't be empty";
                }
                return null;
              },
              (onSavedVal) {
                productModel!.productPrice = int.parse(onSavedVal);
              },
              initialValue: productModel!.productPrice == null
                  ? ""
                  : productModel!.productPrice.toString(),
              borderColor: Colors.black,
              borderFocusColor: Colors.deepPurpleAccent,
              textColor: Colors.black,
              hintColor: Colors.black.withOpacity(.7),
              borderRadius: 10,
              showPrefixIcon: false,
              suffixIcon: const Icon(Icons.monetization_on),
              keyboardType: TextInputType.number,
            ),
          ),
          picPicker(isImageSelected, productModel!.productImage ?? "", (file) {
            setState(() {
              productModel!.productImage = file.path;
              isImageSelected = true;
            });
          }),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: FormHelper.submitButton("Save", () {
              if (validateAndSave()) {
                // API Service
                setState(() {
                  isApiCallProcess = true;
                });

                APIService.saveProduct(
                        productModel!, isEditMode, isImageSelected)
                    .then(
                  (response) {
                    setState(() {
                      isApiCallProcess = false;
                    });

                    if (response) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/",
                        (route) => false,
                      );
                    } else {
                      FormHelper.showSimpleAlertDialog(
                        context,
                        Config.appName,
                        "Error",
                        "OK",
                        () {
                          Navigator.of(context).pop();
                        },
                      );
                    }
                  },
                );
              }
            },
                btnColor: Colors.cyan,
                borderColor: Colors.transparent,
                borderRadius: 15,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  static Widget picPicker(
    bool isFileSelected,
    String fileName,
    Function onFilePicked,
  ) {
    Future<XFile?> _imageFile;
    ImagePicker _picker = ImagePicker();

    return Column(
      children: [
        fileName.isNotEmpty
            ? isFileSelected
                ? Image.file(
                    File(fileName),
                    height: 200,
                    width: 200,
                  )
                : SizedBox(
                    child: Image.network(
                      fileName,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
            : SizedBox(
                child: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png",
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 35,
              width: 35,
              child: IconButton(
                onPressed: () {
                  _imageFile = _picker.pickImage(source: ImageSource.gallery);
                  _imageFile.then((file) async {
                    onFilePicked(file);
                  });
                },
                icon: const Icon(
                  Icons.image,
                  size: 35,
                ),
              ),
            ),
            SizedBox(
              height: 35,
              width: 35,
              child: IconButton(
                onPressed: () {
                  _imageFile = _picker.pickImage(source: ImageSource.camera);
                  _imageFile.then((file) async {
                    onFilePicked(file);
                  });
                },
                icon: const Icon(
                  Icons.camera_alt,
                  size: 35,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
