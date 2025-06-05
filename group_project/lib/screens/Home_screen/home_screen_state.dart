part of 'home_screen_cubit.dart';

class HomeScreenState {
  final Set<String> favoritePizzaIds;

  HomeScreenState({
    required this.favoritePizzaIds,
  });

  factory HomeScreenState.initial() {
    return HomeScreenState(favoritePizzaIds: {});
  }

  HomeScreenState copyWith({
    Set<String>? favoritePizzaIds,
  }) {
    return  HomeScreenState(
      favoritePizzaIds: favoritePizzaIds??this.favoritePizzaIds ,
    );
  }
}


