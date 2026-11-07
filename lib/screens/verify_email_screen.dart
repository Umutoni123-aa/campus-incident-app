import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  void _showError(BuildContext context, String? error) {
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your email'),
        actions: [
          TextButton(
            onPressed: auth.isLoading
                ? null
                : () => context.read<AuthProvider>().logout(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'We sent a verification link to ${auth.currentUser?.email ?? 'your email'}.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        await context
                            .read<AuthProvider>()
                            .resendVerificationEmail();
                        if (context.mounted) {
                          _showError(
                            context,
                            context.read<AuthProvider>().errorMessage,
                          );
                          if (context.read<AuthProvider>().errorMessage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Verification email sent.')),
                            );
                          }
                        }
                      },
                child: const Text('Resend email'),
              ),
              FilledButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        await context
                            .read<AuthProvider>()
                            .refreshVerificationStatus();
                        if (context.mounted) {
                          _showError(
                            context,
                            context.read<AuthProvider>().errorMessage,
                          );
                        }
                      },
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('I have verified'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
