import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panels/main_menu_data.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class Counter {
	int value;

	Counter(this.value);
}

class MoveNode {
	bool expanded = false;
	List<MoveNode>? childNodes;

	DirContainer dirCon;
	int depth;

	MoveNode(this.dirCon, {this.depth = 0});

	MoveNode? getIndex(Counter index) {
		if (index.value == 0) {
			return this;
		}
		if (!expanded) {
			return null;
		}

		// TODO properly handle unpopulated list of ChildNodes
		if (childNodes == null) {
			return null;
		}

		for (var c in childNodes!) {
			index.value -= 1;
			var step = c.getIndex(index);
			if (step != null) {
				return step;
			}
		}
		return null;
	}
}

class MoveTree {
	MoveNode rootNode;

	MoveTree(this.rootNode);

	MoveNode? getNode(int index) {
		return rootNode.getIndex(Counter(index));
	}
}

class MenuMove extends StatefulWidget {
	final SelectionMenuData menuData;

	MenuMove(this.menuData);

	@override
	State<MenuMove> createState() => _StateMenuMove();
}

class _StateMenuMove extends State<MenuMove> {

	MoveTree? tree;

	@override
	void initState() {
		super.initState();
		buildTree();
	}

	Future<void> buildTree() async {
		MoveNode rootNode = MoveNode(await _getRootDir());
		tree = MoveTree(rootNode);
		List<MoveNode> children = await getChildren(rootNode);
		setState(() {
		  rootNode.childNodes = children;
			rootNode.expanded = true;
		});
	}

	MoveNode? _selectedEntry;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(4.0),
			child: Column(
				children: [
					const Text(
						"Move Items",
						style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
					),
					Expanded(
						//width: double.maxFinite,
						child: ListView.builder(
							itemBuilder: (context, index) {
								if (tree == null) {
									return null;
								}
								MoveNode? node = tree!.getNode(index);
								if (node == null) {
									return null;
								}
		
								bool selected = _selectedEntry == node;
		
								return Card(
									margin: EdgeInsets.only(left: 8.0 * node.depth, top: 4.0, bottom: 4.0),
									color: selected ? COLOR_BACKGROUND_HEAVY : Colors.white,
									child: ListTile(
										contentPadding: EdgeInsets.zero,
										leading: Icon(Icons.folder),
										title: Text(node.dirCon.displayName),
										trailing: IconButton(
											icon: Icon(node.expanded ? Icons.expand_less : Icons.expand_more),
											onPressed: () {
												setState(() {
													node.expanded = !node.expanded;
												});
												if (node.childNodes == null) {
													getChildren(node).then((value) {
														setState(() {
															node.childNodes = value;
														});
													});
												}
											},
										),
										onTap: () {
											setState(() {
												if (selected) {
													_selectedEntry = null;
												} else {
													_selectedEntry = node;
												}
											});
										},
									),
								);
							},
						),
					),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceEvenly,
						children: [
							TextButton(
								onPressed: () => Navigator.pop(context, null),
								child: const Text('Cancel'),
							),
							TextButton(
								onPressed: () => Navigator.pop(context, _selectedEntry?.dirCon),
								child: const Text('OK'),
							),
						],
					),
				],
			),
		);
	}

	// TODO eliminate duplicate IO Code with main menu	
	Future<String> get _localPath async {
		final directory = await getApplicationDocumentsDirectory();
		return directory.path;
	}

	Future<DirContainer> _getRootDir() async {
		final path = await _localPath;
		Directory rawDir = await Directory('$path/note_panels').create(recursive: true);
		return DirContainer(rawDir);
	}

	// Main IO functions
	Future<List<MoveNode>> getChildren(MoveNode node) async {
		List<MoveNode> children = [];
		try {
			final dirCon = node.dirCon;
			final entities = await dirCon.dir.list().toList();
			final Iterable<Directory> dirs = entities.whereType<Directory>();
			//final Iterable<File> files = entities.whereType<File>();

			for (var d in dirs) {
				if (!widget.menuData.isSelectedDir(d)){
					children.add(MoveNode(DirContainer(d), depth: node.depth + 1));
				}
			}
		} catch (e) {}

		return children;
	}
}