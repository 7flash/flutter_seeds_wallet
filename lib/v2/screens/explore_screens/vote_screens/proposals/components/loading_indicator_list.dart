import 'package:flutter/material.dart';

/// A circular progress indicator made to work inside a Listview
/// commonly showed at the bottom of a ListView.Builder meanwhile
/// this fetch data.
class LoadingIndicatorList extends StatelessWidget {
  const LoadingIndicatorList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      alignment: Alignment.center,
      child: const Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
