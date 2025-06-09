import '../../../../project_imports.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            AppButton(
              child: Text('Biometric Authentication'),
              onPressed: () {
                context.push(BiometricAuthenticationScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
