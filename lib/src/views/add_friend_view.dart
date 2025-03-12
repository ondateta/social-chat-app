import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:template/src/design_system/responsive_wrapper.dart';

class AddFriendView extends StatefulWidget {
  const AddFriendView({super.key});

  @override
  State<AddFriendView> createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<AddFriendView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _searchFriends() async {
    if (_searchController.text.trim().isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate some dummy results
    final results = List.generate(
      5,
      (index) => {
        'id': '${index + 1}',
        'username': 'User ${index + 1}',
        'email': 'user${index + 1}@example.com',
      },
    );
    
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
      ),
      body: ResponsiveWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Find Friends',
                style: theme.textTheme.headlineMedium,
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by username or email',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSubmitted: (_) => _searchFriends(),
                    ),
                  ),
                  const Gap(8),
                  ElevatedButton(
                    onPressed: _searchFriends,
                    child: const Text('Search'),
                  ),
                ],
              ),
              const Gap(24),
              if (_isSearching)
                const CircularProgressIndicator()
              else if (_searchResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(user['username'].substring(0, 1)),
                        ),
                        title: Text(user['username']),
                        subtitle: Text(user['email']),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(100, 36),
                          ),
                          onPressed: () {
                            // Add friend functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Friend request sent to ${user['username']}'),
                              ),
                            );
                          },
                          child: const Text('Add'),
                        ),
                        onTap: () {
                          context.push('/profile/${user['id']}');
                        },
                      );
                    },
                  ),
                )
              else if (_searchController.text.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text('No users found matching "${_searchController.text}"'),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const Gap(16),
                      Text(
                        'Search for friends by their username or email',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}