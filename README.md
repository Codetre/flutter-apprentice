# Flutter
- `pubspec.yaml` 내 `dev_dependencies` 항목은 오로지 개발 단계에서 필요한 패키지를 나열한다.
- `pubspec.yaml` 내 `sqflite: ^2.0.3+1` 더하기 기호는 '빌드'를 의미한다.  
- `services.rootBundle`은 asset 폴 더 내 모든 자원의 참조에 액세스할 수 있다. 파일을 `String` 형태로 읽어들인다.
- `bool MaterialApp.debugShowCheckedModeBanner`: AppBar에 있는 'Debug'란 띠를 없앤다.

## State management
UI = f(state)
state 변화에 따라 UI를 직접 바꾸는 것보다, 상태 변화를 추적해 UI 부분이 이를 감지해 알아서 바뀔 수 있는 일관된 개발 패턴을 정립하는 것이 더 편하다.
이를 '상태 관리'라고 부른다.
- Ephemeral state(UI state): 위젯 상태를 다른 곳에서 액세스하지 않는다.
- app state: 다른 곳에서 위젯의 상태에 접근하게 된다.

### Provider
- `ChangeNotifier`
  - `notifyListeners()`
- `Consumer`
  - `of<T>()`: use when don't need notifications when te dat changes, instead of `Consumer`.
- `ChangeNotifierProvider`: `create` parameter save `ChangeNotifier` instead of re-creating one
- `FutureProvider`
  - `create: (context) => createFuture()` which returns Future<T>
- `MultiProvider`: Use this rather than nesting `Provider`s. 

## Packages
- `sqflite`: give access to database. 
- `sqlbrite`: reactive stream wrapper around sqlite database. It notify changes on database through stream.
- `moor`: you don't need to write SQL code. Write Dart code and this package handles to translate it to SQL.
- `path`: library that helps manipulating file paths.
- `path_provider`: simplifies dealing with common file system locations.
- `synchronized`: helps implement lock mechanisms to prevent concurrent access, when needed.
- `chopper`: advanced networking than `http`
- `drift_sqflite`: refreshed `moor`
- `chopper_generator`: boilerplate code in the form of a part file generator for `chopper`
- `logging`
- `provider`
- `equatable`: provides `equals()`, `toString()`, `hashchode`
- `json_annotation`: JSON -> model을 위해, 생성할 모델 클래스에 annotation을 단다(`@JsonSerializable()`).
- `json_serializable`: annotation에 따라 JSON 파일을 model class로 변환하는 빌더 클래스 코드를 생성한다.
- `build_runner`: Dart 언어를 사용하는 코드를 자동 생성하기 위한 수단을 제공. 모든 코드 생성기(여기선 `json_serializable`)들이 .part file 클래스들을 빌드하기 위해 필요한 패키지
  - `dart run build_runner build --delete-conflicting-errors`: removes the previously created files.
- `shared_preferences` : 디바이스에 저장할 데이터의 키 이름을 설정하고, 데이터를 저장하거나 얻는다. `SharedPreferences.getInstance()`로 호출한 인스턴스가 데이터 액세스의 시작 지점이다.
- `svg_picture`: SVG 그림을 UI에 보여줄 수 있다.
- `cached_network_image` 패키지로 웹에서 가져온 이미지를 잠시 저장해 둘 수 있다.

## Serialize/Deserialize JSON
- 직렬화(Serialize): 메모리 상 객체 구조 -> 송신 가능한 문자열
- 역직렬화(Deserialize): 수신한 문자열 -> 메모리 상 객체 구조
`dart:convert` 패키지에서 `json.decode()`로 `String` -> `Map<String, dynamic>`으로 전환하거나,
`json.encode()`로 `Map<String, dynamic>` -> `String`으로 전환할 수 있지만 여전히 부족하다.
결국에는 `Map`을 `class`로 변환해야 완전한 역직렬화이기 때문이다.
String(fetched data) -> Map(jsonDecode) -> class(serialized)
serialize = stringfy: object -> string
```dart
@JsonSerializable()
class Model {
  int field0;
  @JsonKey(name: 'name_on_json')
  int field1;
}
```

