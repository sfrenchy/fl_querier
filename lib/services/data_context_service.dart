import 'package:querier/api/api_client.dart';
import 'package:querier/models/entity_schema.dart';
import 'package:querier/api/api_endpoints.dart';

class DataContextService {
  final ApiClient apiClient;

  DataContextService(this.apiClient);

  Future<List<String>> getAvailableContexts() async {
    try {
      final response = await apiClient.get(ApiEndpoints.entityCRUD);
      if (response.statusCode == 200) {
        final List<dynamic> contexts = response.data as List<dynamic>;
        return contexts.map((c) => c.toString()).toList();
      }
    } catch (e) {
      print('Error loading contexts: $e');
    }
    return [];
  }

  Future<List<EntitySchema>> getAvailableEntities(String? context) async {
    if (context == null) return [];

    try {
      final response = await apiClient.get(
        ApiEndpoints.replaceUrlParams(
          ApiEndpoints.entityCRUDEntities,
          {'contextTypeName': context},
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> entities = response.data as List<dynamic>;
        return entities.map((e) => EntitySchema.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error loading entities: $e');
    }
    return [];
  }

  Future<Map<String, String>?> getEntityPreview(
      String context, String entity) async {
    try {
      // Récupérer l'entité dans la liste des entités déjà chargées
      final entities = await getAvailableEntities(context);
      final entitySchema = entities.firstWhere((e) => e.name == entity);

      // Créer un map avec les noms de colonnes et leurs types
      return Map.fromEntries(
        entitySchema.properties.map((prop) => MapEntry(prop.name, prop.type)),
      );
    } catch (e) {
      print('Error loading entity preview: $e');
    }
    return null;
  }

  Future<EntitySchema?> getEntitySchema(String context, String entity) async {
    try {
      final entities = await getAvailableEntities(context);
      return entities.firstWhere(
        (e) => e.name == entity,
      );
    } catch (e) {
      return null;
    }
  }
}
