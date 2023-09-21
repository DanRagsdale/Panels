
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Container holding a reference to a directory
/// Used to allow in place renaming and moving of directories
class DirContainer {
	Directory dir;

	DirContainer(this.dir);

	String get path => dir.path;
	String get fileName => dir.path.split('/').last;
	String get displayName => fileName.split('-*-').last;

	/// Moves the underlying directory to the new name and sets
	/// the directory reference to the new location	
	Future<void> inPlaceRename(String newDispName) async {
		var oldPathList = dir.path.split('/');
		var oldNameList = oldPathList.last.split('-*-');
		
		oldNameList.last = newDispName;

		var newName = oldNameList.join('-*-');
		oldPathList.last = newName;

		var newPath = oldPathList.join('/');

		var newDir = await dir.rename(newPath);
		dir = newDir;
	}
}

Future<String> get _localPath async {
	final directory = await getApplicationDocumentsDirectory();
	return directory.path;
}

/// Return the main storage directory
Future<DirContainer> getMainDir() async {
	final path = await _localPath;
	Directory rawDir = await Directory('$path/note_panels').create(recursive: true);
	return DirContainer(rawDir);
}

/// Return the trashed files storage directory
Future<DirContainer> getTrashDir() async {
	// TODO Implement Trash
	throw UnimplementedError();
}

/// Return the backup files storage directory
Future<DirContainer> getBackupDir() async {
	// TODO Implement Backup
	throw UnimplementedError();
}