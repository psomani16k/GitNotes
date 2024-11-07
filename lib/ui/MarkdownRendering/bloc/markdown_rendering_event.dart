part of 'markdown_rendering_bloc.dart';

@immutable
sealed class MarkdownRenderingEvent {}

final class MarkdownRenderingReadFileEvent extends MarkdownRenderingEvent {
  final File file;

  MarkdownRenderingReadFileEvent({required this.file});
}
