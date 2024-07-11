import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invoice_flutter/Models/GetINVOICEsSalesModel.dart';
import 'package:invoice_flutter/Models/GetINVOICEsStatusModel.dart';
import 'package:invoice_flutter/Models/MyTransactionModel.dart';
import 'package:invoice_flutter/Models/TransactionsList.dart';
import 'package:invoice_flutter/Utils/BaseURL.dart';
import 'package:invoice_flutter/dashboard/DashboardScreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  _InvoicesScreenState createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedItem;
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _amountControllertomyPhone = TextEditingController();
  String FirstName = '';
  String LastName = '';
  String PhoneNumber = '';
  bool _loading = false;
  List<GetINVOICEsStatusModel> invoicesdatas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchTransactions();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    final url = "${BaseURL.PAYINVOICE}";
    print('Request URL: $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        invoicesdatas = data.map((json) => GetINVOICEsStatusModel.fromJson(json)).toList();
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
            content: Text("Failed to load Data. Please try again later."),
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

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                  Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Invoices Status',
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
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const <DataColumn>[
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Total')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: invoicesdatas.map((data) {
                            return DataRow(cells: [
                              DataCell(Text(data.invoicename)),
                              DataCell(Text(data.invoiceamount.toString())),
                              DataCell(Text(data.invoicestatus)),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.payment, color: Colors.red),
                                  onPressed: () {
                                    _makepayment(data.id);
                                  },
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _makepayment(int id) {
    GetINVOICEsStatusModel? selectedInvoice = invoicesdatas.firstWhere(
      (invoice) => invoice.id == id,
    );

    if (selectedInvoice != null) {
      double amount = selectedInvoice.invoiceamount.toDouble();
      String NameInvo = selectedInvoice.invoicename;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          String phoneNumber = '';

          return AlertDialog(
            title: Text('Mpesa Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Name: $NameInvo'), // Display invoice name
                SizedBox(height: 16.0),
                Text('Total Amount: $amount'), // Display total amount
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phonenumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the phone number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Submit'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _submitMPESAinvoiceForm(id, amount); // Pass id and amount
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _submitMPESAinvoiceForm(int id, double amount) async {
    int invoicID = id;
    String InvoiceAmount = amount.toString();
    String InvoiceMPESANumber = _phonenumberController.text;

    Map<String, dynamic> postData = {
      'phonenumber': InvoiceMPESANumber,
      'amount': InvoiceAmount,
      'invoiceid': invoicID,
    };

    String jsonString = json.encode(postData);
    final response = await http.post(
      Uri.parse(BaseURL.CREATE_MPESA),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InvoicesScreen()),
                  );
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
