import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/src/design_system/constants/responsive_constants.dart';
import 'package:template/src/design_system/responsive_values.dart';
import 'package:template/src/design_system/responsive_wrapper.dart';
import 'package:template/src/services/auth_service.dart';
import 'package:template/src/views/chat_list_view.dart';
import 'package:template/src/views/profile_view.dart';
import 'package:template/src/views/updates_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, this.initialTab = 0});
  
  final int initialTab;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late int _selectedIndex;
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }
  
  final List<Widget> _pages = [
    const ChatListView(),
    const UpdatesView(),
    const ProfileView(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/home/chats');
        break;
      case 1:
        context.go('/home/updates');
        break;
      case 2:
        context.go('/home/profile');
        break;
    }
  }

  void _signOut() async {
    await AuthService().signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth > ResponsiveConstants.phoneSize && 
                     screenWidth <= ResponsiveConstants.tabletSize;
    final isDesktop = screenWidth > ResponsiveConstants.tabletSize;
    
    final appBarTitle = responsiveValue<String>(
      context,
      mobile: () => 'Social Chat',
      tablet: () => 'Social Chat App',
      desktop: () => 'Social Chat Platform',
      orElse: () => 'Social Chat',
    );
    
    final appBarTitleStyle = responsiveValue<TextStyle?>(
      context,
      mobile: () => Theme.of(context).textTheme.titleLarge,
      tablet: () => Theme.of(context).textTheme.headlineSmall,
      desktop: () => Theme.of(context).textTheme.headlineMedium,
      orElse: () => Theme.of(context).textTheme.titleLarge,
    );
    
    // For landscape tablet/desktop layout
    if (!isPortrait && (isTablet || isDesktop)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.selected,
              useIndicator: true,
              indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              backgroundColor: Theme.of(context).colorScheme.surface,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.chat_outlined),
                  selectedIcon: Icon(Icons.chat),
                  label: Text('Chats'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.update_outlined),
                  selectedIcon: Icon(Icons.update),
                  label: Text('Updates'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      onPressed: _signOut,
                      tooltip: 'Sign out',
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(appBarTitle, style: appBarTitleStyle),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.person_add_rounded),
                      onPressed: () {
                        context.push('/add-friend');
                      },
                      tooltip: 'Add friend',
                    ),
                    if (!isTablet) // Only show logout in top bar on desktop
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        onPressed: _signOut,
                        tooltip: 'Sign out',
                      ),
                  ],
                ),
                body: ResponsiveWrapper(
                  child: _pages[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Portrait or phone layout
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: appBarTitleStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () {
              context.push('/add-friend');
            },
            tooltip: 'Add friend',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _signOut,
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update_outlined),
            activeIcon: Icon(Icons.update),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class NewUpdateBottomSheet extends StatefulWidget {
  const NewUpdateBottomSheet({super.key});

  @override
  State<NewUpdateBottomSheet> createState() => _NewUpdateBottomSheetState();
}

class _NewUpdateBottomSheetState extends State<NewUpdateBottomSheet> {
  final TextEditingController _updateController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  void _postUpdate() async {
    final content = _updateController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().createUpdate(content);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update posted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = responsiveValue<EdgeInsets>(
      context,
      mobile: () => EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      tablet: () => EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 32,
        right: 32,
        top: 32,
      ),
      desktop: () => EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 48,
        right: 48,
        top: 32,
      ),
      orElse: () => EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
    );
    
    final buttonHeight = responsiveValue<double>(
      context,
      mobile: () => ResponsiveConstants.buttonHeightPhone,
      tablet: () => ResponsiveConstants.buttonHeightTablet,
      desktop: () => ResponsiveConstants.buttonHeightDesktop,
      orElse: () => ResponsiveConstants.buttonHeightPhone,
    );
    
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'New Update',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: responsiveValue(
            context,
            mobile: () => ResponsiveConstants.spacingMediumPhone,
            tablet: () => ResponsiveConstants.spacingMediumTablet,
            desktop: () => ResponsiveConstants.spacingMediumDesktop,
            orElse: () => 24.0,
          )),
          TextField(
            controller: _updateController,
            maxLines: responsiveValue(context, mobile: () => 5, tablet: () => 7, desktop: () => 8, orElse: () => 5),
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: responsiveValue(
            context,
            mobile: () => ResponsiveConstants.spacingMediumPhone,
            tablet: () => ResponsiveConstants.spacingMediumTablet,
            desktop: () => ResponsiveConstants.spacingMediumDesktop,
            orElse: () => 24.0,
          )),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _postUpdate,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post Update'),
            ),
          ),
          SizedBox(height: responsiveValue(
            context,
            mobile: () => ResponsiveConstants.spacingMediumPhone,
            tablet: () => ResponsiveConstants.spacingMediumTablet,
            desktop: () => ResponsiveConstants.spacingMediumDesktop,
            orElse: () => 24.0,
          )),
        ],
      ),
    );
  }
}