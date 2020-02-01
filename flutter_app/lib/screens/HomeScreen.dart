import 'package:connectivity/connectivity.dart';
import 'package:exam_app/screens/RateScreen.dart';
import 'package:exam_app/screens/DetailsScreen.dart';
import 'package:exam_app/shared/AppState.dart';
import 'package:exam_app/shared/Helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:web_socket_channel/io.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> with AppState {

  List <dynamic> types = List();

  @override
  void initState() {
    super.initState();
    repository.init();
    connectionListener();
    fetch();
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


  fetch() async {
    bool connected = await checkConnection();
    setState(() {isFetching = true;});
    await Future.delayed(Duration(milliseconds: 500));
    List <dynamic> types = List();

    if (connected) {
      var response = await service.getTypes();
      types = response['body'];
      await repository.clearSecondTable();
      for (String s in types) {
        await repository.addSecondTable(s);
      }
    } else {
      types = await repository.getAllSecondTable();
    }

    setState(() {
      this.types = types;
      isFetching = false;
    });
  }


  refreshScreen() async {
    await fetch();
  }

  goToRateScreen(context) async {
    if (this.connected) {
      await Navigator.push(context, MaterialPageRoute(
          builder: (context) => RateScreen()
      ));
    } else {
      showAlertDialog(context, "Error", "You must me online in order to visit the rating section!");
    }
  }

  goToDetails(context, item) async {
    String type = item.toString();
    var channel;
    if (this.connected) {
      channel = IOWebSocketChannel.connect('ws://10.0.2.2:2201');
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          type: type,
          channel: channel
        )
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    String subtitle = this.connected ? "" : "You are offline";
    Widget body = this.appBody();
    return new Scaffold(

        appBar: AppBar(
          title: Text("Recipe Types"),
          centerTitle: true,
          bottom: PreferredSize(
              child: Text(subtitle, style: TextStyle(color: Colors.red)),
              preferredSize: null),
        ),

        body: renderWithLoader(body, this.isFetching),

        floatingActionButton: Padding(
            padding: EdgeInsets.all(0),
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_arrow,
              children: [
                SpeedDialChild(
                    child: Icon(Icons.verified_user),
                    label: "Rate Section",
                    backgroundColor: Colors.yellow,
                    onTap: () => this.goToRateScreen(context)
                ),
              ],
            )
        )
    );
  }

  appBody() {
    return RefreshIndicator(
      child: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Container(
            child: this.listView(),
          )
      ),
      onRefresh: () async => await this.refreshScreen(),
    );
  }

  ListView listView() {
    return new ListView.builder(
        itemCount: this.types.length,
        itemBuilder: (context, index) {
          if (index < this.types.length) {
            var item = this.types[index];
//            if (this.connected) {
//              return dismissibleItem(item);
//            }
            return itemListTile(item);
          }
          return null;
        }
    );
  }


  ListTile itemListTile(item) {
    return  ListTile (
        contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
        title: Text(item, style: TextStyle(fontSize: 24)),
        onTap: () => goToDetails(context, item)
    );
  }
}