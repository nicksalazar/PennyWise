import 'package:flutter/material.dart';
import 'package:habit_harmony/providers/loading_provider.dart';
import 'package:provider/provider.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingProvider>(
      builder: (context, loadingProvider, child) {
        if (!loadingProvider.isLoading) {
          return SizedBox.shrink();
        }
        return Container(
          color: Colors.black54,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
