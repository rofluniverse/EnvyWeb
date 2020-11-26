import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:envyweb/Services/ApiFunctions%20-Editor.dart';
import 'package:envyweb/Services/Auth.dart';
import 'package:envyweb/Services/Widgets/DrawerItems.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../HomePage.dart';
import '../ProfilePage.dart';
import 'AcceptedOrders.dart';
import 'SubmitPage.dart';

class EditorPage extends StatefulWidget {
  final String name;
  final String uid;

  const EditorPage({Key key, this.name, this.uid}) : super(key: key);
  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        drawer: Drawer(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Customize("Dashboard", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditorPage()));
                }),
                Customize("Profile", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                }),
                Customize("Submit Image", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SubmitPage()));
                }),
                Customize("Accepted Orders", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AcceptedOrders(
                                uid: widget.uid ?? "1",
                              )));
                }),
                Customize("Log out", () async {
                  await AuthService().logOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage()),
                      (Route<dynamic> route) => false);
                }),
              ],
            ),
          ),
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Editor, " + widget.name.toString(),
                            style: TextStyle(
                                fontSize: 35,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Incoming Orders",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ordersWidget()
                    ]))))));
  }

  Widget ordersWidget() {
    var _media = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
          future:
              ApiFunctionsEditors().getUnconfirmedWorkOrders(widget.uid ?? "1"),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Container(
                    decoration: BoxDecoration(border: Border.all()),
                    width: _media.width,
                    height: _media.height * 0.9,
                    child: snapshot.data != false
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.length > 10
                                ? 10
                                : snapshot.data.length,
                            itemBuilder: (context, index) {
                              return EditorOrderFunction(
                                orderID: snapshot.data[index]['orderID'],
                                uid: widget.uid,
                                date: snapshot.data[index]['startTime'],
                                deadline: snapshot.data[index]['endTime'],
                              );
                            },
                          )
                        : Center(
                            child: Text("No Orders Found",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold))),
                  )
                : CircularProgressIndicator();
          }),
    );
  }
}

class EditorOrderFunction extends StatefulWidget {
  final String orderID;
  final String uid;
  final int date;
  final deadline;

  const EditorOrderFunction(
      {Key key, @required this.orderID, this.date, this.deadline, this.uid})
      : super(key: key);

  @override
  _EditorOrderFunctionState createState() => _EditorOrderFunctionState();
}

class _EditorOrderFunctionState extends State<EditorOrderFunction> {
  @override
  Widget build(BuildContext context) {
    var _media = MediaQuery.of(context).size;
    return Material(
        elevation: 10,
        shadowColor: Colors.grey,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: _media.height * 0.4,
          width: _media.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    Text('Order ID',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold)),
                    Text(widget.orderID),
                  ]),
                  Column(children: [
                    Text('Date',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold)),
                    Text(widget.date.toString()),
                  ]),
                  Column(children: [
                    Text('Deadline',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold)),
                    Text(widget.deadline.toString()),
                  ]),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: () async {
                      print(widget.orderID);
                      bool response = await ApiFunctionsEditors()
                          .orderConfirmation(true, widget.orderID);
                      if (response) {
                        showSuccessDialog(context);
                      } else {
                        showFailDialog(context);
                      }
                    },
                    child: Text("Accept"),
                    color: Colors.green,
                  ),
                  RaisedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => Dialog(
                                child: FutureBuilder(
                                    future: ApiFunctionsEditors()
                                        .getOrderDetails(widget.orderID),
                                    builder: (context, snapshot) {
                                      List features = snapshot.hasData
                                          ? json
                                              .decode(snapshot.data['features'])
                                          : [];
                                      return snapshot.hasData
                                          ? Container(
                                              height: _media.height * 0.7,
                                              width: _media.width * 0.7,
                                              child: snapshot.data != false
                                                  ? Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                                "Order Details",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        25)),
                                                            IconButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                              color: Colors.red,
                                                              icon: Icon(
                                                                  Icons.cancel),
                                                            )
                                                          ],
                                                        ),
                                                        Divider(),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              SizedBox(
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            CircularProgressIndicator(),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(Icons
                                                                            .error),
                                                                    imageUrl: snapshot
                                                                            .data['rawBase64'] ??
                                                                        "https://wallpaperaccess.com/full/2109.jpg",
                                                                  ),
                                                                  height: _media
                                                                          .height *
                                                                      0.5,
                                                                  width: _media
                                                                          .width *
                                                                      0.3),
                                                              Container(
                                                                height: _media
                                                                        .height *
                                                                    0.5,
                                                                width: _media
                                                                        .width *
                                                                    0.3,
                                                                child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      Text(
                                                                          "Tier",
                                                                          style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold)),
                                                                      Text(snapshot
                                                                              .data['tierId'] ??
                                                                          "Tier"),
                                                                      Text(
                                                                          "Date of ordering",
                                                                          style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold)),
                                                                      Text(snapshot
                                                                              .data['timestamp'] ??
                                                                          "Timestamp"),
                                                                      Text(
                                                                          "Deadline",
                                                                          style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold)),
                                                                      Text(snapshot
                                                                              .data['endTime'] ??
                                                                          "5"),
                                                                      Container(
                                                                          height: _media.height *
                                                                              0.2,
                                                                          width: _media.width *
                                                                              0.3,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              Text("Features Ordered", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                                              ListView.builder(
                                                                                shrinkWrap: true,
                                                                                itemCount: features.length,
                                                                                itemBuilder: (context, index) {
                                                                                  return Center(child: Text(features[index]['title']));
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ))
                                                                    ]),
                                                              )
                                                            ])
                                                      ],
                                                    )
                                                  : Center(
                                                      child: Text(
                                                          "Order details unavailable")))
                                          : CircularProgressIndicator();
                                    }),
                              ));
                    },
                    child: Text("View Details"),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      bool response = await ApiFunctionsEditors()
                          .orderConfirmation(false, widget.orderID);
                      //showdialog
                      if (response) {
                        showSuccessDialog(context);
                      } else {
                        showFailDialog(context);
                      }
                    },
                    child: Text("Decline"),
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  showSuccessDialog(context) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
            child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.done,
                        size: 70,
                        color: Colors.green,
                      ),
                      Text("Success"),
                      RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        child: Text("Okay"),
                      )
                    ]))));
  }

  showFailDialog(context) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
            child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.error,
                        size: 70,
                        color: Colors.red,
                      ),
                      Text("Action failed"),
                      RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                        child: Text("Okay"),
                      )
                    ]))));
  }
}
