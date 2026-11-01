import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:my_first_app/app/theme/app_theme.dart';
import 'package:my_first_app/features/feed/feed_screen.dart';
import 'package:my_first_app/features/groups/groups_screens.dart';
import 'package:my_first_app/features/map/map_screen.dart';
import 'package:my_first_app/features/profile/profile_screens.dart';

/// Нижняя навигация: Карта / Лента / Группы / Профиль.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _index = 0;

  final _screens = const [
    MapScreen(),
    FeedScreen(),
    GroupsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: AppColors.forestMid.withValues(alpha: 0.15),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map), label: 'map'.tr()),
          NavigationDestination(icon: const Icon(Icons.dynamic_feed_outlined), selectedIcon: const Icon(Icons.dynamic_feed), label: 'feed'.tr()),
          NavigationDestination(icon: const Icon(Icons.groups_outlined), selectedIcon: const Icon(Icons.groups), label: 'groups'.tr()),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: 'profile'.tr()),
        ],
      ),
    );
  }
}
