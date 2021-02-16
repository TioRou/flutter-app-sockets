import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/src/models/band.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Quenn', votes: 1),
    Band(id: '3', name: 'Héroes del silencio', votes: 2),
    Band(id: '4', name: 'Bon Jovi', votes: 5)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, index) =>_bandTile(bands[index]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: ValueKey(band.id),
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.only(left: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {},
      child: ListTile(
            leading: CircleAvatar(
              child: Text(band.name.substring(0,2)),
              backgroundColor: Colors.blue[100],
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
            onTap: () {
              print(band.name);
            },
          ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if(Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('New Band Name'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Add'),
                  isDefaultAction: true,
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  child: Text('Close'),
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context),
                )
              ],
            );
          }
      );
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('New Band Name'),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () => addBandToList(textController.text),
                  child: Text('Add'),
                  elevation: 5,
                  textColor: Colors.blue,
                ),
              ],
            );
          }
      );
    }

  }

  addBandToList(String name) {
    if(name.length > 1){
      setState(() {
        bands.add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      });

    }
    
    Navigator.pop(context);
  }

}
