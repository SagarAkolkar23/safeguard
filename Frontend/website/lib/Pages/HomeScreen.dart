// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:website/Providers/phishing_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isHovering = false;

  late final AnimationController _animController;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _waveController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _waveController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a URL'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    await ref.read(phishingControllerProvider.notifier).checkUrl(query);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Advanced gradient background with mesh effect
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF0F172A),
                      Color(0xFF1E1B4B),
                      Color(0xFF312E81),
                      Color(0xFF1E40AF),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: GradientRotation(
                      _rotateController.value * 0.5 * math.pi,
                    ),
                  ),
                ),
              );
            },
          ),

          // Animated mesh overlay
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                final offset = _waveController.value * 2 * math.pi;
                return Positioned(
                  top: size.height * 0.1 + (math.sin(offset + index) * 50),
                  left:
                      size.width * (0.2 * index) +
                      (math.cos(offset + index) * 30),
                  child: Opacity(
                    opacity: 0.05 + (math.sin(offset + index) * 0.03).abs(),
                    child: Container(
                      width: 200 + (index * 80),
                      height: 200 + (index * 80),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.3),
                            const Color(0xFF8B5CF6).withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Grid pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: GridPainter()),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Elegant top bar
                FadeTransition(opacity: _fadeAnim, child: _buildTopBar()),

                // Main content area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),

                          // Hero section
                          FadeTransition(
                            opacity: _fadeAnim,
                            child: SlideTransition(
                              position: _slideAnim,
                              child: ScaleTransition(
                                scale: _scaleAnim,
                                child: _buildHeroSection(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Search section
                          FadeTransition(
                            opacity: _fadeAnim,
                            child: _buildSearchSection(),
                          ),

                          const SizedBox(height: 40),

                          // Feature cards
                          FadeTransition(
                            opacity: _fadeAnim,
                            child: _buildFeatureCards(),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'SecureGuard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // Action buttons
          Row(
            children: [
              _buildTopBarButton(Icons.history_rounded, 'History', "/History"),
              const SizedBox(width: 8),
              _buildTopBarButton(Icons.person_rounded, 'Profile', "/Profile"),
              const SizedBox(width: 8),
              _buildTopBarButton(
                Icons.settings_rounded,
                'Settings',
                "/Settings",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarButton(IconData icon, String tooltip, String route) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: IconButton(
        onPressed: () {
          context.go(route);
        },
        icon: Icon(icon, color: Colors.white, size: 22),
        tooltip: tooltip,
        splashRadius: 24,
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Animated shield icon
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.08),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.2),
                      const Color(0xFF8B5CF6).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF6366F1,
                      ).withOpacity(0.3 + _pulseController.value * 0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        // Main headline
        const Text(
          'Advanced Phishing\nProtection',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 18),

        // Subheadline
        Text(
          'Real-time URL analysis powered by AI\nto keep you safe online',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 17,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    final phishingState = ref.watch(phishingControllerProvider);

    return Container(
      constraints: const BoxConstraints(maxWidth: 650),
      child: Column(
        children: [
          // Search input with advanced styling
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: 'Paste URL to analyze security...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white70,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Display results using complete PhishingResponse model
          phishingState.when(
            data: (response) {
              if (response == null) return const SizedBox.shrink();

              if (!response.success) {
                return _buildErrorCard(response.message);
              }

              final result = response.data;
              return _buildResultCard(result);
            },
            loading: () => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing URL security...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            error: (error, stack) => _buildErrorCard(error.toString()),
          ),

          const SizedBox(height: 20),

          // CTA Button
          MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(_isHovering ? 1.02 : 1.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF6366F1,
                    ).withOpacity(_isHovering ? 0.5 : 0.3),
                    blurRadius: _isHovering ? 30 : 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening extension download...'),
                      backgroundColor: Color(0xFF6366F1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Get Browser Extension',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(dynamic result) {
    // Extract all fields from the complete model
    final isPhishing = result.isPhishing;
    final confidence = result.confidence;
    final url = result.url;
    final riskLevel = result.riskLevel;
    final probability = result.probability;

    // Determine color based on risk level
    Color getRiskColor() {
      switch (riskLevel) {
        case 'HIGH':
          return Colors.red;
        case 'MEDIUM':
          return Colors.orange;
        case 'LOW':
          return Colors.green;
        default:
          return Colors.blue;
      }
    }

    final riskColor = getRiskColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [riskColor.withOpacity(0.15), riskColor.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: riskColor.withOpacity(0.2),
            ),
            child: Icon(
              isPhishing ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: riskColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),

          // Main status
          Text(
            isPhishing ? 'Potential Threat Detected!' : 'URL Appears Safe',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: riskColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Risk level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withOpacity(0.3)),
            ),
            child: Text(
              'Risk Level: $riskLevel',
              style: TextStyle(
                color: riskColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Confidence metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetricChip(
                'Confidence',
                '${confidence.toStringAsFixed(1)}%',
              ),
              const SizedBox(width: 12),
              _buildMetricChip(
                'Probability',
                '${(probability * 100).toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // URL display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              url,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Warning/info text
          Text(
            isPhishing
                ? 'This URL may be attempting to steal your information. Proceed with extreme caution.'
                : 'No immediate threats detected. However, always exercise caution online.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.15), Colors.red.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analysis Failed',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error.contains('Exception:')
                      ? error.replaceFirst('Exception:', '').trim()
                      : error,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.speed_rounded,
                  'Instant Analysis',
                  'Real-time threat detection',
                  const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildFeatureCard(
                  Icons.psychology_rounded,
                  'AI Powered',
                  'Machine learning detection',
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.shield_rounded,
                  'Secure & Private',
                  'Your data stays protected',
                  const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildFeatureCard(
                  Icons.flash_on_rounded,
                  'Lightning Fast',
                  'Results in milliseconds',
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String subtitle,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
