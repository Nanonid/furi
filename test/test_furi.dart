import "package:unittest/unittest.dart";

import "package:furi/furi.dart";

class TestObj {
  String _value1;
  String _value2;
  TestObj( this._value1, this._value2 );
  
  String pathi( int val_ ) => "path${val_}";
  String get value1 => _value1;
  String get value2 => _value2;
  String get value3 => "value3";
  String calc4() => "value4";
  String calcI(int val_) => "value${val_}";
  String query() => "*:*";
  String format() => "json";
}

class Obj {
  String _value1;
  Obj( this._value1);
  String pathi( int val_ ) => "path${val_}";
  String get value1 => _value1;
  String calcI(int val_) => "value${val_}";
  String query() => "*:*";
  String format() => "json";
}

void main(){
  group( "fluent", (){
    test( "string path ops", (){
      FUri uri = new FUri( scheme:"http")
        ..ps("path1")
        ..ps("path2")
        ;
      int i = 1;
      uri.pathSegments.forEach( (p){
        expect( p, equals("path${i}"));
        i+=1;
      });
      expect( uri.uri.toString(), equals("http:path1/path2") );
    });
    test( "string path/query ops", (){
      FUri uri = new FUri( scheme:"http")
        ..ps("path1")
        ..ps("path2")
        ..qkv("key1","value1")
        ..qkv("key2","value2")
        ;
      int i = 1;
      uri.pathSegments.forEach( (p){
        expect( p, equals("path${i}"));
        i+=1;
      });
      i = 1;
      uri.queryP.forEach( (k,p){
        expect( p(uri,k), equals("value${i}"));
        i+=1;
      });
      expect( uri.uri.toString(), equals("http:path1/path2?key1=value1&key2=value2") );
    });
    test( "object path/query ops", (){
      TestObj obj = new TestObj("value1","value2");
      FUri uri = new FUri( scheme:"http", host:"host", port:100, pathSegments:["path1","path2"])
        ..pf( ()=>obj.pathi(3) )
        ..qkf("key1",()=>obj.value1)
        ..qkf("key2",()=>obj.value2)
        ..qkf("key3",()=>obj.value3)
        ..qkf("key4",obj.calc4)
        ..qkf("key5",()=>obj.calcI(5))
        ..qkf("key6",()=>obj.calcI(6))
        ;
      int i = 1;
      uri.pathSegments.forEach( (p){
        expect( p, equals("path${i}"));
        i+=1;
      });
      i = 1;
      uri.queryP.forEach( (k,p){
        expect( p(uri,k), equals("value${i}"));
        i+=1;
      });
      uri.qkf( "q", obj.query );
      uri.qkf( "wt", obj.format );
      expect( uri.uri.toString(), equals("http://host:100/path1/path2/path3?key1=value1&key2=value2&key3=value3&key4=value4&key5=value5&key6=value6&q=%2A%3A%2A&wt=json") );
    });
    
    test( "the readme example", (){
      Obj obj = new Obj("value1");
      FUri uri = new FUri( scheme:"http", host:"host", pathSegments:["path1","path2"])
        ..port = 8080
        ..pf( ()=>obj.pathi(3) )
        ..ps( "path4")
        ..qkf("key1",()=>obj.value1)
        ..qkv("key2","value2")
        ..qkf("key3",()=>obj.calcI(3))
        ;
      uri.qkf( "q", obj.query );
      uri.qkf( "wt", obj.format );
      expect( uri.uri.toString(), equals("http://host:8080/path1/path2/path3/path4?key1=value1&key2=value2&key3=value3&q=%2A%3A%2A&wt=json") );
    });
    
  });
  
}