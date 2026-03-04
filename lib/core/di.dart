import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/services/api/cat_api_client.dart';
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

Future<void> configureDependencies() async {
  if (sl.isRegistered<CatsRepository>()) {
    return;
  }

  final preferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(preferences);

  sl.registerLazySingleton<CatApiClient>(CatApiClient.new);

  sl.registerLazySingleton<CatsRemoteDataSource>(
    () => CatsRemoteDataSourceImpl(sl<CatApiClient>()),
  );

  sl.registerLazySingleton<LikedCatsLocalDataSource>(
    () => LikedCatsLocalDataSourceImpl(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<CatsRepository>(
    () => CatsRepositoryImpl(
      sl<CatsRemoteDataSource>(),
      sl<LikedCatsLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetRandomCat>(
    () => GetRandomCat(sl<CatsRepository>()),
  );
  sl.registerLazySingleton<GetBreeds>(() => GetBreeds(sl<CatsRepository>()));
  sl.registerLazySingleton<GetLikedCats>(
    () => GetLikedCats(sl<CatsRepository>()),
  );
  sl.registerLazySingleton<LikeCat>(() => LikeCat(sl<CatsRepository>()));
  sl.registerLazySingleton<DislikeCat>(() => DislikeCat(sl<CatsRepository>()));
  sl.registerLazySingleton<RemoveLikedCatAt>(
    () => RemoveLikedCatAt(sl<CatsRepository>()),
  );

  sl.registerFactory<CatSwipeController>(
    () => CatSwipeController(
      sl<GetRandomCat>(),
      sl<GetLikedCats>(),
      sl<LikeCat>(),
      sl<DislikeCat>(),
    ),
  );

  sl.registerFactory<BreedsController>(() => BreedsController(sl<GetBreeds>()));

  sl.registerFactory<LikedCatsController>(
    () => LikedCatsController(sl<GetLikedCats>(), sl<RemoveLikedCatAt>()),
  );
}
