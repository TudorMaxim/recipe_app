import 'package:connectivity/connectivity.dart';
import 'package:exam_app/domain/Entity.dart';
import 'package:exam_app/shared/AppState.dart';
import 'package:exam_app/shared/Helpers.dart';
import 'package:exam_app/shared/StateManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RateScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new RateScreenState();
  }
}

class RateScreenState extends State <RateScreen> with AppState {
  String socketMessage = "";

  List <Entity> openItems = List();

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
    List <Entity> entities = List();

    if (connected) {
      var response = await service.getLow();
      entities = response['body'];
      entities = StateManager.getTop(entities);

      await repository.clearFirstTable();
      for (Entity e in entities) {
        await repository.addFirstTable(e);
      }
    } else {
      entities = await repository.getAllFirstTable();
      entities = StateManager.getTop(entities);
    }

    setState(() {
      items = entities;
      isFetching = false;
    });
  }

  refreshScreen() async {
    await fetch();
  }

  rate(context, Entity item) async {
    setState(() {
      isFetching = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    if (this.connected) {
      var response = await service.rate(item);
      if (response['status'] == 200) {
        Entity newEntity = Entity.fromMap(response['body']);
        await repository.updateFirstTable(item.id, newEntity);
        List <Entity> items = StateManager.update(this.items, newEntity);
        setState(() {
          this.items = items;
          isFetching = false;
        });
      } else {
        showAlertDialog(context, "Error", response['body']['text']);
        setState(() {
          isFetching = false;
        });
      }
    } else {
      showAlertDialog(context, "Error", "You must be online in order to rate a recipe");
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String subtitle = this.connected ? "" : "You are offline";

    return new Scaffold(

        appBar: AppBar(
          title: Text("Rate Section"),
          centerTitle: true,
          bottom: PreferredSize(
              child: Text(subtitle, style: TextStyle(color: Colors.red)),
              preferredSize: null),
        ),

        body: renderWithLoader(this.appBody(), isFetching),
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
            return itemListTile(item);
          }
          return null;
        }
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
                Expanded(
                    flex: 3,
                    child: Text("Time: " + item.time.toString(), style: TextStyle(fontSize: 18))
                ),
                Expanded(
                    flex: 3,
                    child: Text("Rating: " + item.rating.toString(), style: TextStyle(fontSize: 18))
                ),
                Expanded(
                    flex: 4,
                    child: RaisedButton(
                      child: Icon(Icons.add),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async => await rate(context, item),
                    )
                )

              ],
            ),
          ],
        )
    );
  }
}