import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../models/quote.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class QuoteCardGenerator extends ConsumerStatefulWidget {
  final Quote quote;

  const QuoteCardGenerator({super.key, required this.quote});

  @override
  ConsumerState<QuoteCardGenerator> createState() => _QuoteCardGeneratorState();
}

class _QuoteCardGeneratorState extends ConsumerState<QuoteCardGenerator> {
  final GlobalKey _cardKey = GlobalKey();
  int _selectedStyle = 0;
  bool _isSavingToGallery = false;
  bool _isSharing = false;

  final List<_CardStyle> _styles = [
    _CardStyle(
      name: 'Minimal',
      gradient: const LinearGradient(
        colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      textColor: Colors.white,
      authorColor: Colors.white70,
    ),
    _CardStyle(
      name: 'Gradient',
      gradient: const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      textColor: Colors.white,
      authorColor: Colors.white70,
    ),
    _CardStyle(
      name: 'Sunset',
      gradient: const LinearGradient(
        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      textColor: Colors.white,
      authorColor: Colors.white70,
    ),
    _CardStyle(
      name: 'Ocean',
      gradient: const LinearGradient(
        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      textColor: Colors.white,
      authorColor: Colors.white70,
    ),
    _CardStyle(
      name: 'Forest',
      gradient: const LinearGradient(
        colors: [Color(0xFF134e5e), Color(0xFF71b280)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      textColor: Colors.white,
      authorColor: Colors.white70,
    ),
  ];

  Future<Uint8List?> _captureCard() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing card: $e');
      return null;
    }
  }

  Future<void> _saveToGallery() async {
    if (_isSavingToGallery || _isSharing) return;
    setState(() => _isSavingToGallery = true);

    try {
      final bytes = await _captureCard();
      if (bytes == null) {
        _showError('Failed to generate image');
        return;
      }

      // Save to temp file first
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/quote_card_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      // Save to gallery using gal
      await Gal.putImage(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.quoteSavedToGallery),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSavingToGallery = false);
    }
  }

  Future<void> _shareCard() async {
    if (_isSavingToGallery || _isSharing) return;
    setState(() => _isSharing = true);

    try {
      final bytes = await _captureCard();
      if (bytes == null) {
        _showError('Failed to generate image');
        return;
      }

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/quote_card_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      // Share the file
      await Share.shareXFiles([
        XFile(file.path),
      ], text: '"${widget.quote.text}" — ${widget.quote.author}');
    } catch (e) {
      _showError('Failed to share: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styles[_selectedStyle];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Create Quote Card',
                        style: AppTheme.headingStyle.copyWith(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Card preview
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: _QuoteCardPreview(
                        quote: widget.quote,
                        style: style,
                      ),
                    ),
                  ),
                ),
              ),

              // Style selector
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Choose Style',
                        style: AppTheme.labelStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _styles.length,
                        itemBuilder: (context, index) {
                          final isSelected = index == _selectedStyle;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedStyle = index),
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                gradient: _styles[index].gradient,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.save_alt,
                        label: 'Save to Gallery',
                        isLoading: _isSavingToGallery,
                        onPressed: _saveToGallery,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        isPrimary: true,
                        isLoading: _isSharing,
                        onPressed: _shareCard,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardStyle {
  final String name;
  final LinearGradient gradient;
  final Color textColor;
  final Color authorColor;

  _CardStyle({
    required this.name,
    required this.gradient,
    required this.textColor,
    required this.authorColor,
  });
}

class _QuoteCardPreview extends StatelessWidget {
  final Quote quote;
  final _CardStyle style;

  const _QuoteCardPreview({required this.quote, required this.style});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: style.gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Quote icon
            Icon(
              Icons.format_quote,
              size: 40,
              color: style.textColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            // Quote text
            Text(
              quote.text,
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: style.textColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Author
            Text(
              '— ${quote.author}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: style.authorColor,
              ),
            ),
            const Spacer(),
            // Branding
            Text(
              'QuoteVault',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: style.textColor.withValues(alpha: 0.4),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary ? AppTheme.primaryGradient : null,
        color: isPrimary ? null : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isPrimary
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: AppTheme.buttonStyle.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
