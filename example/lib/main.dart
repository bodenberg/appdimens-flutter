import 'package:appdimens/appdimens.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AppDimensExample());

class AppDimensExample extends StatelessWidget {
  const AppDimensExample({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: const StrategyGallery(),
  );
}

class StrategyGallery extends StatelessWidget {
  const StrategyGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final viewport = AppDimensViewport.fromMediaQuery(media);
    return Scaffold(
      appBar: AppBar(title: const Text('AppDimens — 13 strategies')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100
              ? 4
              : constraints.maxWidth >= 700
              ? 3
              : constraints.maxWidth >= 460
              ? 2
              : 1;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 240,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: AppDimensStrategy.values.length,
            itemBuilder: (context, index) {
              final strategy = AppDimensStrategy.values[index];
              final scale = AppDimensScale(
                strategy == AppDimensStrategy.percentage ? 20 : 48,
                strategy: strategy,
                minValue: strategy == AppDimensStrategy.fluid ? 36 : null,
                maxValue: strategy == AppDimensStrategy.fluid ? 72 : null,
              );
              final result = scale.calculateViewport(viewport);
              return Card.filled(
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
                        '${result.toStringAsFixed(2)} logical px',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${viewport.width.toInt()} × '
                        '${viewport.height.toInt()} viewport',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
