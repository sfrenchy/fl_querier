import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:querier/models/db_schema.dart';
import 'package:querier/models/query_analysis.dart';
import 'api_endpoints.dart';
import 'package:querier/models/user.dart';
import 'package:querier/models/role.dart';
import 'package:querier/models/api_configuration.dart';
import 'package:flutter/material.dart';
import 'package:querier/models/db_connection.dart';
import 'package:querier/models/menu_category.dart';
import 'package:querier/models/page.dart';
import 'package:querier/models/dynamic_row.dart';
import 'package:querier/models/dynamic_card.dart';
import 'package:querier/models/layout.dart';
import 'package:querier/models/entity_schema.dart';
import 'package:querier/services/data_context_service.dart';
import 'package:querier/models/sql_query.dart';
import 'package:querier/models/sql_query_request.dart';
import 'package:querier/models/analyze_query_request.dart';

class ApiClient {
  final Dio _dio;
  String baseUrl;
  final FlutterSecureStorage _secureStorage;
  final NavigatorState _navigator;
  late final DataContextService dataContextService;

  ApiClient(this.baseUrl, this._navigator)
      : _dio = Dio(),
        _secureStorage = const FlutterSecureStorage() {
    updateBaseUrl(baseUrl);
    _setupInterceptors();
    dataContextService = DataContextService(this);
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _secureStorage.delete(key: 'access_token');
            await _secureStorage.delete(key: 'refresh_token');

            _navigator.pushNamedAndRemoveUntil('/login', (route) => false);
          }
          return handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
    _dio.options.baseUrl = baseUrl;
  }

  // Auth methods
  Future<Response> signIn(String email, String password) async {
    print('Attempting sign in for email: $email');
    final response = await _dio.post(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.signIn),
      data: {'email': email, 'password': password},
    );
    print('Sign in response: ${response.data}');
    return response;
  }

  Future<Response> signOut() async {
    return _dio.post(ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.signOut));
  }

  Future<Response> refreshToken(String refreshToken) async {
    return _dio.post(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.refreshToken),
      data: {'refreshToken': refreshToken},
    );
  }

  // Settings methods
  Future<Response> getSettings() async {
    return _dio.get(ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.getSettings));
  }

  Future<Response> updateSettings(Map<String, dynamic> settings) async {
    return _dio.post(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.updateSettings),
      data: settings,
    );
  }

  Future<bool> isConfigured() async {
    final response = await _dio.get(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.isConfigured),
    );
    return response.data as bool;
  }

  // Wizard methods
  Future<bool> setup({
    required String name,
    required String firstName,
    required String email,
    required String password,
    required String smtpHost,
    required int smtpPort,
    required String smtpUsername,
    required String smtpPassword,
    required bool useSSL,
    required String senderEmail,
    required String senderName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.setup),
      data: {
        'admin': {
          'name': name,
          'firstName': firstName,
          'email': email,
          'password': password,
        },
        'smtp': {
          'host': smtpHost,
          'port': smtpPort,
          'username': smtpUsername,
          'password': smtpPassword,
          'useSSL': useSSL,
          'senderEmail': senderEmail,
          'senderName': senderName,
        },
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> testSmtpConfiguration({
    required String host,
    required int port,
    required String username,
    required String password,
    required bool useSSL,
    required String senderEmail,
    required String senderName,
    required bool requireAuth,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.smtpTest),
        data: {
          'host': host,
          'port': port,
          'username': username,
          'password': password,
          'useSSL': useSSL,
          'senderEmail': senderEmail,
          'senderName': senderName,
          'requireAuth': requireAuth,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error testing SMTP configuration: $e');
      return false;
    }
  }

  // User methods
  Future<Response> getCurrentUser() async {
    return _dio.get(ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.currentUser));
  }

  Future<Response> getUserById(String id) async {
    final endpoint = ApiEndpoints.replaceUrlParams(
      ApiEndpoints.userById,
      {'id': id},
    );
    return _dio.get(ApiEndpoints.buildUrl(baseUrl, endpoint));
  }

  // Helper method pour configurer les headers d'authentification
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Response> getUserData(String id) async {
    final endpoint = ApiEndpoints.replaceUrlParams(
      ApiEndpoints.userProfile,
      {'id': id},
    );
    return _dio.get(ApiEndpoints.buildUrl(baseUrl, endpoint));
  }

  Future<List<String>> getRecentQueries() async {
    final response = await _dio.get(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.recentQueries),
    );
    return List<String>.from(response.data);
  }

  Future<Map<String, int>> getQueryStats() async {
    final response = await _dio.get(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.queryStats),
    );
    return Map<String, int>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getActivityData() async {
    final response = await _dio.get(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.activity),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _dio.post(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.signOut),
      data: <String, dynamic>{},
    );
  }

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.users),
      );

      print('API Response: ${response.data}'); // Debug log

      if (response.data is List) {
        return (response.data as List).map((userData) {
          print('Processing user data: $userData'); // Debug log
          return User.fromJson(userData);
        }).toList();
      } else {
        // Si la réponse contient une propriété data ou users
        final usersList = response.data['data'] ?? response.data['users'] ?? [];
        return (usersList as List)
            .map((userData) => User.fromJson(userData))
            .toList();
      }
    } catch (e, stackTrace) {
      print('Error in getAllUsers: $e\n$stackTrace'); // Debug log
      rethrow;
    }
  }

  Future<List<Role>> getAllRoles() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.roles),
      );

      if (response.data is List) {
        return (response.data as List)
            .map((roleData) => Role.fromJson(roleData))
            .toList();
      } else {
        final rolesList = response.data['data'] ?? response.data['roles'] ?? [];
        return (rolesList as List)
            .map((roleData) => Role.fromJson(roleData))
            .toList();
      }
    } catch (e) {
      print('Error in getAllRoles: $e');
      rethrow;
    }
  }

  Future<bool> addRole(String name) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.addRole),
        data: {'id': '', 'name': name},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error in addRole: $e');
      rethrow;
    }
  }

  Future<bool> updateRole(String id, String name) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.updateRole),
        data: {
          'Id': id,
          'Name': name,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error in updateRole: $e');
      rethrow;
    }
  }

  Future<bool> deleteRole(String id) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.buildUrl(
          baseUrl,
          ApiEndpoints.replaceUrlParams(ApiEndpoints.deleteRole, {'id': id}),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error in deleteRole: $e');
      rethrow;
    }
  }

  Future<void> storeRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<bool> addUser(String email, String firstName, String lastName,
      String password, List<String> roles) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.addUser),
        data: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'password': password,
          'userName': email,
          'roles': roles,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error in addUser: $e');
      rethrow;
    }
  }

  Future<bool> updateUser(String id, String email, String firstName,
      String lastName, List<String> roles) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.updateUser),
        data: {
          'id': id,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'userName': email,
          'roles': roles,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error in updateUser: $e');
      rethrow;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.buildUrl(
          baseUrl,
          ApiEndpoints.replaceUrlParams(ApiEndpoints.deleteUser, {'id': id}),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error in deleteUser: $e');
      rethrow;
    }
  }

  Future<bool> resendConfirmationEmail(String userId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.resendConfirmationEmail),
        data: {'userId': userId},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error resending confirmation email: $e');
      rethrow;
    }
  }

  Future<ApiConfiguration> getApiConfiguration() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.apiConfiguration),
      );
      return ApiConfiguration.fromJson(response.data);
    } catch (e) {
      print('Error in getApiConfiguration: $e');
      rethrow;
    }
  }

  Future<bool> updateApiConfiguration(ApiConfiguration config) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.apiConfiguration),
        data: config.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Response> put(String endpoint, {dynamic data}) async {
    final response = await _dio.put(
      ApiEndpoints.buildUrl(baseUrl, endpoint),
      data: data,
    );
    return response;
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    final response = await _dio.post(
      ApiEndpoints.buildUrl(baseUrl, endpoint),
      data: data,
    );
    return response;
  }

  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get(
      ApiEndpoints.buildUrl(baseUrl, endpoint),
      queryParameters: queryParameters,
    );
    return response;
  }

  Future<Response> delete(String endpoint, {dynamic data}) async {
    final response = await _dio.delete(
      ApiEndpoints.buildUrl(baseUrl, endpoint),
      data: data,
    );
    return response;
  }

  Future<List<DBConnection>> getDBConnections() async {
    final response = await _dio.get(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.dbConnections),
    );
    return (response.data as List)
        .map((json) => DBConnection.fromJson(json))
        .toList();
  }

  Future<List<ControllerInfoResponse>> getDBConnectionControllers(
      int connectionId) async {
    final response = await _dio.get(
      ApiEndpoints.replaceUrlParams(
        ApiEndpoints.dbConnectionControllers,
        {'id': connectionId.toString()},
      ),
    );
    return (response.data as List)
        .map((json) => ControllerInfoResponse.fromJson(json))
        .toList();
  }

  Future<List<MenuCategory>> getMenuCategories() async {
    final response = await get(ApiEndpoints.menuCategories);
    return (response.data as List<dynamic>)
        .map((json) => MenuCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MenuCategory> createMenuCategory(Map<String, dynamic> data) async {
    final response = await post(ApiEndpoints.menuCategories, data: data);
    return MenuCategory.fromJson(response.data);
  }

  Future<MenuCategory> updateMenuCategory(int id, MenuCategory category) async {
    final response = await put(
      '${ApiEndpoints.menuCategories}/$id',
      data: category.toJson(),
    );
    return MenuCategory.fromJson(response.data);
  }

  Future<void> deleteMenuCategory(int id) async {
    await delete('${ApiEndpoints.menuCategories}/$id');
  }

  // Récupérer toutes les pages d'une catégorie
  Future<List<MenuPage>> getPages(int categoryId) async {
    final response = await _dio.get(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.pagesByCategory,
          {'categoryId': categoryId.toString()},
        ),
      ),
    );
    return List<MenuPage>.from(
      (response.data as List).map((json) => MenuPage.fromJson(json)),
    );
  }

  // Récupérer une page par son ID
  Future<MenuPage> getPageById(int id) async {
    final response = await _dio.get(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
            ApiEndpoints.pageById, {'id': id.toString()}),
      ),
    );
    return MenuPage.fromJson(response.data);
  }

  // Créer une nouvelle page
  Future<MenuPage> createPage(MenuPage page) async {
    final response = await _dio.post(
      ApiEndpoints.buildUrl(baseUrl, ApiEndpoints.pages),
      data: page.toJson(),
    );
    return MenuPage.fromJson(response.data);
  }

  // Mettre à jour une page
  Future<MenuPage> updatePage(int id, MenuPage page) async {
    final translations = page.names.entries
        .map((entry) => {
              'languageCode': entry.key,
              'name': entry.value,
            })
        .toList();

    final response = await _dio.put(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
            ApiEndpoints.pageById, {'id': id.toString()}),
      ),
      data: {
        'icon': page.icon,
        'order': page.order,
        'isVisible': page.isVisible,
        'roles': page.roles,
        'route': page.route,
        'dynamicMenuCategoryId': page.menuCategoryId,
        'translations': translations,
      },
    );

    return MenuPage.fromJson(response.data);
  }

  // Supprimer une page
  Future<void> deletePage(int id) async {
    await _dio.delete(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
            ApiEndpoints.pageById, {'id': id.toString()}),
      ),
    );
  }

  // Dynamic Rows
  Future<List<DynamicRow>> getDynamicRows(int pageId) async {
    final response = await _dio.get(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.dynamicRowsByPage,
          {'pageId': pageId.toString()},
        ),
      ),
    );
    return (response.data as List)
        .map((json) => DynamicRow.fromJson(json))
        .toList();
  }

  Future<DynamicRow> createDynamicRow(
      int pageId, Map<String, dynamic> rowData) async {
    final response = await _dio.post(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.dynamicRowsByPage,
          {'pageId': pageId.toString()},
        ),
      ),
      data: rowData,
    );
    return DynamicRow.fromJson(response.data);
  }

  Future<DynamicRow> updateDynamicRow(
      int rowId, Map<String, dynamic> updates) async {
    final response = await _dio.put(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.dynamicRows,
          {'id': rowId.toString()},
        ),
      ),
      data: updates,
    );
    return DynamicRow.fromJson(response.data);
  }

  Future<void> deleteDynamicRow(int rowId) async {
    await _dio.delete(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.dynamicRows,
          {'id': rowId.toString()},
        ),
      ),
    );
  }

  Future<void> reorderDynamicRows(int pageId, List<int> rowIds) async {
    await _dio.post(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.dynamicRowReorder,
          {'pageId': pageId.toString()},
        ),
      ),
      data: rowIds,
    );
  }

  // Dynamic Cards
  Future<DynamicCard> createDynamicCard(
      int rowId, Map<String, dynamic> cardData) async {
    final response = await _dio.post(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.dynamicCardsByRow,
          {'rowId': rowId.toString()},
        ),
      ),
      data: cardData,
    );
    return DynamicCard.fromJson(response.data);
  }

  Future<DynamicCard> updateDynamicCard(
      int cardId, Map<String, dynamic> updates) async {
    final response = await _dio.put(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.dynamicCards,
          {'id': cardId.toString()},
        ),
      ),
      data: updates,
    );
    return DynamicCard.fromJson(response.data);
  }

  Future<void> deleteDynamicCard(int cardId) async {
    await _dio.delete(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.dynamicCards,
          {'id': cardId.toString()},
        ),
      ),
    );
  }

  Future<void> reorderDynamicCards(int rowId, List<int> cardIds) async {
    await _dio.post(
      '//DynamicCard/row/$rowId/reorder',
      data: cardIds,
    );
  }

  Future<void> updatePageLayout(int pageId, List<DynamicRow> rows) async {
    await _dio.put(
      ApiEndpoints.buildUrl(
        baseUrl,
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.pageLayout,
          {'id': pageId.toString()},
        ),
      ),
      data: rows.map((row) => row.toJson()).toList(),
    );
  }

  // Layout methods
  Future<Layout> getLayout(int pageId) async {
    final response = await get(
      ApiEndpoints.replaceUrlParams(
        ApiEndpoints.getLayout,
        {'pageId': pageId.toString()},
      ),
    );
    return Layout.fromJson(response.data);
  }

  Future<Layout> updateLayout(int pageId, Layout layout) async {
    print(
        'Updating layout, row heights: ${layout.rows.map((r) => r.height).toList()}');
    final response = await put(
      ApiEndpoints.replaceUrlParams(
        ApiEndpoints.updateLayout,
        {'pageId': pageId.toString()},
      ),
      data: layout.toJson(),
    );
    return Layout.fromJson(response.data);
  }

  Future<void> deleteLayout(int pageId) async {
    await delete(
      ApiEndpoints.replaceUrlParams(
        ApiEndpoints.deleteLayout,
        {'pageId': pageId.toString()},
      ),
    );
  }

  Future<List<String>> getEntityContexts() async {
    final response = await _dio.get(ApiEndpoints.entityCRUD);
    return List<String>.from(response.data);
  }

  Future<List<EntitySchema>> getEntities(String contextTypeName) async {
    final response = await _dio.get(
      ApiEndpoints.replaceUrlParams(
        ApiEndpoints.entityCRUDEntities,
        {'contextTypeName': contextTypeName},
      ),
    );
    return (response.data as List)
        .map((json) => EntitySchema.fromJson(json))
        .toList();
  }

  Future<(List<Map<String, dynamic>>, int)> getEntityData(
      String contextTypeName, String entityTypeName,
      {int pageNumber = 1, int pageSize = 10, String orderBy = ""}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.entityCRUDGetAll,
          {
            'contextTypeName': contextTypeName,
            'entityTypeName': entityTypeName
          },
        ),
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'orderBy': orderBy,
        },
      );

      print('API Response: ${response.data}'); // Debug

      final List<Map<String, dynamic>> data = (response.data['Items'] as List)
          .map(
              (item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
          .toList();

      final totalCount = response.data['Total'] as int? ?? 0;

      return (data, totalCount);
    } catch (e) {
      print('API Error: $e'); // Debug
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEntity(
      String contextName, String entityName) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.replaceUrlParams(
        ApiEndpoints.entityCRUDGetEntity,
        {
          'contextTypeName': contextName,
          'entityName': entityName,
        },
      ),
    );
    return response.data!;
  }

  Future<List<SQLQuery>> getSQLQueries() async {
    final response = await get(ApiEndpoints.sqlQueries);
    print('Raw response data: ${response.data}');

    try {
      if (response.data is List) {
        return (response.data as List).map((item) {
          if (item is Map) {
            return SQLQuery.fromJson(Map<String, dynamic>.from(item));
          }
          // Si l'item est déjà un Map<String, dynamic>
          return SQLQuery.fromJson(item as Map<String, dynamic>);
        }).toList();
      } else if (response.data is Map) {
        return [SQLQuery.fromJson(Map<String, dynamic>.from(response.data))];
      } else {
        throw FormatException('Unexpected response format: ${response.data}');
      }
    } catch (e, stackTrace) {
      print('Error parsing SQLQueries: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<SQLQuery> getSQLQuery(int id) async {
    final response = await get(
      ApiEndpoints.replaceUrlParams(
        ApiEndpoints.sqlQuery,
        {'id': id.toString()},
      ),
    );
    return SQLQuery.fromJson(response.data);
  }

  Future<SQLQuery> createSQLQuery(SQLQuery query,
      {Map<String, dynamic>? sampleParameters}) async {
    final request = SQLQueryRequest(
      query: query,
      sampleParameters: sampleParameters,
    );
    final response =
        await post(ApiEndpoints.sqlQueries, data: request.toJson());
    return SQLQuery.fromJson(response.data);
  }

  Future<SQLQuery> updateSQLQuery(int id, SQLQuery query,
      {Map<String, dynamic>? sampleParameters}) async {
    final request = SQLQueryRequest(
      query: query,
      sampleParameters: sampleParameters,
    );
    final response = await put(
      ApiEndpoints.replaceUrlParams(
          ApiEndpoints.sqlQuery, {'id': id.toString()}),
      data: request.toJson(),
    );
    return SQLQuery.fromJson(response.data);
  }

  Future<void> deleteSQLQuery(int id) async {
    await delete(
      ApiEndpoints.replaceUrlParams(
        ApiEndpoints.sqlQuery,
        {'id': id.toString()},
      ),
    );
  }

  Future<DatabaseSchema> getDatabaseSchema(int connectionId) async {
    try {
      print('Calling getDatabaseSchema for connectionId: $connectionId');

      final url = ApiEndpoints.replaceUrlParams(
        ApiEndpoints.dbConnectionSchema,
        {'connectionId': connectionId.toString()},
      );
      print('URL: $url');

      final response = await _dio.get<Map<String, dynamic>>(url);
      print('Raw API Response: ${response.data}');

      final schema = DatabaseSchema.fromJson(response.data!);
      print('Parsed Schema: $schema');

      return schema;
    } catch (e, stackTrace) {
      print('Error in getDatabaseSchema: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<QueryAnalysis> analyzeQuery(int connectionId, String query) async {
    final request = AnalyzeQueryRequest(query: query);
    final response = await post(
      ApiEndpoints.replaceUrlParams(
        ApiEndpoints.analyzeQuery,
        {'connectionId': connectionId.toString()},
      ),
      data: request.toJson(),
    );
    return QueryAnalysis.fromJson(response.data);
  }

  Future<(List<dynamic>, int)> executeQuery(
    String queryName, {
    int pageNumber = 1,
    int pageSize = 0,
  }) async {
    final queries = await getSQLQueries();
    final query = queries.firstWhere(
      (q) => q.name == queryName,
      orElse: () => throw Exception('Query not found: $queryName'),
    );

    final response = await _dio.post(
      ApiEndpoints.buildUrl(baseUrl, 'SQLQuery/${query.id}/execute'),
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
      data: <String, dynamic>{},
      options: Options(
        contentType: 'application/json-patch+json',
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      return (
        data['Items'] as List<dynamic>,
        data['Total'] as int,
      );
    }

    throw Exception('Failed to execute query');
  }
}
