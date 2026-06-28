import 'package:flutter_bloc/flutter_bloc.dart';

class InfoCubit extends Cubit<String> {
  InfoCubit() : super('');

  void updateQuery(String value) => emit(value);
}
