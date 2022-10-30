class ResponseOb {
  MsgState? msgState;
  ErrState? errState;
  dynamic data;
  ResponseOb({this.msgState, this.errState, this.data});
}

enum MsgState {
  data,
  error,
  loading,
}

enum ErrState {
  unKnownErr,
  severErr,
  noConnection,
}

enum PageState {
  first,
  load,
  noMore,
}
