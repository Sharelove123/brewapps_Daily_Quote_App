import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/collections_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../models/collection.dart';
import 'auth/login_screen.dart';
import 'collection_detail_screen.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final collectionsState = ref.watch(collectionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondaryLight;

    // Show login prompt if not authenticated
    if (!authState.isAuthenticated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open_rounded, size: 64, color: iconColor),
              const SizedBox(height: 24),
              Text(
                'Sign in to create collections',
                style: AppTheme.headingStyleThemed(
                  isDark,
                ).copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Organize your favorite quotes into custom collections',
                style: AppTheme.subheadingStyleThemed(isDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Text(AppStrings.signIn),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                AppStrings.myCollections,
                style: AppTheme.headingStyleThemed(
                  isDark,
                ).copyWith(fontSize: 24),
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: collectionsState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryPurple,
                      ),
                    )
                  : collectionsState.collections.isEmpty
                  ? _buildEmptyState(isDark)
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(collectionsProvider.notifier).refresh(),
                      color: AppTheme.primaryPurple,
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                        itemCount: collectionsState.collections.length,
                        itemBuilder: (context, index) {
                          final collection =
                              collectionsState.collections[index];
                          return _CollectionCard(
                            collection: collection,
                            isDark: isDark,
                            onTap: () {
                              ref
                                  .read(collectionsProvider.notifier)
                                  .selectCollection(collection);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CollectionDetailScreen(
                                    collection: collection,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),

        // FAB
        Positioned(
          right: 20,
          bottom: 100,
          child: FloatingActionButton(
            backgroundColor: AppTheme.primaryPurple,
            onPressed: () => _showCreateCollectionDialog(context, ref),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final iconColor = isDark
        ? Colors.white30
        : AppTheme.textSecondaryLight.withValues(alpha: 0.3);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: iconColor),
          const SizedBox(height: 24),
          Text(
            AppStrings.noCollectionsYet,
            style: AppTheme.headingStyleThemed(isDark).copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              AppStrings.noCollectionsDesc,
              style: AppTheme.subheadingStyleThemed(isDark),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedColor = '#A855F7';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = [
      '#A855F7', // Purple
      '#14B8A6', // Teal
      '#F59E0B', // Amber
      '#EF4444', // Red
      '#3B82F6', // Blue
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark
              ? AppTheme.darkSurface
              : AppTheme.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppStrings.createCollection,
            style: AppTheme.headingStyleThemed(isDark).copyWith(fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: AppTheme.bodyStyleThemed(isDark),
                decoration: InputDecoration(
                  hintText: AppStrings.collectionName,
                  hintStyle: AppTheme.subheadingStyleThemed(isDark),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.colorLabel,
                style: AppTheme.labelStyleThemed(isDark),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: colors.map((color) {
                  final colorValue = Color(
                    int.parse(color.replaceFirst('#', '0xFF')),
                  );
                  final isSelected = color == selectedColor;
                  final borderColor = isDark ? Colors.white : Colors.black;

                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorValue,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: borderColor, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, color: borderColor, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await ref
                      .read(collectionsProvider.notifier)
                      .createCollection(
                        name: nameController.text.trim(),
                        color: selectedColor,
                      );
                  Navigator.pop(context);
                }
              },
              child: Text(AppStrings.createCollection),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final QuoteCollection collection;
  final VoidCallback onTap;
  final bool isDark;

  const _CollectionCard({
    required this.collection,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorValue = Color(
      int.parse(collection.color.replaceFirst('#', '0xFF')),
    );
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: AppTheme.glassDecoration(isDark: isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color strip
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorValue,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          collection.name,
                          style: AppTheme.bodyStyleThemed(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${collection.quoteCount} ${AppStrings.quotes}',
                          style: AppTheme.labelStyleThemed(isDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
