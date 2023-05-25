import 'package:flutter/material.dart';

class AddVoucher extends StatefulWidget {
  const AddVoucher({Key key}) : super(key: key);

  @override
  AddVoucherState createState() => AddVoucherState();
}

class AddVoucherState extends State<AddVoucher> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Voucher"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: orientation == Orientation.portrait
                  ? height * 0.01
                  : height * 0.03,
            ),
            Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, bottom: 25, top: 15),
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.fill,
                      width: orientation == Orientation.portrait
                          ? width * 0.2
                          : width * 0.10,
                      height: orientation == Orientation.portrait
                          ? height * 0.08
                          : height * 0.18,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WASHRY VOUCHER",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5.0),
                          child: Text(
                            "Available balance: \u{20B9}0.00",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5.0),
                          child: Text(
                            "You can add upto \u{20B9}9960",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ]),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15),
                  child: TextFormField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return "data";
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        // border: InputBorder.none,
                        labelText: "VOUCHER CODE",
                        prefixText: "\u{20B9}",
                        // hintText: "Amount",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15),
                  child: TextFormField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return "data";
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        // border: InputBorder.none,
                        labelText: "VOUCHER PIN",
                        prefixText: "\u{20B9}",
                        // hintText: "Amount",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      )),
                ),
              ),
            ),
            SizedBox(
              height: height * .04,
            ),
            SizedBox(
              width: width * .9,
              height: orientation == Orientation.portrait
                  ? height * 0.055
                  : height * 0.13,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("ADD VOUCHER")),
            ),
            SizedBox(
              height: height * .03,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "NOTE:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    Row(
                      children: [
                        Container(
                          height: height * .008,
                          width: width * .017,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black),
                        ),
                        SizedBox(
                          width: width * .02,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: height * .02,
                            ),
                            SizedBox(
                                width: width * .9,
                                child: Text(
                                  "Washry Money cannot be transferred to your bank account as per RBI guidelines.",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                ))
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * .01,
                    ),
                    Row(
                      children: [
                        Container(
                          height: height * .008,
                          width: width * .017,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black),
                        ),
                        SizedBox(
                          width: width * .02,
                        ),
                        SizedBox(
                            width: width * .9,
                            child: Text(
                              "Washry Money can be used for your cleaning or orders",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ))
                      ],
                    )
                  ],
                )),
            SizedBox(height: height * 0.05),
          ],
        ),
      ),
    );
  }
}
