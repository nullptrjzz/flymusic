final RegExp extractFile = RegExp('[/\\\\]+');
final allowedMusicExt = ['.mp3', '.flac', '.ape', '.wav', '.wma', '.mpeg', '.aiff', '.aac'];
final allowedPicExt = ['.jpg', '.jpeg', '.bmp', '.png', '.webp'];

String fileName(String file) {
  return file.split(extractFile).lastWhere((element) => element != null
      && element.isNotEmpty);
}

String fileNameWithoutExt(String file) {
  String name = fileName(file);
  return name.contains('.') ? name.substring(0, name.lastIndexOf('.')) : name;
}

String fileExt(String file, [bool keepDot = true]) {
  String name = fileName(file);
  if (name.contains('.')) {
    return name.substring(name.lastIndexOf('.') + (keepDot ? 0 : 1));
  }
  return "";
}

bool match(String a, String b) {
  String nameA = fileName(a);
  String nameB = fileName(b);
  return nameA.toLowerCase() != nameB.toLowerCase() &&
      fileNameWithoutExt(a).toLowerCase() == fileNameWithoutExt(b).toLowerCase();
}

bool isMusic(String file) {
  return allowedMusicExt.contains(fileExt(file).toLowerCase());
}

bool isPicture(String file) {
  return allowedPicExt.contains(fileExt(file).toLowerCase());
}