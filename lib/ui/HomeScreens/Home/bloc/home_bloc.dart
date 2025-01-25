import 'package:bloc/bloc.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<HomeChooseRepositoryEvent>((event, emit) {
      GitRepoManager.getInstance().setCurrentRepo(event.repo);
      emit(HomeSetRepositoryState(repo: event.repo));
    });
  }
}
