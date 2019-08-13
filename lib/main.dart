import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

Future<RssFeed> fetchFeed() async {
  final response =
  await http.get('https://jsg-weidelsburg.de/feed.rss');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return new RssFeed.parse(response.body);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}


class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    setState(() {
      const oneSecond = const Duration(seconds: 25);
      new Timer.periodic(oneSecond, (Timer t) => setState((){}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSG Weidelsburg News',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
            title: Text('JSG Weidelsburg News'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.directions_car),
                onPressed: () {
                },
              )
            ]
        ),
        body: Center(
          child: buildNewsWidget(),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildNewsWidget() {
    return FutureBuilder<RssFeed>(
      future: fetchFeed(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ListTile> widgets = snapshot.data.items.map((e) => new ListTile(
            title: Text(e.title),
            onTap: () => _launchURL(e.link),
          )).toList();
          return new ListView (
              children: widgets);//Text(snapshot.data.title);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }

}