# Project Description
- `main.dart`
- network/
  - `recipe_model.dart`
    - `APIRecipeQuery`는 검색 결과를 모델링한 클래스이다.
      - count는 쿼리로 찾아낸 모든 결과의 수
      - from, to는 그 중에서 현재 Fetching한 범위
- ui/
  - `main_screen.dart`
    - 현재 어느 BottomNavigationBarItem에 머물러 있는지 SharedPreferences로 기억해둔다.
  - recipes/
    - `recipe_list.dart`
      - `MainScreen`의 `BottomNavigationBar` 첫번째 아이템이다.
      - `prefSearchKey`로 검색 이력을 기기에 저장한다.
      - UI는 검색 입력과 검색 결과를 보여주는 두 부분이 수직으로 나열된다.
        - 검색 입력(`_buildSearchCard()`)
        - 검색 결과(`_buildRecipeLoader()`)
    - `recipe_details.dart`: `RecipeCard`를 클릭하면 나타나는 페이지다.
  - `recipe_card.dart`: `APIRecipe`를 하나 받아 관련 정보(명칭, 칼로리 등)를 카드 형태로 표시한다.

# Dart
- `??=`: Assign value to a variable if it is null; otherwise, it stays the same

delegate, delegator: 어떤 작업을 직접 하지 않고, 다른 객체나 메소드에게 위임(delegate)할 때가 있다. 이 경우 그렇게 작업을
위임 받은 객체나 메소드 등을 delegator라고 부른다.
constructor에 쓰이는 `:`은 final 필드도 초기화 할 수 있다. 콤마로 구분된다.
```dart
class Point {
  double x, y;

  Point(this.x, this.y);

  // The main constructor is a delegator for this constructor.
  // It delegates construction to the main constructor.
  Point.alongXAxis(double x): this(x, 0);

}
```
- Square brackets in method signature mean optional parameter(ex: `Future.value([Future<T>? value])`).


라이브러리를 단독 실행할 때: `dart run <library_name> <library_command>`
`Future == Future<dynamic>`이다.

## Asynchronous
async, await, try, catch, 
`yield <event>`
`yield* <Stream>` delegating emit event to another stream.  

## Stream
배달 서비스와 비슷하다. 배달을 10건 시켰고 도착 시 초인종을 누르라고 요청했다고 가정하자. 마지막 배달을 끝내면 그 다음에 배달이 
끝났음을 알리는 특별한 알림 서비스를 배달의 형태로 해준다. 10건이 언제올지는 모르고(비동기) 도착 시 알림을 받는다는 점에서 이벤트를 
받는다는 것과 마찬가지다. 
data event, error event
error event 발생 시 Stream은 중단됨이 기본 동작
- Single subscription stream: 이벤트는 정확한 순서, 누락이 있어선 안된다.  
- 
Stream에 구독자(listener=subscriber)를 연결한 경우 이 구독 상태를 제어할 필요가 있다. 이는 `stream.listen()`가 반환하는 
`StreamSubscription` 객체로 제어 가능하다. 
```dart
void main() {
  Stream<int> stream = Stream.periodic(
    Duration(seconds: 2),
    (i)=> i * i,
  );
  
  final listener = periodic;
  StreamSubscription subscription = stream.listen(listener);
  
  // Wait for a while the listener do some task.
  
  subscription.pause();
}
```

Future가 단일 값 혹은 에러로 결정될 것이지만 아직 결정되지 않은 타입을 나타냈다면, Stream은 그러한 Future의 연속체로 볼 수 있다.
int -> Future<int>
Iterataor<int> -> Stream<int>
리스너가 잡아야 할 데이터 이벤트들을 보내는 것이 스트림의 역할. 데이터 말고도 에러들을 보낼 수도 있다.
앱의 한 부분(위젯)에서 데이터 이벤트를 보내는 동안 다른 곳에서는 그 이벤트들을 청취할 수 있다.
- Single subscription stream
  - 기본 스트림이며, 단일 listener를 지닌다.
  - 리스너가 청취를 시작하기 전에는 이벤트가 발생하지 않고, 리스너가 청취를 그만두면 데이터가 더 남아 있어도 보내지 않고 중단한다.
