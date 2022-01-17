import 'package:flutter/material.dart';

class WideButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;
  const WideButton({Key? key, required this.callback, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: Theme.of(context).cardColor),
          ),
          onPressed: callback,
          style: ButtonStyle(
            shape: MaterialStateProperty.all(ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }
}
