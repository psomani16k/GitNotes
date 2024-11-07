import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'markdown_rendering_event.dart';
part 'markdown_rendering_state.dart';

class MarkdownRenderingBloc
    extends Bloc<MarkdownRenderingEvent, MarkdownRenderingState> {
  MarkdownRenderingBloc() : super(MarkdownRenderingInitial()) {
    on<MarkdownRenderingReadFileEvent>((event, emit) async {
      String data = await event.file.readAsString();
      emit(MarkdownRenderingRenderDataState(data: data));
    });
  }
}
