library furi;
/**
 * FUri -- the functional URI.
 * FUri exposes the building blocks of the core URI but with a
 * functional interface.
 * Values of the URI can then be derived, such as accessors or calculated.
 * 
 * TODO provide Map/List mixin for query parameters with repeating keys.
 */

import 'dart:convert';
import 'dart:collection';

part 'furiops.dart';


class FUri extends ToStringOp {
  
  String call() {
     return uri.toString();
  }
  
  Uri get uri => build();
  /**
   * build URI on demand, but do not use queryParameters which is always a map.
   */
  Uri build(){
    Uri uri = new Uri( scheme:scheme, userInfo:userInfo, host:host,
        port:port, pathSegments:pathSegments,
        query:query,
        queryParameters:null, fragment:fragment );
    return uri;
  }

  /**
   * arbitrary URI state.
   */
  Map _state = new Map();
  Map get state => _state;
  void set state( Map state_ ){
    _state = state_;
  }
 
  String _scheme;
  String get scheme => _scheme;
  void set scheme( String scheme_ ) {
    _scheme = scheme_;
  }
  
  String _userInfo;
  String get userInfo => _userInfo;
  void set userInfo( String userInfo_ ){
    _userInfo = userInfo_;
  }
  
  String _authority;
  String get authority => _authority;
  void set authority( String authority_ ){
    _authority = authority_;
  }
  
  String _host;
  String get host => _host;
  void set host( String host_ ){
    _host = host_;
  }
  
  int _port;
  int  get port => _port;
  void set port( int port_ ){
    _port = port_;
  }
  
  String get path => makePath(pathSegments, true, false);
  
  FUriOp ps( String pathseg_ ){
    FUriOp res = new SFUriOp(pathseg_);
    paths.add( res );
    return res;
  }
  
  FUriOp pf( String func_() ){
    FUriOp res = new F0FUriOp(func_);
    paths.add( res );
    return res;
  }
  FUriOp p( FUriOp res ){
    paths.add( res );
    return res;
  }
  
  List<FUriOp> _paths = new List<FUriOp>();
  List<FUriOp> get paths => _paths;
  void set paths( List<FUriOp> paths_ ){
    _paths = paths_;
  }
  
  Iterable<String> get pathSegments{
    int i = 0;
    return paths.map( (op) => op(this,i++) );
  }
  
  FUriOp _queryOp;
  FUriOp get queryOp => _queryOp;
  void set queryOp( FUriOp op_ ){
    _queryOp = op_;
  }
  String get query => (_queryOp==null?null:_queryOp.call(this,null));
  List<FUriOp> get queries => (_queryOp is List)?_queryOp:null;
  Map<String,FUriOp> get queryP => (_queryOp is Map)?_queryOp:null;
  
  FUriOp qk( String key_, FUriOp value_ ){
    if( _queryOp == null ){
      _queryOp = new SVFUriMap();
    }
    if( _queryOp is Map){
      SVFUriMap qmap = _queryOp as SVFUriMap;
      return qmap.putIfAbsent(key_, ()=>value_ );
    }
    throw new ArgumentError("Query Op is not a supported map for this method");
  }
  
  FUriOp qkv( String key_, String value_ ){
    if( _queryOp == null ){
      _queryOp = new SVFUriMap();
    }
    if( _queryOp is Map){
      SVFUriMap qmap = _queryOp as SVFUriMap;
      return qmap.putIfAbsent(key_, ()=>new SFUriOp(value_) );
    }
    throw new ArgumentError("Query Op is not a supported map for this method");
  }
  
  FUriOp qkf( String key_, String f_ () ){
    if( _queryOp == null ){
      _queryOp = new SVFUriMap();
    }
    if( _queryOp is Map){
      SVFUriMap qmap = _queryOp as SVFUriMap;
      return qmap.putIfAbsent(key_, ()=>new F0FUriOp(f_)  );
    }
    throw new ArgumentError("Query Op is not a supported map for this method");
  }
  
  FUriOp _fragOp;
  FUriOp get fragOp => _fragOp;
  void set fragOp( FUriOp op_ ){
    _fragOp = op_;
  }
  String get fragment => (_fragOp==null)?null:_fragOp.call(this,null);
  
  /**
   * FUri relies on path lists and operations to build the Uri on demand.
   * Use parsePath to produce lists.
   * Because URI spec allows multiple identical query key values,
   * the Map collections unique key design should not be forced.
   */
  FUri( {String scheme, String userInfo: "", 
    String host, int port, 
    Iterable<String> pathSegments, 
    Map<String, dynamic> queryParameters, String fragment}){
    if( pathSegments == null ){
      pathSegments = new List<String>();
    }
    SVFUriMap queryOp = null;
    if( queryParameters != null ){
      queryOp = new SVFUriMap.fromSDMap(queryParameters);
    }
    SFUriOp frag = null;
    if( fragment != null ){
      frag = new SFUriOp(fragment);
    }
    _scheme = scheme;
    _userInfo = userInfo;
    _host = host;
    _port = port;
    _paths = strToOp(pathSegments);
    _queryOp = queryOp;
    _fragOp = frag;
  }
  
  
  /// Non-verifying constructor. Only call with validated arguments.
  FUri.assign(this._scheme,
                this._userInfo,
                this._host,
                this._port,
                this._paths,
                this._queryOp,
                this._fragOp);
  
  static Iterable<FUriOp> strToOp( Iterable<String> i_ ){
    List<FUriOp> res = new List<FUriOp>();
    i_.forEach( (s)=> res.add(new SFUriOp(s)));
    return res;
  }
  
