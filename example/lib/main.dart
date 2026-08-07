import 'package:appdimens/appdimens.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AppDimensExample());

class AppDimensExample extends StatelessWidget {
  const AppDimensExample({super.key});
  @override
  Widget build(BuildContext context) => AppDimensProvider(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const Gallery(),
    ),
  );
}

class Gallery extends StatelessWidget {
  const Gallery({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.dimensConfiguration;
    return Scaffold(
      appBar: AppBar(title: const Text('AppDimens Dynamic Flutter 3.1.6')),
      body: GridView.extent(
        maxCrossAxisExtent: 340,
        childAspectRatio: 1.5,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          for (final strategy in DimensStrategy.values)
            Card.filled(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strategy.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      DynamicDimens.resolve(
                        16,
                        strategy: strategy,
                        configuration: c,
                      ).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '${c.screenWidth.toInt()} × ${c.screenHeight.toInt()}',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
