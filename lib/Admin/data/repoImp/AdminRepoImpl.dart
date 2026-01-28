import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../AdminRemoteDataSource.dart';
import '../../domain/AdminHotelCreate.dart';
import '../../domain/repo/AdminRepository.dart';

class AdminRepoImpl implements AdminRepository {
  final AdminRemoteDataSource remote;
  AdminRepoImpl(this.remote);

  @override
  Future<String> createHotel(AdminHotelCreate input) async {
    String? coverPath;

     String? coverUrl;

     if (input.coverFile != null) {
      final StorageUploadResult upload = await remote.uploadHotelCover(
        file: input.coverFile!,
        hotelName: input.name,
      );

      coverPath = upload.path;
      coverUrl = upload.url;


    }


    final hotelId = await remote.createHotel({
      'name': input.name,
      'description': input.description,
      'city_id': input.cityId,
      'min_price_per_night': input.minPricePerNight,
      'currency': input.currency,
      'rating': input.rating,
      'cover_image_path': coverPath,
    });

     if (coverPath != null) {
      await remote.addHotelImage(
        hotelId: hotelId,
        imagePath: coverPath,
        sortOrder: 0,
      );
    }

    return hotelId;
  }
  @override
  Future<String> createRoom({
    required String hotelId,
    required String title,
    required String pricingModel,
    required double pricePerNight,
    required int maxPersons,
    required int bedsCount,
  }) {
    return remote.createRoom(
      hotelId: hotelId,
      title: title,
      pricingModel: pricingModel,
      pricePerNight: pricePerNight,
      maxPersons: maxPersons,
      bedsCount: bedsCount,
    );
  }

  @override
  Future<void> upsertRoomFeatures({
    required String roomId,
    required bool wifi,
    required List<String> meals,
    required bool ac,
    required bool parking,
    required bool pool,
    required bool gym,
  }) {
    return remote.upsertRoomFeatures(
      roomId: roomId,
      wifi: wifi,
      meals: meals,
      ac: ac,
      parking: parking,
      pool: pool,
      gym: gym,
    );
  }

}






