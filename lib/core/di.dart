import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../common/services/api/cat_api_client.dart';
import 'analytics/analytics.dart';
import 'analytics/firebase_analytics_service.dart';
import 'analytics/noop_analytics_service.dart';
import 'services/secure_key_value_store.dart';
import 'services/onboarding_storage.dart';
import '../features/auth/data/datasources/local/auth_local_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_auth_status.dart';
import '../features/auth/domain/usecases/login.dart';
import '../features/auth/domain/usecases/logout.dart';
import '../features/auth/domain/usecases/sign_up.dart';
import '../features/auth/domain/usecases/update_username.dart';
import '../features/auth/domain/usecases/change_password.dart';
import '../features/auth/presentation/state/auth_controller.dart';
import '../features/cats/data/datasources/local/liked_cats_local_data_source.dart';
import '../features/cats/data/datasources/remote/cats_remote_data_source.dart';
import '../features/cats/data/repositories/cats_repository_impl.dart';
import '../features/cats/domain/repositories/cats_repository.dart';
import '../features/cats/domain/usecases/dislike_cat.dart';
import '../features/cats/domain/usecases/get_breeds.dart';
import '../features/cats/domain/usecases/get_liked_cats.dart';
import '../features/cats/domain/usecases/get_random_cat.dart';
import '../features/cats/domain/usecases/like_cat.dart';
import '../features/cats/domain/usecases/remove_liked_cat_at.dart';
import '../features/cats/presentation/state/breeds_controller.dart';
import '../features/cats/presentation/state/cat_swipe_controller.dart';
import '../features/cats/presentation/state/liked_cats_controller.dart';

final GetIt sl = GetIt.instance;
const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');
const bool _enableFirebaseAnalytics = bool.fromEnvironment(
  'ENABLE_FIREBASE_ANALYTICS',
);

Future<void> configureDependencies() async {
  if (!sl.isRegistered<SharedPreferences>()) {
    final preferences = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(preferences);
  }

  if (!sl.isRegistered<OnboardingStorage>()) {
    sl.registerLazySingleton<OnboardingStorage>(
      () => OnboardingStorageImpl(sl<SharedPreferences>()),
    );
  }

  if (!sl.isRegistered<Analytics>()) {
    if (!_isFlutterTest && _enableFirebaseAnalytics) {
      try {
        await Firebase.initializeApp();
        sl.registerSingleton<Analytics>(
          FirebaseAnalyticsService(FirebaseAnalytics.instance),
        );
      } catch (_) {
        sl.registerSingleton<Analytics>(const NoopAnalyticsService());
      }
    } else {
      sl.registerSingleton<Analytics>(const NoopAnalyticsService());
    }
  }

  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  }

  if (!sl.isRegistered<SecureKeyValueStore>()) {
    sl.registerLazySingleton<SecureKeyValueStore>(
      () => FlutterSecureKeyValueStore(sl<FlutterSecureStorage>()),
    );
  }

  if (!sl.isRegistered<CatApiClient>()) {
    sl.registerLazySingleton<CatApiClient>(CatApiClient.new);
  }

  if (!sl.isRegistered<CatsRemoteDataSource>()) {
    sl.registerLazySingleton<CatsRemoteDataSource>(
      () => CatsRemoteDataSourceImpl(sl<CatApiClient>()),
    );
  }

  if (!sl.isRegistered<LikedCatsLocalDataSource>()) {
    sl.registerLazySingleton<LikedCatsLocalDataSource>(
      () => LikedCatsLocalDataSourceImpl(sl<SharedPreferences>()),
    );
  }

  if (!sl.isRegistered<CatsRepository>()) {
    sl.registerLazySingleton<CatsRepository>(
      () => CatsRepositoryImpl(
        sl<CatsRemoteDataSource>(),
        sl<LikedCatsLocalDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<AuthLocalDataSource>()) {
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sl<SecureKeyValueStore>()),
    );
  }

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthLocalDataSource>()),
    );
  }

  if (!sl.isRegistered<GetRandomCat>()) {
    sl.registerLazySingleton<GetRandomCat>(
      () => GetRandomCat(sl<CatsRepository>()),
    );
  }
  if (!sl.isRegistered<GetBreeds>()) {
    sl.registerLazySingleton<GetBreeds>(() => GetBreeds(sl<CatsRepository>()));
  }
  if (!sl.isRegistered<GetLikedCats>()) {
    sl.registerLazySingleton<GetLikedCats>(
      () => GetLikedCats(sl<CatsRepository>()),
    );
  }
  if (!sl.isRegistered<LikeCat>()) {
    sl.registerLazySingleton<LikeCat>(() => LikeCat(sl<CatsRepository>()));
  }
  if (!sl.isRegistered<DislikeCat>()) {
    sl.registerLazySingleton<DislikeCat>(
      () => DislikeCat(sl<CatsRepository>()),
    );
  }
  if (!sl.isRegistered<RemoveLikedCatAt>()) {
    sl.registerLazySingleton<RemoveLikedCatAt>(
      () => RemoveLikedCatAt(sl<CatsRepository>()),
    );
  }

  if (!sl.isRegistered<SignUp>()) {
    sl.registerLazySingleton<SignUp>(() => SignUp(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<Login>()) {
    sl.registerLazySingleton<Login>(() => Login(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<Logout>()) {
    sl.registerLazySingleton<Logout>(() => Logout(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<GetAuthStatus>()) {
    sl.registerLazySingleton<GetAuthStatus>(
      () => GetAuthStatus(sl<AuthRepository>()),
    );
  }
  if (!sl.isRegistered<UpdateUsername>()) {
    sl.registerLazySingleton<UpdateUsername>(
      () => UpdateUsername(sl<AuthRepository>()),
    );
  }
  if (!sl.isRegistered<ChangePassword>()) {
    sl.registerLazySingleton<ChangePassword>(
      () => ChangePassword(sl<AuthRepository>()),
    );
  }

  if (!sl.isRegistered<AuthController>()) {
    sl.registerLazySingleton<AuthController>(
      () => AuthController(
        sl<SignUp>(),
        sl<Login>(),
        sl<Logout>(),
        sl<GetAuthStatus>(),
        sl<UpdateUsername>(),
        sl<ChangePassword>(),
        sl<Analytics>(),
      ),
    );
  }

  if (!sl.isRegistered<CatSwipeController>()) {
    sl.registerFactory<CatSwipeController>(
      () => CatSwipeController(
        sl<GetRandomCat>(),
        sl<GetLikedCats>(),
        sl<LikeCat>(),
        sl<DislikeCat>(),
      ),
    );
  }

  if (!sl.isRegistered<BreedsController>()) {
    sl.registerFactory<BreedsController>(
      () => BreedsController(sl<GetBreeds>()),
    );
  }

  if (!sl.isRegistered<LikedCatsController>()) {
    sl.registerFactory<LikedCatsController>(
      () => LikedCatsController(sl<GetLikedCats>(), sl<RemoveLikedCatAt>()),
    );
  }
}
