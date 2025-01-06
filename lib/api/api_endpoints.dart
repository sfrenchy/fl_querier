class ApiEndpoints {
  // Auth Management Controller
  static const String signIn = '/authmanagement/signin';
  static const String signOut = '/authmanagement/signout';
  static const String refreshToken = '/authmanagement/refreshtoken';

  // Settings Controller
  static const String getSettings = '/settings';
  static const String updateSettings = '/settings';
  static const String isConfigured = '/settings/configured';
  static const String configure = '/settings/configure';
  static const String apiConfiguration = 'settings/api-configuration';
  static const String updateApiConfiguration = 'settings/api-configuration';

  // User Management Controller
  static const String users = '/usermanagement/getall';
  static const String addUser = '/usermanagement/add';
  static const String updateUser = '/usermanagement/update';
  static const String currentUser = '/usermanagement/me';
  static const String userById = '/users/{id}';
  static const String deleteUser = '/usermanagement/delete/{id}';
  static const String userProfile = '/usermanagement/view/{id}';
  static const String resendConfirmationEmail =
      '/usermanagement/resend-confirmation';

  // Role Controller
  static const String roles = '/role/getall';
  static const String roleById = '/role/{id}';
  static const String addRole = '/role/addrole';
  static const String updateRole = '/role/updaterole';
  static const String deleteRole = '/role/deleterole/{id}';

  // DB Connection Controller
  static const String dbConnections = 'dbconnection';
  static const String deleteDbConnection = 'dbconnection/deletedbconnection';
  static const String addDbConnection = 'dbconnection/adddbconnection';
  static const String updateDbConnection = 'dbconnection/{id}';
  static const String dbConnectionSchema =
      '/dbconnection/{connectionId}/schema';
  static const String dbConnectionControllers =
      '/dbconnection/{id}/controllers';
  static const String analyzeQuery =
      '/dbconnection/{connectionId}/analyze-query';

  // Menu Category Controller
  static const String menuCategories = '/dynamicmenucategory';

  // DynamicPage Controller
  static const String pages = 'dynamicpage';
  static const String pageById = 'dynamicpage/{id}';
  static const String pagesByCategory = 'dynamicpage?categoryId={categoryId}';
  static const String pageLayout = 'dynamicpage/{id}/layout';

  // Dynamic Row Controller
  static const String dynamicRows = 'dynamicrow';
  static const String dynamicRowsByPage = 'dynamicrow/page/{pageId}';
  static const String dynamicRowReorder = 'dynamicrow/page/{pageId}/reorder';

  // Dynamic Card Controller
  static const String dynamicCards = 'dynamiccard';
  static const String dynamicCardsByRow = 'dynamiccard/row/{rowId}';
  static const String dynamicCardReorder = 'dynamiccard/row/{rowId}/reorder';

  // Query Analytics Controller
  static const String recentQueries = '/queries/recent';
  static const String queryStats = '/queries/stats';
  static const String activity = '/queries/activity';

  // Wizard endpoints
  static const String setup = '/wizard/setup';

  // Layout Controller
  static const String getLayout = 'layout/{pageId}';
  static const String updateLayout = 'layout/{pageId}';
  static const String deleteLayout = 'layout/{pageId}';

  // Helper Methods
  static String buildUrl(String baseUrl, String endpoint) {
    if (endpoint.startsWith('api/v1/')) {
      final baseUrlWithoutApi = baseUrl.replaceAll(RegExp(r'/api/v1/?$'), '');
      return '$baseUrlWithoutApi/$endpoint';
    }

    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanEndpoint =
        endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

    return '$cleanBaseUrl/$cleanEndpoint';
  }

  static String replaceUrlParams(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  static const String entityCRUD = '/EntityCRUD/GetContexts';
  static const String entityCRUDEntities =
      '/EntityCRUD/GetEntities?contextTypeName={contextTypeName}';
  static const String entityCRUDGetAll =
      '/EntityCRUD/GetAll?contextTypeName={contextTypeName}&entityTypeName={entityTypeName}';
  static const String entityCRUDGetEntity =
      '/EntityCRUD/GetEntity?contextTypeName={contextTypeName}&entityName={entityName}';

  static String getEntity(String contextTypeName, String entityName) =>
      replaceUrlParams(
        entityCRUDGetEntity,
        {
          'contextTypeName': contextTypeName,
          'entityName': entityName,
        },
      );

  // SQL Query endpoints
  static const String sqlQueries = 'SQLQuery';
  static const String sqlQuery = 'SQLQuery/{id}';
  static const String executeSqlQuery = 'SQLQuery/{id}/execute';

  // SMTP Controller
  static const String smtpTest = 'smtp/test';
}
