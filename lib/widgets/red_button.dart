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

class _RedButtonState extends State<RedButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (!widget.enabled) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void didUpdateWidget(RedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    if (!widget.enabled) return;
    HapticFeedback.heavyImpact();
    widget.onPressed();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pressed ? 0.9 : _pulseAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.38,
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer base ring — the metal housing
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade600,
                        Colors.grey.shade800,
                        Colors.grey.shade900,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.danger.withValues(alpha: 0.22),
                        blurRadius: 14,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                // Yellow hazard ring
                Container(
                  width: 144,
                  height: 144,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.shade600, width: 4),
                  ),
                ),
                // Inner red dome — the button itself
                AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  width: _pressed ? 118 : 126,
                  height: _pressed ? 118 : 126,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.3),
                      colors: [
                        AppColors.danger.shade400,
                        AppColors.danger.shade600,
                        AppColors.danger.shade800,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    border: Border.all(
                      color: AppColors.danger.shade900,
                      width: 3,
                    ),
                    boxShadow: _pressed
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.danger.shade900.withValues(
                                alpha: 0.6,
                              ),
                              offset: const Offset(0, 6),
                              blurRadius: 0,
                            ),
                          ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontFamily: AppFonts.family,
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: AppColors.danger.shade900,
                                offset: const Offset(1, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
