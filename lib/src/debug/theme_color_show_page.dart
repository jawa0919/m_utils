import 'package:flutter/material.dart';

class ThemeColorShowPage extends StatefulWidget {
  const ThemeColorShowPage({super.key});

  @override
  State<ThemeColorShowPage> createState() => _ThemeColorShowPageState();
}

class _ThemeColorShowPageState extends State<ThemeColorShowPage> {
  late ThemeData _themeData;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context).brightness == Brightness.dark
        ? ThemeData(brightness: Brightness.dark)
        : Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('所有颜色'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ColorSchemePage(),
                ),
              );
            },
            icon: const Icon(Icons.developer_board),
          ),
        ],
      ),
      body: Card(
        margin: const EdgeInsets.all(16),
        elevation: 0,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: <Widget>[
              SwitchListTile(
                title: const Text('深色样式'),
                onChanged: (bool value) {
                  setState(() {});
                },
                value: Theme.of(context).brightness == Brightness.dark,
              ),
              ListTile(
                subtitle: Text(_themeData.scaffoldBackgroundColor.toString()),
                title: const Text('scaffoldBackgroundColor'),
                trailing: Container(
                  color: _themeData.scaffoldBackgroundColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.canvasColor.toString()),
                title: const Text('canvasColor'),
                trailing: Container(
                  color: _themeData.canvasColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.cardColor.toString()),
                title: const Text('cardColor'),
                trailing: Container(
                  color: _themeData.cardColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.disabledColor.toString()),
                title: const Text('disabledColor'),
                trailing: Container(
                  color: _themeData.disabledColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.dividerColor.toString()),
                title: const Text('dividerColor'),
                trailing: Container(
                  color: _themeData.dividerColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.focusColor.toString()),
                title: const Text('focusColor'),
                trailing: Container(
                  color: _themeData.focusColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.highlightColor.toString()),
                title: const Text('highlightColor'),
                trailing: Container(
                  color: _themeData.highlightColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.hintColor.toString()),
                title: const Text('hintColor'),
                trailing: Container(
                  color: _themeData.hintColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.hoverColor.toString()),
                title: const Text('hoverColor'),
                trailing: Container(
                  color: _themeData.hoverColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.primaryColor.toString()),
                title: const Text('primaryColor'),
                trailing: Container(
                  color: _themeData.primaryColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.primaryColorDark.toString()),
                title: const Text('primaryColorDark'),
                trailing: Container(
                  color: _themeData.primaryColorDark,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.primaryColorLight.toString()),
                title: const Text('primaryColorLight'),
                trailing: Container(
                  color: _themeData.primaryColorLight,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.scaffoldBackgroundColor.toString()),
                title: const Text('scaffoldBackgroundColor'),
                trailing: Container(
                  color: _themeData.scaffoldBackgroundColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.secondaryHeaderColor.toString()),
                title: const Text('secondaryHeaderColor'),
                trailing: Container(
                  color: _themeData.secondaryHeaderColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.shadowColor.toString()),
                title: const Text('shadowColor'),
                trailing: Container(
                  color: _themeData.shadowColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.splashColor.toString()),
                title: const Text('splashColor'),
                trailing: Container(
                  color: _themeData.splashColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(_themeData.unselectedWidgetColor.toString()),
                title: const Text('unselectedWidgetColor'),
                trailing: Container(
                  color: _themeData.unselectedWidgetColor,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }
}

class ColorSchemePage extends StatelessWidget {
  const ColorSchemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('colorScheme')),
      body: Card(
        margin: const EdgeInsets.all(16),
        elevation: 0,
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: <Widget>[
              ListTile(
                subtitle: Text(colorScheme.brightness.toString()),
                title: const Text('brightness'),
              ),
              ListTile(
                subtitle: Text(colorScheme.primary.toString()),
                title: const Text('primary'),
                trailing: Container(
                  color: colorScheme.primary,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onPrimary.toString()),
                title: const Text('onPrimary'),
                trailing: Container(
                  color: colorScheme.onPrimary,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.primaryContainer.toString()),
                title: const Text('primaryContainer'),
                trailing: Container(
                  color: colorScheme.primaryContainer,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onPrimaryContainer.toString()),
                title: const Text('onPrimaryContainer'),
                trailing: Container(
                  color: colorScheme.onPrimaryContainer,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.secondary.toString()),
                title: const Text('secondary'),
                trailing: Container(
                  color: colorScheme.secondary,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onSecondary.toString()),
                title: const Text('onSecondary'),
                trailing: Container(
                  color: colorScheme.onSecondary,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.secondaryContainer.toString()),
                title: const Text('secondaryContainer'),
                trailing: Container(
                  color: colorScheme.secondaryContainer,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onSecondaryContainer.toString()),
                title: const Text('onSecondaryContainer'),
                trailing: Container(
                  color: colorScheme.onSecondaryContainer,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.tertiary.toString()),
                title: const Text('tertiary'),
                trailing: Container(
                  color: colorScheme.tertiary,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onTertiary.toString()),
                title: const Text('onTertiary'),
                trailing: Container(
                  color: colorScheme.onTertiary,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.tertiaryContainer.toString()),
                title: const Text('tertiaryContainer'),
                trailing: Container(
                  color: colorScheme.tertiaryContainer,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onTertiaryContainer.toString()),
                title: const Text('onTertiaryContainer'),
                trailing: Container(
                  color: colorScheme.onTertiaryContainer,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.error.toString()),
                title: const Text('error'),
                trailing: Container(
                  color: colorScheme.error,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onError.toString()),
                title: const Text('onError'),
                trailing: Container(
                  color: colorScheme.onError,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.errorContainer.toString()),
                title: const Text('errorContainer'),
                trailing: Container(
                  color: colorScheme.errorContainer,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onErrorContainer.toString()),
                title: const Text('onErrorContainer'),
                trailing: Container(
                  color: colorScheme.onErrorContainer,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.outline.toString()),
                title: const Text('outline'),
                trailing: Container(
                  color: colorScheme.outline,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.surface.toString()),
                title: const Text('surface'),
                trailing: Container(
                  color: colorScheme.surface,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onSurface.toString()),
                title: const Text('onSurface'),
                trailing: Container(
                  color: colorScheme.onSurface,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.surfaceContainerHighest.toString()),
                title: const Text('surfaceContainerHighest'),
                trailing: Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onSurfaceVariant.toString()),
                title: const Text('onSurfaceVariant'),
                trailing: Container(
                  color: colorScheme.onSurfaceVariant,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.inverseSurface.toString()),
                title: const Text('inverseSurface'),
                trailing: Container(
                  color: colorScheme.inverseSurface,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.onInverseSurface.toString()),
                title: const Text('onInverseSurface'),
                trailing: Container(
                  color: colorScheme.onInverseSurface,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.inversePrimary.toString()),
                title: const Text('inversePrimary'),
                trailing: Container(
                  color: colorScheme.inversePrimary,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
              ListTile(
                subtitle: Text(colorScheme.shadow.toString()),
                title: const Text('shadow'),
                trailing: Container(
                  color: colorScheme.shadow,
                  child: const SizedBox(width: 24, height: 24),
                ),
              ),
            ],
          ).toList(),
        ),
      ),
    );
  }
}
