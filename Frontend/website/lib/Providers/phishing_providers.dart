// lib/Providers/phishing_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:website/Services/PhishingDetectionService%20.dart';
import 'package:website/core/BaseUrl.dart';

final phishingServiceProvider = Provider<PhishingDetectionService>((ref) {
  return PhishingDetectionService(baseUrl: backendBaseUrl);
});

final phishingControllerProvider =
    StateNotifierProvider<PhishingController, AsyncValue<Map<String, dynamic>>>(
      (ref) {
        final service = ref.watch(phishingServiceProvider);
        return PhishingController(service);
      },
    );

class PhishingController
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final PhishingDetectionService _service;

  PhishingController(this._service) : super(const AsyncData({}));

  Future<void> checkUrl(String url) async {
    state = const AsyncLoading();

    try {
      final result = await _service.checkPhishing(url);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ✅ Method to clear results
  void clearResults() {
    state = const AsyncData({});
  }
}
