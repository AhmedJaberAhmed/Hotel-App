import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -------------------- ADMIN imports --------------------
import 'Admin/AdminCitiesRemoteDataSource.dart';
import 'Admin/AdminRemoteDataSource.dart';
import 'Admin/CityEntity.dart';
import 'Admin/UpsertRoomFeatures.dart';
import 'Admin/data/repoImp/AdminCitiesRepoImpl.dart';
import 'Admin/data/repoImp/AdminRepoImpl.dart';
import 'Admin/presentaion/Blocs/AddminAddHotel/AdminHotelFormBloc.dart';
import 'Admin/presentaion/Blocs/Room/room_bloc.dart';
import 'Admin/presentaion/Blocs/RoomFeatureBloc/AdminRoomFeaturesBloc.dart';
import 'Admin/presentaion/Blocs/getCityBloc/cityEvent.dart';
import 'Admin/presentaion/Blocs/getCityBloc/city_bloc.dart';
import 'Admin/presentaion/pages/AdminAddHotelPage.dart';
import 'Admin/use case CreateHotel.dart';

// -------------------- AUTH imports --------------------
import 'Auth/Auth Wrapper.dart';
import 'Auth/data/Auth repo imp.dart';
import 'Auth/domain/AuthRemoteDataSource.dart';
import 'Auth/presentaion/Blocs/Auth Bloc/Auth Cubit.dart';
import 'Auth/presentaion/pages/signinPage.dart';
import 'Auth/presentaion/pages/signup Screen.dart';

// -------------------- HOTELS imports --------------------
import 'Home/HotelRemoteDataSource.dart';
import 'Home/Hotel_Repo_Repo_Imp.dart';
import 'Home/MainShell.dart';
import 'Home/presentaion/Blocs/Hotels_cubit/Hotels_Bloc.dart';

// -------------------- FAVORITES imports --------------------
import 'Home/favourite/data/favorites_repository_imp.dart';
import 'Home/favourite/presentation/favorites_cubit.dart';

// -------------------- MAIN SHELL (Bottom Nav) --------------------
// ✅ create this file as I sent you: lib/features/main/presentation/main_shell.dart

// -------------------- Your old screen (still used inside MainShell) --------------------
import 'Home/presentaion/pages/hotel_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: '',
    anonKey: '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;

    // --- ADMIN DataSources ---
    final adminRemote = AdminRemoteDataSource(supabaseClient);
    final citiesRemote = AdminCitiesRemoteDataSource(supabaseClient);

    // --- ADMIN Repos ---
    final adminRepo = AdminRepoImpl(adminRemote);
    final citiesRepo = AdminCitiesRepoImpl(citiesRemote);

    // --- ADMIN UseCases ---
    final createHotel = CreateHotel(adminRepo);
    final createRoom = CreateRoom(adminRepo);
    final upsertRoomFeatures = UpsertRoomFeatures(adminRepo);
    final getCitiesUseCase = GetCitiesUseCase(citiesRepo);

    // --- HOTELS Repository ---
    final hotelsRepository = HotelsRepositoryImpl(
      remoteDataSource: HotelsRemoteDataSourceImpl(
        supabaseClient: supabaseClient,
      ),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HotelsRepository>(
          create: (_) => hotelsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // ============ AUTH ============
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(
              authRepository: AuthRepositoryImpl(
                remoteDataSource: AuthRemoteDataSourceImpl(
                  supabaseClient: supabaseClient,
                ),
              ),
            ),
          ),

          // ============ FAVORITES ============
          BlocProvider<FavoritesCubit>(
            create: (_) => FavoritesCubit(
              repo: FavoritesRepository(),
            )..load(),
          ),

          // ============ ADMIN ============
          BlocProvider<AdminHotelFormBloc>(
            create: (_) => AdminHotelFormBloc(createHotel),
          ),
          BlocProvider<AdminCitiesBloc>(
            create: (_) => AdminCitiesBloc(getCitiesUseCase)
              ..add(const AdminCitiesLoadRequested()),
          ),
          BlocProvider<AdminAddRoomBloc>(
            create: (_) => AdminAddRoomBloc(createRoom),
          ),
          BlocProvider<AdminRoomFeaturesBloc>(
            create: (_) => AdminRoomFeaturesBloc(upsertRoomFeatures),
          ),

          // ============ HOTELS ============
          BlocProvider<HotelsCubit>(
            create: (context) => HotelsCubit(
              repository: context.read<HotelsRepository>(),
            )..loadHotels(), // ✅ recommended so favorites page works immediately
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hotel Booking App',
          theme: ThemeData(
            useMaterial3: true,

            // ================== BRAND COLORS ==================
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E3A8A), // Primary Blue (Brand)
              brightness: Brightness.light,

              // Primary
              primary: const Color(0xFF1E3A8A), // Deep Royal Blue
              onPrimary: Colors.white,

              // Backgrounds
              background: const Color(0xFFF6F7FB), // Light gray background
              onBackground: const Color(0xFF0F172A),

              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),

              // Accent
              secondary: const Color(0xFFF5B301), // Gold accent
              onSecondary: const Color(0xFF0F172A),

              // Status colors
              error: const Color(0xFFEF4444), // Soft red
              onError: Colors.white,
            ),

            scaffoldBackgroundColor: const Color(0xFFF6F7FB),

            // ================== APP BAR ==================
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Color(0xFFF6F7FB),
              foregroundColor: Color(0xFF0B1220),
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0B1220),
              ),
            ),

            // ================== TEXT ==================
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
              titleMedium: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              bodyLarge: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
              bodyMedium: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),

            // ================== CARDS ==================
            cardTheme: CardTheme(
              elevation: 0,
              color: Colors.white,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),

            // ================== ELEVATED BUTTON ==================
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF1E3A8A), // Primary Blue
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),

            // ================== OUTLINED BUTTON ==================
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E3A8A),
                side: const BorderSide(color: Color(0xFF1E3A8A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),

            // ================== ICONS ==================
            iconTheme: const IconThemeData(
              color: Color(0xFF0B1220),
            ),

            // ================== BOTTOM NAV ==================
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF1E3A8A), // Primary blue
              unselectedItemColor: Color(0xFF64748B),
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
              elevation: 0,
            ),

            // ================== DIVIDERS ==================
            dividerTheme: const DividerThemeData(
              color: Color(0xFFE9EEF5),
              thickness: 1,
            ),

            // ================== SUCCESS / SNACKBAR ==================
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color(0xFF0B1220),
              contentTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          ),


          // ✅ AuthWrapper decides what to show based on auth state
          home: const AuthWrapper(),

          routes: {
            '/signin': (_) => const SignInScreen(),
            '/signup': (_) => const SignUpScreen(),

            // ✅ NOW home is the bottom navigation shell
            '/home': (_) => const MainShell(),

            // Admin route stays
            '/admin': (_) => const AdminAddHotelPage(),

            // (optional) if you still want direct access
            '/hotels': (_) => const HotelsListScreen(),
          },
        ),
      ),
    );
  }
}
