import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class DialogHelper {
  static void showSuccessDialog(
    BuildContext context,
    String message, {
    VoidCallback? onContinue,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: message,
      confirmBtnColor: Colors.green,
      confirmBtnTextStyle: const TextStyle(fontSize: 18, color: Colors.white),
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (onContinue != null) onContinue();
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
