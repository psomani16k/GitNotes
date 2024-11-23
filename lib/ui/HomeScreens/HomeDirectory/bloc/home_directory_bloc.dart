import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_directory_event.dart';
part 'home_directory_state.dart';

class HomeDirectoryBloc extends Bloc<HomeDirectoryEvent, HomeDirectoryState> {
  HomeDirectoryBloc() : super(HomeDirectoryInitial()) {
    on<HomeDirectoryEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
