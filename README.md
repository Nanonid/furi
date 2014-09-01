#FUri -- the functional URI.

`FUri` exposes the building blocks of the `dart:core` `Uri` but with a functional interface.

`Uri` Path and Query can then be derived, such as accessors or calculated values.

`FUri` also exposes some of the interfaces hidden within `Uri` making it easier to write your own URI class.

`FUri` depends on the `FUriOp` functor class with the signature `String call( FUri uri_, dynamic key_)` to evaluate Query and Path.

`FUri` production depends _only_ on `dart:core`; non-intrusive.

Example:
```dart
class Obj {
  String _value1;
  Obj( this._value1);
  String pathi( int val_ ) => "path${val_}";
  String get value1 => _value1;
  String calcI(int val_) => "value${val_}";
  String query() => "*:*";
  String format() => "json";
}

Obj obj = new Obj("value1");
FUri uri = new FUri( scheme:"http", host:"host", pathSegments:["path1","path2"])
    ..port = 8080
    ..pf( ()=>obj.pathi(3) )
    ..ps( "path4")
    ..qkf("key1",()=>obj.value1)
    ..qkv("key2","value2")
    ..qkf("key3",()=>obj.calcI(3));
uri.qkf( "q", obj.query );
uri.qkf( "wt", obj.format );
expect( uri.uri.toString(), equals("http://host:8080/path1/path2/path3/path4?key1=value1&key2=value2&key3=value3&q=%2A%3A%2A&wt=json") );

```
