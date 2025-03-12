import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:template/src/design_system/constants/responsive_constants.dart';
import 'package:template/src/design_system/responsive_values.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    
    final listPadding = responsiveValue<EdgeInsets>(
      context,
      mobile: () => const EdgeInsets.symmetric(vertical: 12),
      tablet: () => const EdgeInsets.symmetric(vertical: 16),
      desktop: () => const EdgeInsets.symmetric(vertical: 20),
      orElse: () => const EdgeInsets.symmetric(vertical: 12),
    );
    
    final avatarSize = responsiveValue<double>(
      context,
      mobile: () => 48.0,
      tablet: () => 52.0,
      desktop: () => 56.0,
      orElse: () => 48.0,
    );

    final messageFontSize = responsiveValue<double>(
      context,
      mobile: () => ResponsiveConstants.fontSizeMediumPhone,
      tablet: () => ResponsiveConstants.fontSizeMediumTablet,
      desktop: () => ResponsiveConstants.fontSizeMediumDesktop,
      orElse: () => ResponsiveConstants.fontSizeMediumPhone,
    );
    
    return Scaffold(
      body: Padding(
        padding: listPadding,
        child: isLandscape && MediaQuery.of(context).size.width > ResponsiveConstants.tabletSize
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 10,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) => _buildChatItem(
                  context,
                  index,
                  theme,
                  avatarSize,
                  messageFontSize,
                ),
              )
            : ListView.separated(
                itemCount: 10,
                padding: const EdgeInsets.all(12),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) => _buildChatItem(
                  context,
                  index,
                  theme,
                  avatarSize,
                  messageFontSize,
                ),
              ),
      ),
    );
  }
  
  Widget _buildChatItem(BuildContext context, int index, ThemeData theme, double avatarSize, double messageFontSize) {
    final bool hasUnread = index < 3;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/chat/${index + 1}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                ),
                child: Center(
                  child: Text(
                    'U${index + 1}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: avatarSize * 0.4,
                    ),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'User ${index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${index + 1}m ago',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasUnread
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      'This is the last message from user ${index + 1}...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                        color: hasUnread
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasUnread)
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}