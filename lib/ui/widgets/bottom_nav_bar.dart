
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../utils/app_theme.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFabPressed;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
  }

  void _handleTap(int index) {
    // if (_selectedIndex == index) return;
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    _selectedIndex = widget.currentIndex;
    const double barHeight = 70;
    const double fabOuter = 60; // tighter circle like screenshot
    const double fabInner = 52;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: barHeight + (fabOuter / 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// ✅ Green background bar (touches bottom edge perfectly)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              child: Container(
                height: barHeight,
                color: kGreen,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left icons
                    Row(
                      children: [
                        _buildNavIcon(LucideIcons.home, 0),
                        const SizedBox(width: 26),
                        _buildNavIcon(LucideIcons.search, 1),
                      ],
                    ),
                    // Right icons
                    Row(
                      children: [
                        _buildNavIcon(LucideIcons.messageSquare, 3),
                        const SizedBox(width: 26),
                        _buildNavIcon(LucideIcons.user, 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ✅ FAB section (white circle perfectly blends with green bar)
          Positioned(
            bottom: barHeight - (fabOuter / 2),
            left: (screenWidth / 2) - (fabOuter / 2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // White circle (base)
                Container(
                  width: fabOuter,
                  height: fabOuter,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),

                // Teal Floating Button
                SizedBox(
                  width: fabInner,
                  height: fabInner,
                  child: FloatingActionButton(
                    onPressed: widget.onFabPressed,
                    backgroundColor: kTeal,
                    elevation: 0,
                    shape: const CircleBorder(),
                    child: const Icon(
                      LucideIcons.plus,
                      color: Colors.white,
                      size: 28,
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

  /// ✅ Icon builder (white icons with light animation)
  Widget _buildNavIcon(IconData icon, int index) {
    final bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _handleTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isActive ? 28 : 26,
        ),
      ),
    );
  }
}
