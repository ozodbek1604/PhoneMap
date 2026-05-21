import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Profil')),
      body: Consumer<AuthService>(builder: (context, auth, child) {
        if (!auth.isLoggedIn) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.person_outline, size: 80), const SizedBox(height: 16),
            const Text('Tizimga kiring'), const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Telefon orqali kirish')),
          ]));
        }
        return ListView(children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          Center(child: Text(auth.userName ?? 'Foydalanuvchi', style: Theme.of(context).textTheme.headlineSmall)),
          const Divider(height: 32),
          ListTile(leading: const Icon(Icons.list), title: const Text('Mening e\'lonlarim'), trailing: const Icon(Icons.arrow_forward_ios), onTap: () {}),
          ListTile(leading: const Icon(Icons.favorite), title: const Text('Sevimlilar'), trailing: const Icon(Icons.arrow_forward_ios), onTap: () {}),
          ListTile(leading: const Icon(Icons.settings), title: const Text('Sozlamalar'), trailing: const Icon(Icons.arrow_forward_ios), onTap: () {}),
          const Divider(height: 32),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Chiqish', style: TextStyle(color: Colors.red)), onTap: () => auth.signOut()),
        ]);
      }));
  }
}