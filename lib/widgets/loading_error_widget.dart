import 'package:flutter/material.dart';

class LoadingErrorWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String loadingText;

  const LoadingErrorWidget({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
    this.loadingText = 'Cargando...',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: const CircularProgressIndicator(strokeWidth: 3),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              loadingText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
