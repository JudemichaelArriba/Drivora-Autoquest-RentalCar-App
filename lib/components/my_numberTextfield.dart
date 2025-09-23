import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyNumberTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final int requiredLength;

  const MyNumberTextField({
    super.key,
    required this.controller,
    required this.label,
    this.requiredLength = 11,
  });

  @override
  State<MyNumberTextField> createState() => _MyNumberTextFieldState();
}

class _MyNumberTextFieldState extends State<MyNumberTextField> {
  String? _errorText;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  void _validate() {
    final text = widget.controller.text;

    setState(() {
      if (text.length != widget.requiredLength) {
        _errorText = "Number must be exactly ${widget.requiredLength} digits";
      } else {
        _errorText = null;
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (_errorText != null) return Colors.red;
      if (_focusNode.hasFocus) return const Color(0xFFFF7A30);
      return Colors.grey.shade600;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            focusNode: _focusNode,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(widget.requiredLength),
            ],
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(color: getColor()),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: getColor(), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: getColor(), width: 2),
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 5),
              child: Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
