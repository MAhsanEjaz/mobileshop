import 'package:flutter/material.dart';
import 'package:shopapp/utils.dart';

class CustomLoader extends StatefulWidget {
  final double size;
  final Color color;

  const CustomLoader({super.key, this.size = 60, this.color = appColor});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _scale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotate = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _rotate.value * 6.28319, // 2π rad
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 8, color: widget.color),
        ),
      ),
    );
  }
}
