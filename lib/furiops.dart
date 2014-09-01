
part of furi;

/**
 * Functor signature for return a String representation.
 */
abstract class ToStringOp implements Function {
  String call();
}

/**
 * FUri functor signature that returns a String representation
 * given a FUri and some dynamic key.
 * For Path, key is an integer.
 * For Query, key *may* the query parameter key.
 * However, because the query parameters may have repeated keys,
 * the map collection design should not be forced.
 */
abstract class FUriOp implements Function {
  String call( FUri uri_, dynamic key_ );
}

/**
 * SQuriOp holds and evals() to a public String value.
 * Used as default paths() implementation via ps();
 */
class SFUriOp extends FUriOp {
  String value;
  SFUriOp( this.value );
  String call( FUri uri_, dynamic key_ ){
    return value;
  }
}

/**
 * F0FUriOp call a 0 arg function.
 */
class F0FUriOp extends FUriOp {
  var func;
  F0FUriOp( this.func );
  String call( FUri uri_, dynamic key_ ){
    return _emptyNullToString( func() );
  }
}

/**
 * FUriMapOp arbitrary toString Query mapping, not Path.
 */
class FUriMapOp extends FUriOp {
  Map _map;
  FUriMapOp( this._map );
  Map<String,String> reduce(FUri uri_){
    Map<String,String> reduced = new Map<String,String>();
    _map.forEach( (k,v) => reduced.putIfAbsent(
        _emptyNullToString(k), ()=> _emptyNullToString(v)) );
    return reduced;
  }
  String call( FUri uri_, dynamic key_ ){
    if( _map == null || _map.isEmpty ){
      return null;
    }
    return FUri.makeQuery( reduce(uri_) );
  }
}

/**
 * KVFUriMap collection of FUriOp for Query mapping, not Path.
 */
class KVFUriMap<TKey> extends MapMixin<TKey,FUriOp> with FUriOp {
  Map<TKey,FUriOp> _map = new Map<TKey,FUriOp>();
  KVFUriMap();
  KVFUriMap.fromMap( this._map );
  Map<String,String> reduce(FUri uri_){
    Map<String,String> reduced = new Map<String,String>();
    _map.forEach( (k,op) => reduced.putIfAbsent(k.toString(), ()=>op(uri_,k)) );
    return reduced;
  }
  String call( FUri uri_, dynamic key_ ){
    if( isEmpty ){
      return null;
    }
    return FUri.makeQuery( reduce(uri_) );
  }
  Iterable<TKey> get keys => _map.keys;
  FUriOp operator[](Object key_) => _map[key_];
  operator []=(TKey key_, FUriOp value_) => _map[key_] = value_;
  FUriOp remove(Object key_) => _map.remove(key_);
  void clear() => _map.clear();
}

class SVFUriMap extends KVFUriMap<String>{
  SVFUriMap() : super.fromMap( new Map<String,FUriOp>() );
  SVFUriMap.fromMap( Map<String,FUriOp> map ): super.fromMap(map);
  SVFUriMap.fromSDMap( Map<String,dynamic> ssmap_ ){
    addSMap(ssmap_);
  }
  SVFUriMap.fromSSMap( Map<String,String> ssmap_ ){
    ssmap_.forEach( (k,v) => putIfAbsent(k,()=>new SFUriOp(v)) );
  }
  
  void addSMap(Map<String, dynamic> other) {
    for (String key in other.keys) {
      this[key] = other[key];
    }
  }
  
  operator []=(String key_, dynamic value_) {
    if( value_ is String ){
      return putIfAbsent(key_, ()=> new SFUriOp(value_));
    }
    if( value_ is FUriOp ) {
      return super._map[key_] = value_;
    }  
    throw new ArgumentError("Value must be a FUriOp");
  }
}

/**
 * JSFUriOp
 */
String _emptyNullToString( dynamic value_ ){
  if( value_ == null ) return "";
  try{
    return value_.toString();
  }catch( e ){
    return "";
  }
}
