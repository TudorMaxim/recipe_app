
import 'package:connectivity/connectivity.dart';
import 'package:exam_app/domain/Entity.dart';
import 'package:exam_app/shared/AppState.dart';
import 'package:exam_app/shared/Helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new AddScreenState();
  }
}

class AddScreenState extends State<AddScreen> with AppState {

  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  TextEditingController detailsController = new TextEditingController();
  TextEditingController timeController = new TextEditingController();

  TextEditingController typeController = new TextEditingController();
  TextEditingController ratingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    repository.init();
    connectionListener();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  connectionListener() async {
    bool conn = await checkConnection();
    setState(() {
      connected = conn;
    });
    subscription = Connectivity().onConnectivityChanged.listen((result) async {
      bool connected = result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
      if (connected != this.connected) {
        setState(() {
          this.connected = connected;
        });
      }
    });
  }


  String validator(value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  add(context) async {
    var name = nameController.text;
    var details = detailsController.text;
    var time = timeController.text;
    var type = typeController.text;
    var rating = ratingController.text;

    Entity item = new Entity(
        name: name,
        details: details,
        time: int.parse(time),
        type: type,
        rating: int.parse(rating)
    );
    setState(() {
      isFetching = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    bool connected = await checkConnection();

    if (!connected) {
      showAlertDialog(context, "Error", "You Are offline!");
      setState(() {
        isFetching = false;
      });
      return;
    }

    var response = await service.add(item);
    if (response['status'] == 200) {
      Entity newEntity = Entity.fromMap(response['body']);
      await repository.addFirstTable(newEntity);
      setState(() {
        isFetching = false;
      });
      Navigator.pop(context, newEntity);
    } else {
      showAlertDialog(context, "Error", response['body']['text']);
      setState(() {
        isFetching = false;
      });
      return;
    }
  }

  submit(context) async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState.validate()) {
      await add(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String subtitle = this.connected ? "" : "You are offline";
    return Scaffold(
        appBar: AppBar(
            title: Text('Add a recipe'),
            centerTitle: true,
            bottom: PreferredSize(
              child: Text(subtitle, style: TextStyle(color: Colors.red)),
              preferredSize: null),
        ),
        body: renderWithLoader(this.form(context), isFetching)
    );
  }

  Widget form(context) {
    return Form(
        key: _formKey,
        child: Container (
          margin: const EdgeInsets.only(left: 0.0, right: 0.0),
          child:  Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    hintText: "Name"
                ),
                validator: (value) => this.validator(value),
              ),

              TextFormField (
                controller: detailsController,
                decoration: InputDecoration(
                    hintText: "Details"
                ),
                validator: (value) => this.validator(value),
              ),

              
              TextFormField(
                controller: timeController,
                decoration: InputDecoration(
                    hintText: "Time"
                ),
                validator: (value) => this.validator(value),
              ),

              TextFormField(
                controller: typeController,
                decoration: InputDecoration(
                    hintText: "Type"
                ),
                validator: (value) => this.validator(value),
              ),

              TextFormField(
                controller: ratingController,
                decoration: InputDecoration(
                    hintText: "Rating"
                ),
                validator: (value) => this.validator(value),
              ),

              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Align (
                    alignment: Alignment.center,
                    child: RaisedButton(
                        onPressed: () async =>  await submit(context),
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text('Submit')
                    ),
                  )
              ),
            ],
          ),
        )
    );
  }
}