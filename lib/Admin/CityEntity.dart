import 'domain/repo/AdminCityRepo.dart';

class CityEntity {
  final String id;
  final String name;

  const CityEntity({
    required this.id,
    required this.name,
  });
}



class GetCitiesUseCase {
  final AdminCitiesRepository repo;
  GetCitiesUseCase(this.repo);

  Future<List<CityEntity>> call() => repo.getCities();
}
