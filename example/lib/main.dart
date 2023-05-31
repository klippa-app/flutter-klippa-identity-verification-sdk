import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klippa_identity_verification_sdk/klippa_identity_verification_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _idVerificationResult = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  void _startSession() async {
    String sessionResultText = 'Unknown';
    var identityBuilder = IdentityBuilder();
    identityBuilder.isDebug = true;
    try {
      // @todo: get a session token from the API through your backend here.
      var sessionResult = await KlippaIdentityVerificationSdk.startSession(
          identityBuilder,
          'VUB6md6UmHATXheRtdokbsZlRxs7W4QwLkCSE2CBZueDrEB326o7iIdyJ8Z74sax');
      sessionResultText = 'Finished';
    } on PlatformException catch (e) {
      sessionResultText = 'Failed to start session: ' + e.toString();
    }

    setState(() {
      _idVerificationResult = sessionResultText;
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
          child: Text('ID verification result: $_idVerificationResult\n'),
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
