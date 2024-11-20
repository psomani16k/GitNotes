import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_git_event.dart';
part 'home_git_state.dart';

class HomeGitBloc extends Bloc<HomeGitEvent, HomeGitState> {
  HomeGitBloc() : super(HomeGitInitial()) {
    on<HomeGitEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
