import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
	bool isClicked = false;
	
	@override
  Widget build(BuildContext context) {
    return Scaffold(
			appBar: AppBar(
				title: const Text("Hello from the other page!"),
			),
			body: GestureDetector(
				onTap: () {
					setState(() {
						isClicked = !isClicked;
					});
				},
				child: isClicked ? 
					Image.asset("images/aurora.jpg") :
					Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/NGC_4414_%28NASA-med%29.jpg/726px-NGC_4414_%28NASA-med%29.jpg"),
			),
		);
  }
}