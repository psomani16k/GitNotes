import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'markdown_rendering_event.dart';
part 'markdown_rendering_state.dart';

class MarkdownRenderingBloc extends Bloc<MarkdownRenderingEvent, MarkdownRenderingState> {
  MarkdownRenderingBloc() : super(MarkdownRenderingInitial()) {
    on<MarkdownRenderingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