  // Lifted from Uri, because it's not extensible.
  // Frequently used character codes.
  static const int SPACE = 0x20;
  static const int DOUBLE_QUOTE = 0x22;
  static const int NUMBER_SIGN = 0x23;
  static const int PERCENT = 0x25;
  static const int ASTERISK = 0x2A;
  static const int PLUS = 0x2B;
  static const int SLASH = 0x2F;
  static const int ZERO = 0x30;
  static const int NINE = 0x39;
  static const int COLON = 0x3A;
  static const int LESS = 0x3C;
  static const int GREATER = 0x3E;
  static const int QUESTION = 0x3F;
  static const int AT_SIGN = 0x40;
  static const int UPPER_CASE_A = 0x41;
  static const int UPPER_CASE_F = 0x46;
  static const int UPPER_CASE_Z = 0x5A;
  static const int LEFT_BRACKET = 0x5B;
  static const int BACKSLASH = 0x5C;
  static const int RIGHT_BRACKET = 0x5D;
  static const int LOWER_CASE_A = 0x61;
  static const int LOWER_CASE_F = 0x66;
  static const int LOWER_CASE_Z = 0x7A;
  static const int BAR = 0x7C;

  // Characters allowed in the path as of RFC 3986.
  // RFC 3986 section 3.3.
  // pchar = unreserved / pct-encoded / sub-delims / ":" / "@"
  static const pathCharTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               !  $ &'()*+,-.
      0x7fd2,   // 0x20 - 0x2f  0100101111111110
                //              0123456789:; =
      0x2fff,   // 0x30 - 0x3f  1111111111110100
                //              @ABCDEFGHIJKLMNO
      0xffff,   // 0x40 - 0x4f  1111111111111111
                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  // Characters allowed in the path as of RFC 3986.
  // RFC 3986 section 3.3 *and* slash.
  static const pathCharOrSlashTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               !  $ &'()*+,-./
      0xffd2,   // 0x20 - 0x2f  0100101111111111
                //              0123456789:; =
      0x2fff,   // 0x30 - 0x3f  1111111111110100
                //              @ABCDEFGHIJKLMNO
      0xffff,   // 0x40 - 0x4f  1111111111111111

                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  /**
   * This is the internal implementation of JavaScript's encodeURI function.
   * It encodes all characters in the string [text] except for those
   * that appear in [canonicalTable], and returns the escaped string.
   */
  static String uriEncode(List<int> canonicalTable,
                           String text,
                           {Encoding encoding: UTF8,
                            bool spaceToPlus: false}) {
    byteToHex(byte, buffer) {
      const String hex = '0123456789ABCDEF';
      buffer.writeCharCode(hex.codeUnitAt(byte >> 4));
      buffer.writeCharCode(hex.codeUnitAt(byte & 0x0f));
    }

    // Encode the string into bytes then generate an ASCII only string
    // by percent encoding selected bytes.
    StringBuffer result = new StringBuffer();
    var bytes = encoding.encode(text);
    for (int i = 0; i < bytes.length; i++) {
      int byte = bytes[i];
      if (byte < 128 &&
          ((canonicalTable[byte >> 4] & (1 << (byte & 0x0f))) != 0)) {
        result.writeCharCode(byte);
      } else if (spaceToPlus && byte == SPACE) {
        result.writeCharCode(PLUS);
      } else {
        result.writeCharCode(PERCENT);
        byteToHex(byte, result);
      }
    }
    return result.toString();
  }
  
  /**
   * Returns the URI path split into its segments. Each of the
   * segments in the returned list have been decoded. If the path is
   * empty the empty list will be returned. A leading slash `/` does
   * not affect the segments returned.
   *
   * The returned list is unmodifiable and will throw [UnsupportedError] on any
   * calls that would mutate it.
   */
  static List<String> parsePath( String path_ ) {
      var pathToSplit = !path_.isEmpty && path_.codeUnitAt(0) == SLASH
                        ? path_.substring(1)
                        : path_;
      List<String> pathSegments = new List<String>();
      if( !pathToSplit.isEmpty ){
       pathSegments.addAll(pathToSplit.split("/")
                                       .map(Uri.decodeComponent) );
    }
    return pathSegments;
  }
  
  static String makePath( Iterable<String> pathSegments,
                          bool ensureLeadingSlash,
                          bool isFile) {

    var result = pathSegments.map((s) => uriEncode(pathCharTable, s)).join("/");

    if (result.isEmpty) {
      if (isFile) return "/";
    } else if ((isFile || ensureLeadingSlash) &&
               result.codeUnitAt(0) != SLASH) {
      return "/$result";
    }
    return result;
  }
  
  /**
   * Returns the [query_] split into a map according to the rules
   * specified for FORM post in the
   * [HTML 4.01 specification section 17.13.4]
   * (http://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4
   * "HTML 4.01 section 17.13.4"). Each key and value in the returned
   * map has been decoded. If the [query_]
   * is the empty string an empty map is returned.
   *
   * Keys in the query string that have no value are mapped to the
   * empty string.
   *
   * Each query component will be decoded using [encoding]. The default encoding
   * is UTF-8.
   */
  static Map<String, String> parseQuery(String query_,
                                              {Encoding encoding_: UTF8}) {
    return Uri.splitQueryString(query_, encoding:encoding_);
  }
  
  static String makeQuery( Map<String, String> queryParams_) {
    if (queryParams_ == null) return null;
    if ( queryParams_.isEmpty ) return null;

    var result = new StringBuffer();
    var first = true;
    queryParams_.forEach((key, value) {
      if (!first) {
        result.write("&");
      }
      first = false;
      result.write(Uri.encodeQueryComponent(key));
      if (value != null && !value.isEmpty) {
        result.write("=");
        result.write(Uri.encodeQueryComponent(value));
      }
    });
    return result.toString();
  }


}