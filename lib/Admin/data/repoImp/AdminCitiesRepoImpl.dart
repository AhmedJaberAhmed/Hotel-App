import '../../AdminCitiesRemoteDataSource.dart';
import '../../CityEntity.dart';
import '../../domain/repo/AdminCityRepo.dart';

class AdminCitiesRepoImpl implements AdminCitiesRepository {
  final AdminCitiesRemoteDataSource remote;
  AdminCitiesRepoImpl(this.remote);

  @override
  Future<List<CityEntity>> getCities() async {
    final rows = await remote.getCities();
    return rows
        .map((e) => CityEntity(
      id: e['id'] as String,
      name: e['name'] as String,
    ))
        .toList();
  }
}
