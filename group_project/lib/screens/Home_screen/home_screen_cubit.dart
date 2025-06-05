import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  final String userId;
  final CollectionReference favoritesRef;

  HomeScreenCubit(this.userId)
      : favoritesRef = FirebaseFirestore.instance.collection('favorites'),
        super(HomeScreenState.initial()) {
    _loadFavorites();
  }

  void _loadFavorites() async {
    try {
      final snapshot = await favoritesRef
          .where('userId', isEqualTo: userId) // ✅ filter by current userId
          .get();

      final ids = snapshot.docs.map((doc) => doc.id).toSet();
      emit(state.copyWith(favoritePizzaIds: ids));
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  void toggleFavorite(String pizzaId, Map<String, dynamic> pizzaData) async {
    final current = state.favoritePizzaIds;
    final docRef = favoritesRef.doc(pizzaId);

    if (current.contains(pizzaId)) {
      await docRef.delete();
      emit(state.copyWith(favoritePizzaIds: {...current}..remove(pizzaId)));
    } else {
      final dataWithUser = {
        ...pizzaData,
        'userId': userId, //
      };

      await docRef.set(dataWithUser);
      emit(state.copyWith(favoritePizzaIds: {...current, pizzaId}));
    }
  }

  bool isFavorite(String pizzaId) {
    return state.favoritePizzaIds.contains(pizzaId);
  }
}