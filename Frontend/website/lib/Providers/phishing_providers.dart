// lib/Providers/phishing_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:website/Services/PhishingDetectionService%20.dart';
import 'package:website/core/BaseUrl.dart';
import 'package:website/models/PhishingResult.dart';

// 🧩 1️⃣ Provider for Service
final phishingServiceProvider = Provider<PhishingDetectionService>((ref) {
  return PhishingDetectionService(baseUrl: backendBaseUrl);
});

// 🧠 2️⃣ StateNotifierProvider using the PhishingResponse model
final phishingControllerProvider =
    StateNotifierProvider<PhishingController, AsyncValue<PhishingResponse?>>((
      ref,
    ) {
      final service = ref.watch(phishingServiceProvider);
      return PhishingController(service);
    });

// ⚙️ 3️⃣ Controller
class PhishingController extends StateNotifier<AsyncValue<PhishingResponse?>> {
  final PhishingDetectionService _service;

  PhishingController(this._service) : super(const AsyncData(null));

  Future<void> checkUrl(String url) async {
    state = const AsyncLoading();

    try {
      final result = await _service.checkPhishing(url);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void clearResults() {
    state = const AsyncData(null);
  }
}
