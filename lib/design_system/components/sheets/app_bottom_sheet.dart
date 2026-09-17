import 'package:flutter/material.dart';

class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        24,
        8,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(child: builder(context)),
    ),
  );
}
