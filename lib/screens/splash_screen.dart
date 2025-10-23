import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
            child: Image.asset('assets/images/chat.png', width: 150),
          ),
          const SizedBox(height: 12,),
          Text('Flutter Chat', style: Theme.of(context).textTheme.displayLarge!.copyWith(color: Theme.of(context).colorScheme.primary),),
          const SizedBox(height: 48,),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
