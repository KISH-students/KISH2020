class KISHApi {
  static const String HOST = "https://kish-dev.kro.kr/";
  static const String API_ROOT = HOST + "api/";
  static const String MAGAZINE_ROOT = API_ROOT + "kish-magazine/";
  static const String POST_ROOT = API_ROOT + "post/";
  static const String LIBRARY_ROOT = API_ROOT + "library/";

  static const String GET_EXAM_DATES = API_ROOT + "getExamDates";
  static const String GET_LUNCH = API_ROOT + "getLunch";

  static const String SEARCH_POST = POST_ROOT + "searchPost";
  static const String GET_POSTS_BY_MENU = POST_ROOT + "getPostsByMenu";
  static const String GET_LAST_UPDATED_MENU_LIST = POST_ROOT + "getLastUpdatedMenuList";
  static const String GET_POST_CONTENT_HTML = POST_ROOT + "getPostContentHtml";
  static const String GET_POST_ATTACHMENTS = POST_ROOT + "getPostAttachments";
  static const String GET_POST_LIST_HOME_SUMMARY = POST_ROOT + "getPostListHomeSummary";

  static const String LIBRARY_LOGIN = LIBRARY_ROOT + "login";
  static const String LIBRARY_MY_INFO = LIBRARY_ROOT + "getInfo";
  static const String LIBRARY_REGISTER = LIBRARY_ROOT + "register";
  static const String IS_LIBRARY_Member = LIBRARY_ROOT + "isMember";

  static const String GET_MAGAZINE_ARTICLE = MAGAZINE_ROOT + "getArticleList";
  static const String GET_MAGAZINE_HOME = MAGAZINE_ROOT + "home";
  static const String GET_MAGAZINE_PARENT_LIST = MAGAZINE_ROOT + "getParentList";
  static const String GET_MAGAZINE_CATEGORY_LIST = MAGAZINE_ROOT + "getCategoryList";
}