- Broadcast stream
  - 여러 리스너를 지닐 수 있다.
  - 리스너가 있든 없든 상관 없이 이벤트를 발생시킨다.
  - `singleStream.asBroadcastStream()`으로 생성할 수 있다.
  - 어떤 스트림이 싱글인지 브로드캐스트인지 알려면 `.isBroadcast` 불리언 속성을 확인하면 된다.
`StreamController` has `Stream`, `StreamSink`.
`StreamSink`는 데이터의 목적지다. 컨트롤러는 싱크에 도달한 데이터를 listener에게 전달한다.
`StreamSubscription`, `StreamBuilder`
```dart
// 데이터가 싱크에 도달 -> 컨트롤러는 데이터를 스트림으로 보낸다 -> 스트림은 구동 중인 리스너에게 데이터를 보낸다.
final controller = StreamController<TypeOfData>();
controller.sink.add(dataFromNetwork); 

StreamSubscription subscription = stream.listen((valueFromSink) {
  // Rebuild a widget.
  setState(() => widgetProperty = valueFromSink);
});

// Widget destroyed.
subscription.cancel();
controller.close();
```

그렇지만 이러한 과정을 `FutureBuilder`처럼 편리하게 작성할 수 있다.
```dart
final provider = Provider.of<Repository>(context, listen: false);
// Build UI by the stream.
return StreamBuilder<List<Recipe>>(
  stream: repository.recipeStream(),
  builder:(context, AsyncSnapshot<List<Recipe>> snapshot){

  },
);
```

## Mixin(믹스인)
class A, B, C가 있고 이들의 상속형 ExtendedA,ExtendedB, ExtendedC가 있다고 하자.
그런데 확장된(=상속된) 클래스들을 보니, 동일한 기능들을 추가하기 위해 확장됐음을 알게 됐다.
이 경우 EA, EB, EC는 기능은 공통이겠지만 코드는 각자 따로 구현돼 있으니 변경이 생기면 모두 세 번 코드를 수정해야 한다.
이럴 바에야 차라리 기능만을 담은 클래스를 하나 만들고 A, B, C에 이 기능을 끼워 넣는 방식을 사용하면 
기능을 담은 클래스 한 곳만을 수정하는 이점이 있다. 이 기능을 담은 클래스를 'Mixin class'라 하며 믹스인 클래스를 필요로 하는 
클래스에 믹스인 클래스를 끼워 넣기 위해서는 `with` 키워드를 사용한다. `FuncNeedCls with Mixin` 이렇게 말이다. 

## `library`, `part`, `part of` directives
library file has lines
- `libarry <name>`
- `part <path/to/part_file.dart`
part file has lines
- `part of <path/to/library_file.dart`

### `library` directive
The import and library directives can help you create a modular and shareable code base. 
Libraries not only provide APIs, but are a unit of privacy: identifiers that start with an 
underscore (_) are visible only inside the library. Every Dart file (plus its parts) is a library, 
even if it doesn’t use a library directive.

library를 사용하려면 `import '<scheme>:<package_name>'` 같이 쓴다. scheme에는 dart, package, file system 등이 온다.

- 복수의 라이브러리에 동일한 식별자가 존재한다면 namespace 문제를 해결하기 위해 라이브러리에 prefix를 붙일 수 있다.
```dart
import 'dart:developer' as dev;
import 'dart:math';
void main() {
  dev.log('Log2(3)');  // debugging logger.
  log(3); // mathematical logarithmic function.
}
```

- 라이브러리에서 특정 부분만 가져오거나 반대로 특정 부분만 가려서 가져오고 싶을 때는: `show`, `hide`
```dart
import 'package:mylib/mylib.dart' show Element;
import 'package:mylib/mylib.dart' hide Element;
```

- 실제 쓰일 때 비로소 라이브러리 가져오기: `deferred as`(Only for web: `dart compile js`)
웹 앱에서 첫 로딩이 너무 길어지는 것을 막기 위해 지연 임포트를 하는 경우가 있고 이를 Dart에서도 실현할 수 있다.
```dart
import 'package:mylib/mylib.dart' deferred as lib;

Future<void> load() async {
  await lib.loadLibrary();
  lib.method();
}
```
