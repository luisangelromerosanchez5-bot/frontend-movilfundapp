import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/certificate_remote_data_source.dart';
import '../../data/repositories/certificate_repository_impl.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';

final certificateRemoteDataSourceProvider = Provider<CertificateRemoteDataSource>((ref) {
  return CertificateRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return CertificateRepositoryImpl(remoteDataSource: ref.watch(certificateRemoteDataSourceProvider));
});

final userCertificatesProvider = FutureProvider<List<Certificate>>((ref) async {
  final repo = ref.watch(certificateRepositoryProvider);
  final user = ref.watch(authProvider).user;
  return await repo.getCertificatesByUser(user?.id ?? 'u101');
});
