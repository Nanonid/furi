import "package:unittest/unittest.dart";

import "package:furi/furi.dart";

const String STRDATA = '''my long calculated string
   multiline test data''';

class STest extends ToStringOp {
  String call() => STRDATA;
}

class SMTest extends ToStringOp {
  String value;
  SMTest( this.value );
  String call() => value;
}

class FUriOpTest extends FUriOp {
  String value;
  FUriOpTest( this.value );
  String call(FUri uri_, dynamic key_) => "${value},${key_}";
}

void main(){
  group( "basic Op extension", (){
    test( "ToStringOp", (){
       expect( new STest()(), equals(STRDATA) );
       expect( new SMTest(STRDATA)(), equals(STRDATA) );
       expect( new SMTest("readme example")(), equals("readme example") );
    });
    test( "FUriOp", (){
      expect( new FUriOpTest("readme example")(null,"key"), equals("readme example,key") );
    });
    test( "FUriMapOp", (){
      expect( new FUriMapOp({"k1":"v1","k2":"v2"})(null,null), equals("k1=v1&k2=v2") );
    });
  });
}