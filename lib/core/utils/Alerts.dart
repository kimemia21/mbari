

import 'package:flutter/material.dart';
import 'package:status_alert/status_alert.dart';

void showalert({
  required bool success,
  required BuildContext context,
  required String title,
  required String subtitle,
  int secs = 2,
 }) {
  const TextStyle titleStyle = TextStyle(
    fontFamily: 'SFNS',
    color: Colors.black,
    fontSize: 30,
  );

  const TextStyle subtitleStyle = TextStyle(
    fontFamily: 'SFNS',
    color: Colors.black,
  );

  final StatusAlertTextConfiguration titleConfig = StatusAlertTextConfiguration(
    style: titleStyle,
  );

  final StatusAlertTextConfiguration subtitleConfig =
      StatusAlertTextConfiguration(
    style: subtitleStyle,
  );

  final IconConfiguration iconConfig = IconConfiguration(
    icon: success ? Icons.done : Icons.error,
    color: success ? Colors.green : Colors.red,
  );

  StatusAlert.show(
    context,
    duration: Duration(seconds: secs),
    maxWidth: 400,
    title: title,
    subtitle: subtitle,
    titleOptions: titleConfig,
    subtitleOptions: subtitleConfig,
    configuration: iconConfig,
    backgroundColor:
        success ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4),
  );
}





