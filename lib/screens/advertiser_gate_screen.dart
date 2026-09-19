import 'package:flutter/material.dart';

import '../models/advertiser_account.dart';
import '../services/advertiser_account_service.dart';
import 'advertiser_auth_screen.dart';

class AdvertiserGateScreen extends StatefulWidget {
  final Widget destination;

  const AdvertiserGateScreen({
    super.key,
    required this.destination,
  });

  @override
  State<AdvertiserGateScreen> createState() => _AdvertiserGateScreenState();
}

class _AdvertiserGateScreenState extends State<AdvertiserGateScreen> {
  late Future<AdvertiserAccount?> _accountFuture;

  @override
  void initState() {
    super.initState();
    _accountFuture =
        AdvertiserAccountService.instance.getCurrentAccount();
  }

  void _load() {
    if (!mounted) return;
    setState(() {
      _accountFuture =
          AdvertiserAccountService.instance.getCurrentAccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdvertiserAccount?>(
      future: _accountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final account = snapshot.data;
        if (account == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('حساب المعلن مطلوب'),
              centerTitle: true,
            ),
            body: AdvertiserAuthScreen(
              embedded: true,
              onAuthenticated: _load,
            ),
          );
        }

        if (!account.isActive) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('لوحة المعلن'),
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.block_rounded,
                      size: 68,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'حساب المعلن موقوف',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'تواصل مع مدير النظام لمعرفة السبب وإعادة تفعيل الحساب.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/advertiserAccount',
                      ),
                      icon: const Icon(Icons.support_agent_rounded),
                      label: const Text('التواصل مع مدير النظام'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await AdvertiserAccountService.instance.logout();
                        _load();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return widget.destination;
      },
    );
  }
}
