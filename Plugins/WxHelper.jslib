mergeInto(LibraryManager.library, {
  SetOpenId: function (openid) {
    var openidStr = UTF8ToString(openid);
    GameGlobal.dnSDK.setOpenId(openidStr);
  },
  SetUnionId: function (unionid) {
    var unionidStr = UTF8ToString(unionid);
    GameGlobal.dnSDK.setUnionId(unionidStr);
  },
  OnTrack: function (type,params) {
    GameGlobal.dnSDK.track(UTF8ToString(type),JSON.parse(UTF8ToString(params)));
  },
  IsWxPlatform:function(){
    return typeof wx !== 'undefined';
  },
});
