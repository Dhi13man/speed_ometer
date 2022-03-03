import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'package:speed_ometer/screens/dash_screen.dart';

Future<void> main() async {
  // Placeholder Splash Screen Material App.
  runApp(const NoPermissionApp(hasCheckedPermissions: false));
  WidgetsFlutterBinding.ensureInitialized();

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.unableToDetermine) {
    permission = await GeolocatorPlatform.instance.requestPermission();
  }
  switch (permission) {
    case LocationPermission.deniedForever:
      runApp(const NoPermissionApp(hasCheckedPermissions: true));
      break;

    case LocationPermission.always:
    case LocationPermission.whileInUse:
      runApp(const SpeedometerApp());
      break;

    case LocationPermission.denied:
    case LocationPermission.unableToDetermine:
      runApp(const NoPermissionApp(hasCheckedPermissions: false));
  }
}

/// MaterialApp that launches when proper permissions granted
class SpeedometerApp extends StatefulWidget {
  const SpeedometerApp({Key? key}) : super(key: key);

  @override
  _SpeedometerAppState createState() => _SpeedometerAppState();
}

class _SpeedometerAppState extends State<SpeedometerApp> {
  /// Shared preferences to be loaded for persistence.
  SharedPreferences? sharedPreferences;

  /// Unit selection
  final List<String> units = const <String>['m/s', 'km/h', 'miles/h'];
  String currentSelectedUnit = 'm/s';

  /// Function to save newly selected unit [newUnit] to persistent storage if possible, and update state.
  void unitSelectorFunciton(String newUnit) {
    if (sharedPreferences != null) {
      sharedPreferences!.setString('unit', newUnit);
    }
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
                .headline6!
                .copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          // Makes one Unit Selection button for each potential unit (m/s, km/h and miles/h programmed)
          actions: units.map<Widget>(
            (String unitType) {
              return _UnitSelectionButton(
                unitButtonName: unitType,
                currentSelectedUnit: currentSelectedUnit,
                unitSelector: unitSelectorFunciton,
              );
            },
          ).toList(),
        ),
        body: DashScreen(unit: currentSelectedUnit),
      ),
    );
  }
}

/// TextButton that enables user to select this particular unit
class _UnitSelectionButton extends StatelessWidget {
  const _UnitSelectionButton({
    Key? key,
    this.unitButtonName = 'm/s',
    required this.currentSelectedUnit,
    required this.unitSelector,
  }) : super(key: key);

  final String unitButtonName, currentSelectedUnit;
  final void Function(String) unitSelector;

  @override
  Widget build(BuildContext context) {
    final Color textColor = unitButtonName != currentSelectedUnit
        ? Colors.white
        : const Color(0xFFE9A246);
    return Container(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton(
        onPressed: () => unitSelector(unitButtonName),
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
        child: Text(unitButtonName, style: TextStyle(color: textColor)),
      ),
    );
  }
}

/// MaterialApp that launches when permissions still being searched, or denied forever.
class NoPermissionApp extends StatelessWidget {
  const NoPermissionApp({
    Key? key,
    required bool hasCheckedPermissions,
  })  : _hasCheckedPermissions = hasCheckedPermissions,
        super(key: key);

  final bool _hasCheckedPermissions;

  @override
  Widget build(BuildContext context) {
    Widget outWidget;
    // Splash screen mode
    if (!_hasCheckedPermissions) {
      outWidget = const Image(
        image: AssetImage('images/splash_image.png'),
        alignment: Alignment.center,
        fit: BoxFit.contain,
      );
    } else {
      outWidget = const Text(
        'Location permissions permanently denied!\n'
        'Please reinstall app and provide permissions!',
        style: TextStyle(
          color: Colors.red,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: outWidget),
      ),
    );
  }
}
