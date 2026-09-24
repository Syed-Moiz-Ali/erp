import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'service_team.dart';

abstract interface class ServiceTeamRepository {
  Stream<Result<ServiceTeamPage>> watchTeams(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  });
  Stream<Result<ServiceTeam?>> watchTeam(AuthContext context, String id);
  Future<Result<ServiceTeam?>> getTeam(AuthContext context, String id);
  Future<Result<ServiceTeam>> saveTeam(
    AuthContext context,
    ServiceTeamDraft draft, {
    String? id,
  });
  Future<Result<void>> setActive(AuthContext context, String id, bool active);

  /// Resolved members for a team (active + historical inactive), via the
  /// WorkforceDirectory contract.
  Stream<Result<List<ServiceTeamMemberView>>> watchMembers(
    AuthContext context,
    String teamId,
  );
  Future<Result<List<ServiceTeamRef>>> searchReferences(
    AuthContext context, {
    String query = '',
    int limit = 50,
  });

  /// Resolves several team references by id (active or historical) for display.
  Future<Result<List<ServiceTeamRef>>> getReferences(
    AuthContext context,
    Iterable<String> ids,
  );
}
