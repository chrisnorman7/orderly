import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns a [builder] when the given [value] has data.
class AsyncValueBuilder<T> extends StatelessWidget {
  /// Create an instance.
  const AsyncValueBuilder({
    required this.value,
    required this.builder,
    super.key,
  });

  /// The value to work with.
  final AsyncValue<T> value;

  /// The builder to use.
  final Widget Function(T data) builder;

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    final localValue = value;
    return switch (localValue) {
      AsyncLoading<T>() => const LoadingWidget(),
      AsyncData<T>() => builder(localValue.value),
      AsyncError<T>() => ErrorListView(
        error: localValue.error,
        stackTrace: localValue.stackTrace,
      ),
    };
  }
}
