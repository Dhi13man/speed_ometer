import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'package:speed_ometer/main_screen.dart';

void main() {
  // Placeholder Splash Screen Material App.
  runApp(NoPermissionApp(hasCheckedPermissions: false));
  WidgetsFlutterBinding.ensureInitialized();

  Geolocator.checkPermission().then(
    (LocationPermission permission) {
      // App must be reinstalled to be used if permission denied forever.
      if (permission == LocationPermission.deniedForever)
        runApp(NoPermissionApp(hasCheckedPermissions: true));
      else // Run app and ask for permissions.
        runApp(SpeedometerApp());
    },
  );
}

/// MaterialApp that launches when proper permissions granted
class SpeedometerApp extends StatefulWidget {
  @override
  _SpeedometerAppState createState() => _SpeedometerAppState();
}

class _SpeedometerAppState extends State<SpeedometerApp> {
  /// Shared preferences to be loaded for persistence.
  SharedPreferences sharedPreferences;

  /// Unit selection
  final List<String> units = const <String>['m/s', 'km/h', 'miles/h'];
  String currentSelectedUnit = 'm/s';

  /// Function to save newly selected unit [newUnit] to persistent storage if possible, and update state.
  void unitSelectorFunciton(String newUnit) {
    if (sharedPreferences != null) sharedPreferences.setString('unit', newUnit);
    setState(() => currentSelectedUnit = newUnit);
  }

  @override
  void initState() {
    super.initState();

    // Load Selected unit through Shared Preferences
    SharedPreferences.getInstance().then(
      (SharedPreferences prefs) {
        sharedPreferences = prefs;
        setState(
          () => currentSelectedUnit = (prefs.getString('unit') ?? 'm/s'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Voice Speedometer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Speedometer',
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          // Makes one Unit Selection button for each potential unit (m/s, km/h and miles/h programmed)
          actions: units.map<Widget>(
            (String unitType) {
              return UnitSelectionButton(
                unitButtonName: unitType,
                currentSelectedUnit: currentSelectedUnit,
                unitSelector: unitSelectorFunciton,
              );
            },
          ).toList(),
        ),
        body: MainScreen(unit: currentSelectedUnit),
      ),
    );
  }
}

/// TextButton that enables user to select this particular unit
class UnitSelectionButton extends StatelessWidget {
  const UnitSelectionButton({
    Key key,
    this.unitButtonName = 'm/s',
    @required this.currentSelectedUnit,
    @required this.unitSelector,
  }) : super(key: key);

  final String unitButtonName, currentSelectedUnit;
  final void Function(String) unitSelector;

  @override
  Widget build(BuildContext context) {
    final Color textColor = unitButtonName != currentSelectedUnit
        ? Colors.white
        : Color(0xFFE9A246);
    return Container(
      padding: EdgeInsets.only(right: 10),
      child: FlatButton(
        onPressed: () => unitSelector(unitButtonName),
        minWidth: 0,
        padding: EdgeInsets.zero,
        child: Text(unitButtonName, style: TextStyle(color: textColor)),
      ),
    );
  }
}

/// MaterialApp that launches when permissions still being searched, or denied forever.
class NoPermissionApp extends StatelessWidget {
  const NoPermissionApp({
    Key key,
    @required bool hasCheckedPermissions,
  })  : _hasCheckedPermissions = hasCheckedPermissions ?? false,
        super(key: key);

  final bool _hasCheckedPermissions;

  @override
  Widget build(BuildContext context) {
    Widget outWidget;
    // Splash screen mode
    if (!_hasCheckedPermissions)
      outWidget = Image(
        image: AssetImage('images/splash_image.png'),
        alignment: Alignment.center,
        fit: BoxFit.contain,
      );
    // Error Message mode
    else
      outWidget = Text(
        'Location permissions permanently denied!\n' +
            'Please reinstall app and provide permissions!',
        style: TextStyle(
          color: Colors.red,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      );
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: outWidget),
      ),
    );
  }
}
