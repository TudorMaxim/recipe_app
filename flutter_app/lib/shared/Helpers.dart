import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

Widget renderWithLoader(Widget body, isFetching) {
  return Visibility(
    visible: isFetching,
    child: Center (
      child: CircularProgressIndicator(),
    ),
    replacement: body,
  );
}

checkConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

void showAlertDialog(BuildContext context, String title, String message) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title),
        content: new Text(message),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
