import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/src/services/socket_service.dart';
import 'package:band_names/src/models/band.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'Queen', votes: 1),
    // Band(id: '3', name: 'Héroes del silencio', votes: 2),
    // Band(id: '4', name: 'Bon Jovi', votes: 5)
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List)
        .map((band) => Band.fromMap(band))
        .toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: (socketService.serverStatus == ServerStatus.Online)
            ? Icon(Icons.check_circle, color: Colors.blue[300],)
            : Icon(Icons.check_circle, color: Colors.red[300],)
          ),
        ],
      ),
      body: Column(
        children: [
          _mostrarGrafica(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) =>_bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

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
      onDismissed: (_) => socketService.socket.emit('delete-band', {'id': band.id}),
      child: ListTile(
            leading: CircleAvatar(
              child: Text(band.name.substring(0,2)),
              backgroundColor: Colors.blue[100],
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
            onTap: () => socketService.socket.emit('vote-band', {'id' : band.id}),
          ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if(Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
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
          )
      );

    } else {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
          )
      );
    }

  }

  addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if(name.length > 1){
      // setState(() {
      //   bands.add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      // });

      socketService.socket.emit('add-band', {'name': name});

    }
    
    Navigator.pop(context);
  }

  Widget _mostrarGrafica() {
    Map<String, double> dataMap = new Map();
//    dataMap.putIfAbsent('Flutter', () => 5);

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
      child: PieChart(
        dataMap: dataMap,
        chartValuesOptions: ChartValuesOptions(
          showChartValuesInPercentage: true
        ),
      ),
      width: double.infinity,
      height: 200.0,
    );
  }

}
