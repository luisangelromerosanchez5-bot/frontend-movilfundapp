import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/activity_remote_data_source.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/postulacion.dart';
import '../../domain/repositories/activity_repository.dart';

final activityRemoteDataSourceProvider = Provider<ActivityRemoteDataSource>((ref) {
  return ActivityRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(remoteDataSource: ref.watch(activityRemoteDataSourceProvider));
});

// Filtros de actividades
class ActivityFilter {
  final String query;
  final String categoria;

  const ActivityFilter({this.query = '', this.categoria = 'Todos'});

  ActivityFilter copyWith({String? query, String? categoria}) {
    return ActivityFilter(
      query: query ?? this.query,
      categoria: categoria ?? this.categoria,
    );
  }
}

final activityFilterProvider = StateProvider<ActivityFilter>((ref) => const ActivityFilter());

final activitiesListProvider = FutureProvider<List<Activity>>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  final filter = ref.watch(activityFilterProvider);
  return await repository.getActivities(query: filter.query, categoria: filter.categoria);
});

final activityDetailProvider = FutureProvider.family<Activity?, String>((ref, id) async {
  final repository = ref.watch(activityRepositoryProvider);
  return await repository.getActivityById(id);
});

final userPostulacionesProvider = FutureProvider<List<Postulacion>>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  final user = ref.watch(authProvider).user;
  return await repository.getUserPostulaciones(user?.id ?? '1');
});
