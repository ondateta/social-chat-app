import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:template/src/design_system/constants/responsive_constants.dart';
import 'package:template/src/design_system/responsive_values.dart';
import 'package:template/src/services/auth_service.dart';

class ProfileView extends StatefulWidget {
  final String? userId;
  const ProfileView({super.key, this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userUpdates = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userData = await AuthService().getUserData();
      final userUpdates = await AuthService().getUserUpdates();
      
      setState(() {
        _userData = userData;
        _userUpdates = userUpdates;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // In a real app, upload the image to a server
      // For this demo, we'll just show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated')),
        );
      }
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
    final theme = Theme.of(context);
    final spacing = responsiveValue<double>(
      context,
      mobile: () => 16.0,
      tablet: () => 24.0,
      desktop: () => 32.0,
      orElse: () => 16.0,
    );
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_userData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading profile',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final username = _userData!['username'] as String? ?? 'User';
    final email = _userData!['email'] as String? ?? 'email@example.com';
    
    // Get screen width to check if we need responsive adjustments
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < ResponsiveConstants.tabletSize;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile header section
                  GestureDetector(
                    onTap: _selectImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            username.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.surface,
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(spacing),
                  Text(
                    username,
                    style: theme.textTheme.headlineSmall,
                  ),
                  Gap(spacing / 2),
                  Text(
                    email,
                    style: theme.textTheme.bodyLarge,
                  ),
                  Gap(spacing),
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatColumn('Posts', _userUpdates.length.toString()),
                      Container(
                        height: 30,
                        width: 1,
                        color: theme.dividerColor,
                        margin: EdgeInsets.symmetric(horizontal: spacing),
                      ),
                      _buildStatColumn('Friends', '0'),
                    ],
                  ),
                  
                  Gap(spacing),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SizedBox(
                          width: isMobile ? double.infinity : 150,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Navigate to edit profile
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                          ),
                        ),
                      ),
                      SizedBox(width: spacing),
                      Flexible(
                        child: SizedBox(
                          width: isMobile ? double.infinity : 150,
                          child: OutlinedButton.icon(
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  Gap(spacing),
                  
                  // Post an update section
                  Container(
                    padding: EdgeInsets.all(spacing),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            username.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                            child: Text(
                              'What\'s on your mind?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => UpdateBottomSheet(
                                onUpdatePosted: () {
                                  _loadUserData();
                                },
                              ),
                            );
                          },
                          child: const Text('Post Update'),
                        ),
                      ],
                    ),
                  ),
                  
                  Gap(spacing),
                  
                  // User updates section
                  if (_userUpdates.isEmpty)
                    Column(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        Gap(spacing),
                        Text(
                          'No posts yet',
                          style: theme.textTheme.titleLarge,
                        ),
                        Gap(spacing / 2),
                        Text(
                          'Your posts will appear here',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _userUpdates.length,
                      itemBuilder: (context, index) {
                        final update = _userUpdates[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: spacing),
                          child: Padding(
                            padding: EdgeInsets.all(spacing),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: theme.colorScheme.primary,
                                      child: Text(
                                        username.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: spacing / 2),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            username,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          Text(
                                            '${DateTime.fromMillisecondsSinceEpoch(update['timestamp']).toString().substring(0, 16)}',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () {
                                        // Show options
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: spacing),
                                Text(
                                  update['content'] ?? '',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                SizedBox(height: spacing),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.thumb_up_outlined),
                                      onPressed: () {
                                        // Like functionality
                                      },
                                      iconSize: 20,
                                    ),
                                    Text(
                                      '${update['likes'] ?? 0}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    SizedBox(width: spacing),
                                    IconButton(
                                      icon: const Icon(Icons.comment_outlined),
                                      onPressed: () {
                                        // Comment functionality
                                      },
                                      iconSize: 20,
                                    ),
                                    Text(
                                      '${update['comments'] ?? 0}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatColumn(String title, String count) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class UpdateBottomSheet extends StatefulWidget {
  const UpdateBottomSheet({super.key, required this.onUpdatePosted});
  
  final VoidCallback onUpdatePosted;

  @override
  State<UpdateBottomSheet> createState() => _UpdateBottomSheetState();
}

class _UpdateBottomSheetState extends State<UpdateBottomSheet> {
  final TextEditingController _updateController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  void _postUpdate() async {
    if (_updateController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().createUpdate(_updateController.text.trim());
      
      if (mounted) {
        Navigator.pop(context);
        widget.onUpdatePosted();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update posted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting update: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        left: 16,
        right: 16,
        top: 16,
      ),
      tablet: () => EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      desktop: () => EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 32,
        right: 32,
        top: 32,
      ),
      orElse: () => EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Update',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _updateController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _postUpdate,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Post Update'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}