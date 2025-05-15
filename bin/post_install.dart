// tool/post_install.dart
import 'dart:io';

void main() {
  print('Add feature_generator to PATH? [Y/n]');
  final input = stdin.readLineSync()?.toLowerCase();
  if (input != null && input != 'y' && input.isNotEmpty) exit(0);

  final configFile = _getShellConfigFile();
  final exportCommand = _getExportCommand();

  if (_pathAlreadyExists(configFile)) {
    print('PATH already configured!');
    exit(0);
  }

  try {
    File(configFile).writeAsStringSync(exportCommand, mode: FileMode.append);
    print('Updated $configFile ✓');
    print('Restart your terminal or run: source $configFile');
  } catch (e) {
    stderr.writeln('Error: Failed to update $configFile');
    exit(1);
  }
}

String _getShellConfigFile() {
  if (Platform.isWindows) {
    return _getWindowsPath();
  }

  final shell = Platform.environment['SHELL']?.split('/').last ?? 'bash';
  switch (shell) {
    case 'zsh':
      return Platform.environment['ZDOTDIR'] ?? '${Platform.environment['HOME']}/.zshrc';
    case 'fish':
      return '${Platform.environment['HOME']}/.config/fish/config.fish';
    default:
      return '${Platform.environment['HOME']}/.bashrc';
  }
}

String _getExportCommand() {
  if (Platform.isWindows) {
    return '\n\$env:Path += ";${Platform.environment['USERPROFILE']}\\.pub-cache\\bin"';
  }
  return '\nexport PATH="\$PATH:\$HOME/.pub-cache/bin"';
}

String _getWindowsPath() {
  final powerShellProfile = Platform.environment['PROFILE'] ?? 
    '${Platform.environment['USERPROFILE']}\\Documents\\WindowsPowerShell\\Microsoft.PowerShell_profile.ps1';
  
  if (File(powerShellProfile).existsSync()) return powerShellProfile;
  return '${Platform.environment['USERPROFILE']}\\.bashrc';
}

bool _pathAlreadyExists(String configFile) {
  final content = File(configFile).readAsStringSync();
  return content.contains('.pub-cache/bin');
}