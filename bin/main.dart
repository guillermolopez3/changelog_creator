import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import '../lib/changelog_creator.dart' as changelog;

final String currentDir = Directory.current.path;
final changelogFile = File('$currentDir/CHANGELOG.md');
final List<String> version = [];

void main(List<String> arguments) async{
  changelog.init(arguments);
}
