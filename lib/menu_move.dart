import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class Counter {
	int value;

	Counter(this.value);
}

class MoveNode {
	bool expanded = false;
	List<MoveNode> childNodes = [];

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

		for (var c in childNodes) {
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

	void add(MoveNode node) {
		rootNode.childNodes.add(node);
	}

	MoveNode? getNode(int index) {
		return rootNode.getIndex(Counter(index));
	}
}

class MenuMove extends StatefulWidget {
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

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.maxFinite,
			child: ListView.builder(
				itemBuilder: (context, index) {
					if (tree == null) {
						return null;
					}
					MoveNode? node = tree!.getNode(index);
					if (node == null) {
						return null;
					}
					
					return ListTile(
						contentPadding: EdgeInsets.zero,
						title: Row(
							mainAxisAlignment: MainAxisAlignment.start,
							children: [
								SizedBox(width: 6.0 * node.depth,),
 								Text(node.dirCon.displayName),
							],
						),
						trailing: IconButton(
							icon: Icon(node.expanded ? Icons.expand_less : Icons.expand_more),
							onPressed: () {
								setState(() {
								  node.expanded = !node.expanded;
									getChildren(node).then((value) {
										setState(() {
											node.childNodes = value;
										});
									});
								});
							},
						),
					);
				},
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
				children.add(MoveNode(DirContainer(d), depth: node.depth + 1));
			}
		} catch (e) {}

		return children;
	}
}