import 'dart:io';

final String currentDir = Directory.current.path;
final changelogFile = File('$currentDir/CHANGELOG.md');

void main(List<String> arguments) async{

  stdout.writeln('--BIENVENIDO A CHANGELOG CREATOR!--');
  createFileChangeLog();
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

