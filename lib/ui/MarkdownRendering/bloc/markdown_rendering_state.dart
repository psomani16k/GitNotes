part of 'markdown_rendering_bloc.dart';

@immutable
sealed class MarkdownRenderingState {}

final class MarkdownRenderingInitial extends MarkdownRenderingState {}

final class MarkdownRenderingRenderDataState extends MarkdownRenderingState {
  final String data;

  MarkdownRenderingRenderDataState({required this.data});
}
