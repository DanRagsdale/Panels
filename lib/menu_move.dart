import 'dart:io';

import 'package:flutter/material.dart';
import 'package:panels/main_menu_data.dart';

import 'io_tools.dart';
import 'main.dart';

/// Simple class allowing an int to be passed by reference
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

	/// Return child (or this) MoveNode at the given index in the tree
	/// Counts recursively, taking into account expanded and unexpanded children
	/// Returns null if no MoveNode exists for the index
	MoveNode? getIndex(int index) {
		return this.getIndexCounter(Counter(index));
	}

	MoveNode? getIndexCounter(Counter index) {
		if (index.value == 0) {
			return this;
		}
		if (!expanded) {
			return null;
		}

		if (childNodes == null) {
			return null;
		}

		for (var c in childNodes!) {
			index.value -= 1;
			var step = c.getIndexCounter(index);
			if (step != null) {
				return step;
			}
		}
		return null;
	}
}

class MenuMove extends StatefulWidget {
	final SelectionMenuData menuData;

	MenuMove(this.menuData);

	@override
	State<MenuMove> createState() => _StateMenuMove();
}

class _StateMenuMove extends State<MenuMove> {

	MoveNode? rootNode;

	@override
	void initState() {
		super.initState();
		buildTree();
	}

	Future<void> buildTree() async {
		rootNode = MoveNode(await getMainDir());
		List<MoveNode> children = await getChildren(rootNode!);
		setState(() {
		  rootNode!.childNodes = children;
			rootNode!.expanded = true;
		});
	}

	MoveNode? _selectedEntry;

	@override
	Widget build(BuildContext context) {
		return Container(
			color: COLOR_BACKGROUND,
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
								if (rootNode == null) {
									return null;
								}
								MoveNode? node = rootNode!.getIndex(index);
								if (node == null) {
									return null;
								}
		
								bool selected = _selectedEntry == node;
		
								return Card(
									margin: EdgeInsets.only(left: 8.0 * node.depth, top: 4.0, bottom: 4.0),
									color: selected ? COLOR_MENU_HOT : COLOR_BACKGROUND_MID,
									child: ListTile(
										contentPadding: EdgeInsets.zero,
										leading: Icon(Icons.folder),
										title: node.depth != 0 ? Text(node.dirCon.displayName) : Text("Home"),
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

	/// Return a list of child MoveNodes corresponding to child directories
	/// Excludes directories that are selected to be moved
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