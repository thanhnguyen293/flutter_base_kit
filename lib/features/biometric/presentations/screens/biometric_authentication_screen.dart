import 'package:flutter/services.dart';

import '../../../../project_imports.dart';

import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricAuthenticationScreen extends StatefulWidget {
  const BiometricAuthenticationScreen({super.key});

  @override
  State<BiometricAuthenticationScreen> createState() =>
      _BiometricAuthenticationScreenState();
}

class _BiometricAuthenticationScreenState
    extends State<BiometricAuthenticationScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  bool _canCheckBiometrics = false;
  bool _isDeviceSupported = false;
  List<BiometricType> _availableBiometrics = [];
  String _authStatus = 'Not authenticated';

  /// Check whether device supports biometrics
  Future<void> _checkSupport() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      final biometrics = await auth.getAvailableBiometrics();

      setState(() {
        _canCheckBiometrics = canCheck;
        _isDeviceSupported = isSupported;
        _availableBiometrics = biometrics;
      });
    } catch (e) {
      setState(() {
        _authStatus = "Support check failed: $e";
      });
    }
  }

  /// Authenticate user with custom options
  Future<void> _authenticate({
    bool biometricOnly = false,
    bool sticky = false,
    bool useErrorDialogs = true,
  }) async {
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access sensitive info',
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: sticky,
          useErrorDialogs: useErrorDialogs,
        ),
        authMessages: const <AuthMessages>[
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please enable biometrics in settings',
          ),
          AndroidAuthMessages(
            cancelButton: 'Cancel',
            signInTitle: 'Sign in with biometrics',
          ),
        ],
      );

      setState(() {
        _authStatus =
            didAuthenticate ? 'Authenticated!' : 'Failed to authenticate';
      });
    } on PlatformException catch (e) {
      // Handle specific error codes
      String errorMsg;
      switch (e.code) {
        case auth_error.notAvailable:
          errorMsg = 'Biometric hardware not available';
          break;
        case auth_error.notEnrolled:
          errorMsg = 'No biometrics enrolled';
          break;
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          errorMsg = 'Biometrics locked. Use passcode';
          break;
        default:
          errorMsg = 'Unknown error: ${e.code}';
      }
      setState(() {
        _authStatus = errorMsg;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Auth - Full Demo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Device Support Info",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(" - canCheckBiometrics: $_canCheckBiometrics"),
            Text(" - isDeviceSupported: $_isDeviceSupported"),

            const Text(
              "Available Biometrics",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._availableBiometrics.map((type) => Text(" - ${type.name}")),
            const Text(
              "Authentication Result",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(' - $_authStatus', style: const TextStyle(fontSize: 16)),
            const Divider(),
            const Text(
              "Test Authentication Scenarios",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            AppButton(
              onPressed: () => _authenticate(),
              child: const Text("Basic authenticate"),
            ),
            AppButton(
              onPressed: () => _authenticate(biometricOnly: true),
              child: const Text("Biometric only"),
            ),
            AppButton(
              onPressed: () => _authenticate(sticky: true),
              child: const Text("StickyAuth"),
            ),
            AppButton(
              onPressed: () => _authenticate(useErrorDialogs: false),
              child: const Text("Suppress dialogs"),
            ),
          ],
        ),
      ),
    );
  }
}
