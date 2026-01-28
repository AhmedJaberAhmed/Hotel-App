import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repoImp/AdminRepoImpl.dart';
import 'domain/AdminHotelCreate.dart';
import 'domain/repo/AdminRepository.dart';

class CreateHotel {
  final AdminRepository repo;
  CreateHotel(this.repo);

  Future<String> call(AdminHotelCreate input) {
    return repo.createHotel(input);
  }
}



class CreateRoom {
  final AdminRepository repo;
  CreateRoom(this.repo);

  Future<String> call({
    required String hotelId,
    required String title,
    required String pricingModel,
    required double pricePerNight,
    required int maxPersons,
    required int bedsCount,
  }) {
    return repo.createRoom(
      hotelId: hotelId,
      title: title,
      pricingModel: pricingModel,
      pricePerNight: pricePerNight,
      maxPersons: maxPersons,
      bedsCount: bedsCount,
    );
  }
}









