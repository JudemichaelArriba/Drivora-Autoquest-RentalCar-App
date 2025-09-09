import 'package:flutter/material.dart';

class MyTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? errorText;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.errorText,
  });

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(color: Colors.grey[600]),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: widget.errorText != null
                      ? Colors.red
                      : const Color.fromARGB(255, 206, 206, 206),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: widget.errorText != null
                      ? Colors.red
                      : const Color(0xFFFF7A30),
                  width: 2,
                ),
              ),
              fillColor: Colors.white,
              filled: true,
              suffixIcon: widget.obscureText
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Image.asset(
                        _obscureText
                            ? 'lib/images/seepass.png'
                            : 'lib/images/notseepass.png',
                        width: 24,
                        height: 24,
                      ),
                    )
                  : null,
            ),
          ),
          if (widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 5),
              child: Text(
                widget.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
