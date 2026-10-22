import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:druid_app/user_interface/theme/druid_tokens.dart';
import 'package:druid_app/user_interface/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Mostra caricamento, errore o contenuto di una `Validation` caricata da un `LoadableController`.
class ValidationView<T> extends StatelessWidget {
  final Validation<T> data;
  final bool loading;
  final Widget Function(BuildContext context, T value) builder;
  final VoidCallback? onRetry;

  const ValidationView({super.key, required this.data, required this.loading, required this.builder, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return data.fold(
      (failures) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Gaps.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.loadingError, style: context.texts.titleMedium),
              const SizedBox(height: Gaps.s),
              Text(failures.map((f) => f.toString()).join('\n'), textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: Gaps.l),
                FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
              ],
            ],
          ),
        ),
      ),
      (value) => builder(context, value),
    );
  }
}
