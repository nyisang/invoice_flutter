import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invoice_flutter/Models/GetINVOICEsSalesModel.dart';
import 'package:invoice_flutter/Models/MyTransactionModel.dart';
import 'package:invoice_flutter/Models/ProductSales.dart';
import 'package:invoice_flutter/Models/Submitinvoice.dart';
import 'package:invoice_flutter/Models/TransactionsList.dart';
import 'package:invoice_flutter/Utils/BaseURL.dart';
import 'package:invoice_flutter/dashboard/InvoicesScreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItem;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productAmountController = TextEditingController();
  final TextEditingController _invoicenameController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _amountControllertomyPhone = TextEditingController();
  String FirstName = '';
  String LastName = '';
  String PhoneNumber = '';
  bool _loading = false;
  List<TransactionsList> _transactions = [];
  List<GetINVOICEsSalesModel> posdatas = [];
  final List<String> _dropdownItems = [
    'My Number',
    'Other Number',
  ];
  bool firstContainerVisible = true;
  bool secondContainerVisible = false;
  String? _transformedValue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchTransactions();
    _fetchsalepos();
  }

  Future<void> _fetchsalepos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = true;
    });
    final url = "${BaseURL.INVOICE_PRODUCTs}";
    print('Request URL: $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        posdatas = data.map((json) => GetINVOICEsSalesModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to load Data. Please try again later to Create Invoice."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      FirstName = prefs.getString("FNAME") ?? '';
      LastName = prefs.getString("LNAME") ?? '';
      PhoneNumber = prefs.getString("PHONE") ?? '';
    });
  }

  Future<void> _fetchTransactions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse(BaseURL.MY_TRANSACTIONS), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });
      print('URL 33: ${response.request!.url}');
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = true;
        });
        final List<dynamic> responseData = jsonDecode(response.body);
        print(response.statusCode);
        print(response.body);
        setState(() {
          _transactions = responseData.map((json) => TransactionsList.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load Transactions');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double grandTotal = _calculateGrandTotal();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 86, 141, 218),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Invoice Flutter',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Welcome, $FirstName $LastName',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InvoicesScreen()),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 86, 141, 218),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  const Size(double.infinity, 50.0),
                ),
              ),
              child: _loading
                  ? CircularProgressIndicator()
                  : const Text(
                      'Invoice Status',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: ElevatedButton.icon(
                onPressed: () => _showUploadModal(context),
                icon: Icon(Icons.create, color: Colors.white),
                label: Text('Create Invoice', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // background color
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Created Invoices',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Amount')),
                    ],
                    rows: posdatas
                        .map(
                          (data) => DataRow(cells: [
                            DataCell(Text(data.productsale)),
                            DataCell(Text(data.amountsale.toString())),
                          ]),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Grand Total: ${grandTotal.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Invoice Amount ${grandTotal.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _invoicenameController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Name",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _submitInvoiceForm,
                          child: Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 86, 218, 117),
              ),
              child: Text('Submit invoice', style: TextStyle(color: Colors.white, fontSize: 14.0)),
            ),
          ],
        ),
      ),
    );
  }

  String transformValue(String? value) {
    if (value == "My Number") {
      return "MyNumber";
    } else if (value == "Other Number") {
      return "OtherNumber";
    }
    return ""; // Default value
  }

  Widget _buildCampaignMaterialItem(TransactionsList transaction) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${transaction.phonepaying}'),
          Text('${transaction.amounttopay}'),
        ],
      ),
    );
  }

  void _showUploadModal(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Item to invoice'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: _productNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter  Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: _productAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: _submitProductinvoiceForm,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white, // Text color
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateGrandTotal() {
    return posdatas.fold(0, (sum, item) => sum + item.amountsale);
  }

  Future<void> _submitInvoiceForm() async {
    String Invoicenamesend = _invoicenameController.text;
    double grandTotal = _calculateGrandTotal();

    Map<String, dynamic> postData = {
      'InvoiceName': Invoicenamesend,
      'InvoiceAmount': grandTotal,
    };

    String jsonString = json.encode(postData);
    final response = await http.post(
      Uri.parse(BaseURL.SUBMITINVOICE),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvoicesScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to submit data."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _submitProductinvoiceForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Productsellerid2 = prefs.getString("UserID") ?? '';
    String ProductName2 = _productNameController.text;
    String ProductAmount2 = _productAmountController.text;

    Map<String, dynamic> postData = {
      'productName': ProductName2,
      'ProductAmount': ProductAmount2,
      'productSeller': Productsellerid2,
    };

    String jsonString = json.encode(postData);
    final response = await http.post(
      Uri.parse(BaseURL.CREATE_INVOICE_PRODUCT),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString,
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to submit data."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}
