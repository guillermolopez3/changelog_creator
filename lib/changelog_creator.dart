import 'dart:convert';
import 'dart:io';
import 'constants.dart';
import 'package:args/args.dart';

final String currentDir = Directory.current.path;
final File changelogFile = File('$currentDir/CHANGELOG.md');
final List<String> version = [];

void init(List<String> arguments) async{
  final ArgParser parser = ArgParser();
  parser.addFlag(helpFlag, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addOption('repo', abbr: 'r', defaultsTo: defaultGit);//gilab o github
  parser.addOption('branch', abbr: 'b', defaultsTo: defaultBranch);
  final ArgResults argResults = parser.parse(arguments);

  stdout.writeln(introValue);

  if (argResults[helpFlag]) {
    stdout.writeln('Generate changelog creator');
    stdout.writeln(parser.usage);
    exit(0);
  }

  final bool existsFile = await existsCreateFileChangeLog();

  if(!existsFile) exit(0); ///si el archivo no existe o no se pudo crear, termino
  await loadChangelogVersion();

}

///verifica si existe o crea el archivo CHANGELOG si no existe
Future<bool> existsCreateFileChangeLog() async{
  stdout.writeln('---Verificando archivo CHANGELOG.md---');
  if(! await changelogFile.exists()){
    try{
      changelogFile.create();
      stdout.writeln('Archivo CHANGELOG.md creado');
      return true;
    }catch(_){
      stdout.writeln('Error al crear el archivo CHANGELOG.md');
      return false;
    }
  }
  return true;
}

///leo el archivo changelo y obtengo todas las lineas donde aparece el versionado
Future<void> loadChangelogVersion() async{
  RegExp reLineVersion = RegExp(r'^\#\# ([0-9]\d*)\.(\d+)\.(\d+)'); //formato valido: ## 0.0.1
  RegExp reExtractVersion = RegExp(r'([0-9]\d*)\.(\d+)\.(\d+)');
  await changelogFile
      .openRead()
      .map(utf8.decode)
      .transform(new LineSplitter())
      .forEach((l){
    if(reLineVersion.hasMatch(l)){
      version.add(reExtractVersion.stringMatch(l));
      //stdout.writeln('linea: $l');
    }
  });
  //version.forEach((element)=> stdout.writeln('V: $element') );
}

///cuando ya obtengo el versionado, lo modifico en el pubspec.yaml
void setVersionPubspec(String newVersion){
  final File yaml = File('$currentDir/pubspec.yaml');
  if(!yaml.existsSync()) {
    stdout.writeln('no existe el archivo yaml');
    return;
  }
  String content = yaml.readAsStringSync();
  content = content.replaceFirst(new RegExp(r"version: .*"),"version: $newVersion");
  yaml.writeAsStringSync(content);
}

///traigo todas las ramas fusionadas a develop y dejo solo las que sean feature
void getAllBranchMenged() async{
  final ProcessResult gitResult = Process.runSync('git', ["branch","--merged","develop"]);
  final String data = gitResult.stdout.toString();
  String branchFeature;
  LineSplitter.split(data).forEach((line) {
    if(line.contains("feature")){
      //stdout.writeln('Branches mergeadas features: $line');
      branchFeature = line;
    }
  });

  //stdout.writeln('Branches mergeadas features: ${branchFeature.replaceAll(" ", "")}');

}

///Metodo para agregar el nuevo versionado al changelog
void writeChangelog(String data) async{
  String content = changelogFile.readAsStringSync();
  String newContent = '$data\r$content';
  changelogFile.writeAsStringSync(newContent);
}

