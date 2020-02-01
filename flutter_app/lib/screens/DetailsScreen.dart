import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:exam_app/domain/Entity.dart';
import 'package:exam_app/screens/AddScreen.dart';
import 'package:exam_app/shared/AppState.dart';
import 'package:exam_app/shared/Helpers.dart';
import 'package:exam_app/shared/StateManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DetailsScreen extends StatefulWidget {

  final WebSocketChannel channel;
  final String type;

  DetailsScreen({this.channel, this.type}) : super();

  @override
  State<StatefulWidget> createState() {
    return new DetailsScreenState();
  }
}

class DetailsScreenState extends State <DetailsScreen> with AppState {
  String socketMessage = "";

  List <Entity> openItems = List();

  @override
  void initState() {
    super.initState();
    repository.init();
    socketListener();
    connectionListener();
    fetch();
  }

  @override
  void dispose() {
    if (widget.channel != null) {
      widget.channel.sink.close();
    }
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

  socketListener() {
    if (widget.channel != null) {
      widget.channel.stream.listen((data) {
        print(data);
        var map = json.decode(data);
        String message = Entity.fromMap(map).toString();
        setState(() {
          socketMessage = message;
        });
      });
    }

  }

  fetch() async {
    bool connected = await checkConnection();
    setState(() {isFetching = true;});
    await Future.delayed(Duration(milliseconds: 500));
    List <Entity> entities = List();

    if (connected) {
      var response = await service.getAll(widget.type);
      entities = response['body'];

      await repository.clearFirstTable();
      for (Entity e in entities) {
        await repository.addFirstTable(e);
      }
    } else {
      entities = await repository.getAllFirstTable();
    }

    setState(() {
      items = entities;
      isFetching = false;
    });
  }

  refreshScreen() async {
    await fetch();
  }

  deleteEntity(Entity item) async {
    List <Entity> items = StateManager.remove(this.items, item);
    List <Entity> openItems = StateManager.remove(this.openItems, item);
    await repository.deleteFirstTable(item.id);
    await service.delete(item.id);
    setState(() {
      this.items = items;
      this.openItems = openItems;
    });
  }

  goToAddScreen(context) async {

    Entity newEntity = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddScreen()
    ));

    if (newEntity != null) {
      List <Entity> items = StateManager.add(this.items, newEntity);
      setState(() {
        this.items = items;
      });

      if (this.socketMessage.length > 0) {
        showAlertDialog(context, "New Recipe Added", this.socketMessage);
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    String subtitle = this.connected ? "" : "You are offline";

    return new Scaffold(

        appBar: AppBar(
          title: Text(widget.type + " Recipes"),
          centerTitle: true,
          bottom: PreferredSize(
              child: Text(subtitle, style: TextStyle(color: Colors.red)),
              preferredSize: null),
        ),

        body: renderWithLoader(this.appBody(), isFetching),

        floatingActionButton: Padding(
            padding: EdgeInsets.all(0),
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_arrow,
              children: [
                SpeedDialChild(
                    child: Icon(Icons.add),
                    label: "Add",
                    backgroundColor: Colors.yellow,
                    onTap: () => this.goToAddScreen(context)
                ),
//                SpeedDialChild(
//                    child: Icon(Icons.storage),
//                    label: "Fulfilled Requests",
//                    backgroundColor: Colors.red,
//                    onTap: () => this.goToYourEntities(context)
//                )
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
            child: this.listView(this.items),
          )
      ),
      onRefresh: () async => await this.refreshScreen(),
    );
  }

  ListView listView(List<Entity> items) {
    return new ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          if (index < items.length) {
            var item = items[index];
            if (this.connected) {
              return dismissibleItem(item);
            }
            return itemListTile(item);
          }
          return null;
        }
    );
  }

  Dismissible dismissibleItem(Entity item) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => this.deleteEntity(item),
      child: itemListTile(item),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Text('Delete', style: TextStyle(fontSize: 24, color: Colors.white))
          ),
        ),
      ),
    );
  }

  Widget itemListTile(item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        this.itemListTileUp(item),
        Text(item.details.toString(), style: TextStyle(fontSize: 18))
      ],
    );
  }

  Widget itemListTileUp(item) {
    return  ListTile (
        contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
        title: Text(item.name, style: TextStyle(fontSize: 24)),
        subtitle: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
//            Padding(
//                padding: EdgeInsets.only(right: 10),
//                child: Text("Details: " + item.details.toString(), style: TextStyle(fontSize: 18))
//            ),
                Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text("Time: " + item.time.toString(), style: TextStyle(fontSize: 18))
                ),
                Padding(
                    padding: EdgeInsets.only(right: 0),
                    child: Text("Rating: " + item.rating.toString(), style: TextStyle(fontSize: 18))
                )
              ],
            ),
          ],
        )
    );
  }
}