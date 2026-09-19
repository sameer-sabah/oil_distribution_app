import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

class RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback onTap;
  final bool compact;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    required this.onTap,
    this.compact = false,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool hover = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.color ?? AppColors.primary;
    final compact = widget.compact;

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() {
        hover = false;
        pressed = false;
      }),
      child: AnimatedScale(
        scale: pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            splashColor: cardColor.withValues(alpha: .15),
            highlightColor: Colors.transparent,
            onTapDown: (_) => setState(() => pressed = true),
            onTapUp: (_) => setState(() => pressed = false),
            onTapCancel: () => setState(() => pressed = false),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(compact ? 11 : 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: hover ? cardColor : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hover
                        ? cardColor.withValues(alpha: .20)
                        : AppColors.shadow,
                    blurRadius: hover ? 24 : 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: compact ? 48 : 64,
                    height: compact ? 48 : 64,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(compact ? 14 : 18),
                    ),
                    child: Icon(
                      widget.icon,
                      color: cardColor,
                      size: compact ? 28 : 34,
                    ),
                  ),

                  SizedBox(width: compact ? 12 : 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: compact ? 17 : 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: compact ? 3 : 6),
                        Text(
                          widget.subtitle,
                          maxLines: compact ? 1 : null,
                          overflow:
                          compact
                              ? TextOverflow.ellipsis
                              : null,
                          style: TextStyle(
                            fontSize: compact ? 12.5 : 14,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedSlide(
                    duration: const Duration(milliseconds: 250),
                    offset: hover
                        ? const Offset(0.15, 0)
                        : Offset.zero,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: cardColor,
                      size: compact ? 18 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fade(duration: 500.ms)
        .slideY(begin: .20, curve: Curves.easeOut)
        .scale(
      begin: const Offset(.95, .95),
      end: const Offset(1, 1),
    );
  }
}