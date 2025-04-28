import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  String url;
  ImageScreen(this.url);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.white)
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Image.network(
          this.widget.url,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
