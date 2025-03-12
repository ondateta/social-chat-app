import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:template/src/design_system/constants/responsive_constants.dart';
import 'package:template/src/design_system/responsive_values.dart';
import 'package:template/src/services/auth_service.dart';

class UpdatesView extends StatefulWidget {
  const UpdatesView({super.key});

  @override
  State<UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends State<UpdatesView> {
  List<Map<String, dynamic>> _updates = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updates = await AuthService().getAllUpdates();
      final userData = await AuthService().getUserData();
      
      setState(() {
        _updates = updates;
        _currentUser = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _deleteUpdate(String updateId) async {
    try {
      await AuthService().deleteUpdate(updateId);
      setState(() {
        _updates.removeWhere((update) => update['id'] == updateId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting update: $e')),
        );
      }
    }
  }
  
  void _editUpdate(Map<String, dynamic> update) {
    final TextEditingController controller = TextEditingController(text: update['content']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Update'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  await AuthService().updateUpdate(update['id'], controller.text.trim());
                  _loadData(); // Reload all updates
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Update edited successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error editing update: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = responsiveValue<double>(
      context,
      mobile: () => ResponsiveConstants.spacingMediumPhone,
      tablet: () => ResponsiveConstants.spacingMediumTablet,
      desktop: () => ResponsiveConstants.spacingMediumDesktop,
      orElse: () => ResponsiveConstants.spacingMediumPhone,
    );
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_updates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            Gap(spacing),
            Text(
              'No updates yet',
              style: theme.textTheme.titleLarge,
            ),
            Gap(spacing / 2),
            Text(
              'Updates from you and your friends will appear here',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: EdgeInsets.all(spacing),
          itemCount: _updates.length,
          itemBuilder: (context, index) {
            final update = _updates[index];
            final username = update['username'] as String?;
            final isCurrentUserUpdate = update['userId'] == _currentUser?['id'];
            final timestamp = DateTime.fromMillisecondsSinceEpoch(update['timestamp']);
            final timeAgo = _getTimeAgo(timestamp);
            
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
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            username?.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(color: theme.colorScheme.onPrimary),
                          ),
                        ),
                        SizedBox(width: spacing / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username ?? 'User',
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                timeAgo,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (isCurrentUserUpdate)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editUpdate(update);
                              } else if (value == 'delete') {
                                _deleteUpdate(update['id']);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: spacing),
                    Text(
                      update['content'] ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (update['edited'] == true)
                      Padding(
                        padding: EdgeInsets.only(top: spacing / 4),
                        child: Text(
                          '(edited)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    SizedBox(height: spacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            update['liked'] == true
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            color: update['liked'] == true
                                ? theme.colorScheme.primary
                                : null,
                          ),
                          onPressed: () {
                            // Like functionality
                          },
                          iconSize: 20,
                        ),
                        Text(
                          update['likes']?.toString() ?? '0',
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
                          update['comments']?.toString() ?? '0',
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => UpdateBottomSheet(
              onUpdatePosted: _loadData,
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
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