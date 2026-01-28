
import '../../CityEntity.dart';

abstract class AdminCitiesRepository {
  Future<List<CityEntity>> getCities();
}