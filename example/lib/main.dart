import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klippa_identity_validation_sdk/klippa_identity_validation_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _idValidationResult = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  void _startSession() async {
    String sessionResultText = 'Unknown';
    var identityBuilder = IdentityBuilder();
    identityBuilder.language = KIVLanguage.Dutch;
    try {
      var sessionResult = await KlippaIdentityValidationSdk.startSession(identityBuilder, 'test');
      sessionResultText = 'Finished';
    } on PlatformException catch (e) {
      sessionResultText = 'Failed to start session: ' + e.toString();
    }

    setState(() {
      _idValidationResult = sessionResultText;
    });

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('ID validation result: $_idValidationResult\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _startSession,
          tooltip: 'Start session',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
