import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/user.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _productIdController = TextEditingController();
  int currentStock = 100; // Example stock value
  final Uuid uuid = Uuid();
  late User user;

  // List to store added products
  List<Map<String, dynamic>> products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  String generateProductId() {
    final random = Random();
    return (10000 + random.nextInt(90000)).toString(); // 5-digit random number
  }

  void _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScannerPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _productIdController.text = result;
      });
    }
  }

  Future<void> addProductAndUser(
    Product product,
    User user,
  ) async {
    setState(() {
      isLoading = true;
    });

    // Simulate a network request or any long-running task
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      products.add({
        'productId': generateProductId(),
        'product': product,
        'user': user,
      });
      isLoading = false;
    });
  }

  void _openAddProductDialog() {
    TextEditingController productNameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController firstInventoryDateController =
        TextEditingController();
    TextEditingController supervisorNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: firstInventoryDateController,
                  decoration:
                      InputDecoration(labelText: 'First Inventory Date'),
                ),
                TextField(
                  controller: supervisorNameController,
                  decoration: InputDecoration(labelText: 'Supervisor Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (productNameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    firstInventoryDateController.text.isNotEmpty &&
                    supervisorNameController.text.isNotEmpty) {
                  Product product = Product(
                    productName: productNameController.text,
                    description: descriptionController.text,
                    firstInventoryDate: firstInventoryDateController.text,
                    supervisorName: supervisorNameController.text,
                  );
                  Navigator.of(context).pop();
                  _openAddUserDialog(product);
                }
              },
              child: Text('Next'),
            ),
          ],
        );
      },
    );
  }

  void _openAddUserDialog(Product product) {
    TextEditingController userIdController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController designationController = TextEditingController();
    TextEditingController companyNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add User Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userIdController,
                  decoration: InputDecoration(labelText: 'User ID'),
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: designationController,
                  decoration: InputDecoration(labelText: 'Designation'),
                ),
                TextField(
                  controller: companyNameController,
                  decoration: InputDecoration(labelText: 'Company Name'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (userIdController.text.isNotEmpty &&
                    usernameController.text.isNotEmpty &&
                    designationController.text.isNotEmpty &&
                    companyNameController.text.isNotEmpty) {
                  User user = User(
                    userId: userIdController.text,
                    username: usernameController.text,
                    designation: designationController.text,
                    companyName: companyNameController.text,
                    deviceId: uuid.v4(),
                  );
                  Navigator.of(context).pop();
                  addProductAndUser(product, user);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(int index) {
    setState(() {
      products.removeAt(index); // Remove product and user from list
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Inventory Management',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product ID Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _productIdController,
                      decoration: InputDecoration(
                        labelText: 'Enter 5-digit Product ID',
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.search),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.qr_code_scanner, color: Colors.blueAccent),
                    onPressed: _scanQRCode, // QR Code functionality
                  ),
                ],
              ),
              SizedBox(height: 20.0),

              // Display Added Products Section
              SizedBox(height: 20),
              Text(
                'Added Products:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index]['product'] as Product;
                        final user = products[index]['user'] as User;

                        return Column(
                          children: [
                            // Product Card with updated style
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product ID
                                    Text(
                                      'Product ID: ${products[index]['productId']}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.shopping_bag,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Product Name: ${product.productName}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.description,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Description: ${product.description}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.date_range,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Inventory Date: ${product.firstInventoryDate}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Supervisor: ${product.supervisorName}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),

                                    // Stock Section with better visuals
                                    Row(
                                      children: [
                                        Text(
                                          'Stock: $currentStock',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: currentStock == 0
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                        Spacer(),
                                        IconButton(
                                          icon: Icon(Icons.remove_circle,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              if (currentStock > 0) {
                                                currentStock--;
                                              }
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add_circle,
                                              color: Colors.green),
                                          onPressed: () {
                                            setState(() {
                                              currentStock++;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _deleteProduct(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8),

                            // User Card with updated style
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User ID: ${user.userId}',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blueAccent),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Username: ${user.username}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.design_services,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Designation: ${user.designation}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.business,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Company: ${user.companyName}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.devices,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Device ID: ${user.deviceId}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddProductDialog, // Open dialog for adding product
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.add, size: 30),
        ),
      ),
    );
  }
}

class QRCodeScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          controller.scannedDataStream.listen((scanData) {
            Navigator.pop(context, scanData.code);
          });
        },
      ),
    );
  }
}
