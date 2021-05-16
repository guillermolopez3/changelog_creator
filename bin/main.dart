import 'dart:convert';
import 'dart:io';



final String currentDir = Directory.current.path;
final changelogFile = File('$currentDir/CHANGELOG.md');
final List<String> version = [];

void main(List<String> arguments) async{

  exitCode = 0;
  /*final parser = ArgParser()
    ..addOption('repo', abbr: 'r', defaultsTo: 'gitlab');//gilab o github
  final argResults = parser.parse(arguments);*/

  stdout.writeln('--BIENVENIDO A CHANGELOG CREATOR--');
  //createFileChangeLog();
  //readChange();
  setVersionPubspec();
}

///crea el archivo CHANGELOG si no existe
void createFileChangeLog() async{
  stdout.writeln('---Verificando archivo CHANGELOG.md---');
  if(! await changelogFile.exists()){
    try{
      changelogFile.create();
      stdout.writeln('Archivo CHANGELOG.md creado');
      await changelogFile.writeAsString('# Changelog');
    }catch(_){
      stdout.writeln('Error al crear el archivo CHANGELOG.md');
    }
  }
}

void readChange() async{
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

  version.forEach((element)=> stdout.writeln('V: $element') );

}

//modifico el versionado del pubspec.yaml
void setVersionPubspec(){
  final File yaml = File('$currentDir/pubspec.yaml');
  if(!yaml.existsSync()) {
    stdout.writeln('no existe el archivo yaml');
    return;
  }
  String content = yaml.readAsStringSync();
  content = content.replaceFirst(new RegExp(r"version: .*"),"version: 0.2.0");
  yaml.writeAsStringSync(content);
}