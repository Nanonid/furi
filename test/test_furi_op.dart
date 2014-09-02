import "package:unittest/unittest.dart";

import "package:furi/furi.dart";

class STest extends ToStringOp {
  String call() => "my calculated string";
}

void main(){
  group( "basic Op extension", (){
    test( "ToStringOp", (){
       expect( new STest()(), equals("my calculated string") );
    });
  });
}