import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'CityEntity.dart';

class AdminCitiesRemoteDataSource {
  final SupabaseClient client;
  AdminCitiesRemoteDataSource(this.client);

  Future<List<Map<String, dynamic>>> getCities() async {
    final res = await client
        .from('cities')
        .select('id, name')
        .order('name', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }
}




















 
