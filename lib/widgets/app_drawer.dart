import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guidego/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:guidego/providers/traveler_provider.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  const AppDrawer({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final traveler = context.watch<TravelerProvider>().traveler;
    final auth = AuthService();

    return Drawer(
      child: SafeArea(
        child: Container(
          color: const Color(0xFF1C1C1C),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.teal,
                  backgroundImage: traveler?.profileImage != null
                      ? NetworkImage(traveler!.profileImage!)
                      : null,
                  child: traveler?.profileImage == null
                      ? const Icon(Icons.person, color: Colors.white, size: 32)
                      : null,
                ),
                accountName: Text(
                  traveler?.fullName ?? userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(traveler?.email ?? ""),
              ),
              _item(context, Icons.home, "Home", "/"),
              _item(context, Icons.person, "Profile", "/profile"),
              _item(context, Icons.book_online, "My Bookings", "/bookings"),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text("Logout", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await auth.signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _item(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
