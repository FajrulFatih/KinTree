import 'package:flutter/material.dart';

/// FilledButton yang menampilkan spinner selama [onPressed] async berjalan
/// dan mencegah double-tap.
class AsyncButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String label;

  const AsyncButton({super.key, required this.onPressed, required this.label});

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _loading = false;

  Future<void> _run() async {
    setState(() => _loading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _loading ? null : _run,
      child: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(widget.label),
    );
  }
}
