import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BatchPage extends StatefulWidget {
  final List<String> texts; // Change the variable name to texts

  const BatchPage({Key? key, required this.texts}) : super(key: key);

  @override
  _BatchPageState createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  int _selectedTextIndex = 0; // Change the variable name to _selectedTextIndex

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider(
            items: widget.texts.map((text) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                    ),
                    child: Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
            options: CarouselOptions(
              height: 200.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _selectedTextIndex = index;
                });
              },
            ),
          ),
          SizedBox(height: 20.0),
          Text('Selected Text Index: $_selectedTextIndex'),
          ElevatedButton(
            onPressed: () {
              // Set the selected text as the background (implement your logic here)
              String selectedText = widget.texts[_selectedTextIndex];
              print('Set as background: $selectedText');
            },
            child: Text('Set as Background'),
          ),
        ],
      ),
    );
  }
}
