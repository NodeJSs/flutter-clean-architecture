import 'dart:io';
import 'package:path/path.dart' as p;


String fixture(String name) => File(p.join(p.current,"test", "fixtures", name )).readAsStringSync();