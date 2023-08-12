# Flutter
pubspec.yaml 내 dev_dependencies 항목은 오로지 개발 단계에서 필요한 패키지를 나열한다. 
Packages
- json_serializable
- json_annotation
- build_runner: Dart 언어를 사용하는 코드를 자동 생성하기 위한 수단을 제공. 
    모든 코드 생성기들이 .part file 클래스들을 빌드하기 위해 필요한 패키지
`services.rootBundle` is the top-level property that holds references to all the items in the asset 
folder. This loads the file as a string.

# Project Description


# Serialize/Deserialize JSON
json_annotation, json_serializable을 사용해서 구문 분석을 할 수 있다.
dart:convert 패키지에서 json.decode()로 String -> Map<String, dynamic>으로 전환하거나,
json.encode()로 Map<String, dynamic> -> String으로 전환할 수 있지만 여전히 부족하다. 
결국에는 Map을 class로 변환해야 하기 때문이다. 
String -> Map -> class
json_annotation으로 제공한 annotation에 따라 json_serializable이 JSON 파일을 model class로 변환한다. 
json_annotation은 모델 클래스에 annotation을 단다.

# JSON serialize
serialize = stringfy: object -> string

- json_annotation: write annotations for JSON -> model 
- json_serializable

```dart
@JsonSerializable
class Model {
  int field0;
  @JsonKey
  int field1;
}
```


# Dart
라이브러리를 단독 실행할 때: `dart run <library_name> <library_command>`

## `library`, `part`, `part of` directives
library file has lines
- `libarry <name>`
- `part <path/to/part_file.dart`
part file has lines
- `part of <path/to/library_file.dart`

## `library` directive
The import and library directives can help you create a modular and shareable code base. 
Libraries not only provide APIs, but are a unit of privacy: identifiers that start with an 
underscore (_) are visible only inside the library. Every Dart file (plus its parts) is a library, 
even if it doesn’t use a library directive.

library를 사용하려면 import 'dart:html' 같이 쓴다. scheme: dart, package, file system

복수의 라이브러리에 동일한 식별자가 존재한다면 namespace 문제를 해결하기 위해 라이브러리에 prefix를 붙일 수 있다.
```dart
import 'package:mylib1/mylib1.dart' as lib1;
import 'package:mylib2/mylib2.dart' as lib2;

lib1.Element el1 = lib1.Element();
lib2.Element el2 = lib2.Element();
```

라이브러리에서 특정 부분만 가져오거나 반대로 특정 부분만 가려서 가져오고 싶을 때는: `show`, `hide`
```dart
import 'package:mylib/mylib.dart' show Element;
import 'package:mylib/mylib.dart' hide Element;
```

실제 쓰일 때 비로소 라이브러리 가져오기: `deferred as`
웹 앱에서 첫 로딩이 너무 길어지는 것을 막기 위해 지연 임포트를 하는 경우가 있고 이를 Dart에서도 실현할 수 있다.
대신 이 기능은 `dart compile js`로 컴파일하는 경우만 가능하다.
```dart
import 'package:mylib/mylib.dart' deferred as lib;

Future<void> load() async {
  await lib.loadLibrary();
  lib.method();
}
```
