import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class DialogHelper {
  static void showSuccessDialog(
    BuildContext context,
    String message, {
    VoidCallback? onContinue,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: scale,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Container(
              width: 320,
              height: 340,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7A30),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.all(28),
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: animation,
                        curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Success",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onContinue != null) onContinue();
                      },
                      child: const Text(
                        "Okay",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showErrorDialog(
    BuildContext context,
    String errorMessage, {
    VoidCallback? onClose,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: errorMessage,
      confirmBtnColor: Colors.red,
      confirmBtnTextStyle: const TextStyle(fontSize: 18, color: Colors.white),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (onClose != null) onClose();
      },
    );
  }

  static void showWarningDialog(
    BuildContext context,
    String message, {
    VoidCallback? onClose,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: message,
      confirmBtnColor: Colors.orange,
      confirmBtnTextStyle: const TextStyle(fontSize: 18, color: Colors.white),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (onClose != null) onClose();
      },
    );
  }
}
