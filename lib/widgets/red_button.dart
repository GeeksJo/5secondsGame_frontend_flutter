import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class RedButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  const RedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  State<RedButton> createState() => _RedButtonState();
}

class _RedButtonState extends State<RedButton> {
  static const double _diameter = 118;
  static const double _pressScale = 0.965;

  bool _pressed = false;
  bool _tapLocked = false;

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    if (!widget.enabled) return;
    if (_tapLocked) return;
    _tapLocked = true;
    HapticFeedback.mediumImpact();
    widget.onPressed();
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      _tapLocked = false;
    });
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.38,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          scale: _pressed ? _pressScale : 1.0,
          child: SizedBox(
            width: _diameter,
            height: _diameter,
            child: Material(
              type: MaterialType.transparency,
              child: InkResponse(
                onTapDown: widget.enabled ? _onTapDown : null,
                onTapUp: widget.enabled ? _onTapUp : null,
                onTapCancel: widget.enabled ? _onTapCancel : null,
                radius: _diameter * 0.5,
                containedInkWell: true,
                highlightShape: BoxShape.circle,
                splashColor: Colors.white.withValues(alpha: 0.10),
                highlightColor: Colors.white.withValues(alpha: 0.05),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 110),
                  curve: Curves.easeOutCubic,
                  width: _diameter,
                  height: _diameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.danger.shade400,
                        AppColors.danger.shade700,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.32),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.family,
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        letterSpacing: 0.2,
                        shadows: const [
                          Shadow(
                            color: Color(0x66000000),
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
