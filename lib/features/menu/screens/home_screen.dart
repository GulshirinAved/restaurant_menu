import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_bloc.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_state.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_event.dart';
import 'package:restaurant_menu_app/features/cart/screens/order_screen.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_event.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_state.dart';
import 'package:restaurant_menu_app/features/menu/screens/add_product_screen.dart';
import 'package:restaurant_menu_app/features/menu/widgets/menu_item_card.dart';
import 'package:restaurant_menu_app/features/cart/models/cart_item.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/language/bloc/language_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(LoadMenu());
  }

  void _navigateToAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is MenuLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MenuError) {
            // Check if it's the specific "Failed to load menu" error with numeric format
            // If so, we might want to show a friendlier message or the same empty state if it means no data
            // But for now, let's just make the error look better
            return _buildStatusView(
              context: context,
              icon: Icons.error_outline,
              title: AppLocalizations.of(context)!.translate('error_title'),
              message: state.message,
            );
          } else if (state is MenuLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _buildTabletLayout(context, state);
                } else {
                  return _buildMobileLayout(context, state);
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton:
          MediaQuery.of(context).size.width <= 900
              ? FloatingActionButton(
                onPressed: () => _navigateToAddProduct(context),
                child: const Icon(Icons.add),
              )
              : null, // Hide FAB on tablet, use header button or dedicated area
    );
  }

  // --- Layouts ---

  Widget _buildTabletLayout(BuildContext context, MenuLoaded state) {
    final categories = state.categorizedItems.keys.toList();
    _selectedCategory ??= categories.isNotEmpty ? categories.first : null;
    final items = state.categorizedItems[_selectedCategory] ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Pane: Navigation Rail / Categories
        Container(
          width: 280,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
                child: Text(
                  AppLocalizations.of(context)!.translate('menu'),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == _selectedCategory;
                    return InkWell(
                      onTap: () => setState(() => _selectedCategory = category),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.15)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.local_dining
                                  : Icons.local_dining_outlined,
                              size: 20,
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).unselectedWidgetColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              category,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color:
                                    isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Center Pane: Menu Grid
        Expanded(
          flex: 5,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory ??
                              AppLocalizations.of(
                                context,
                              )!.translate('everyone_favs'),
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (MediaQuery.of(context).size.width <=
                            1100) // Show cart icon if right pane might be tight or hidden (though we force it here)
                          const SizedBox(),
                      ],
                    ),
                  ),
                ),
                if (items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildStatusView(
                      context: context,
                      icon: Icons.restaurant_menu,
                      title: AppLocalizations.of(
                        context,
                      )!.translate('no_items'),
                      message: AppLocalizations.of(
                        context,
                      )!.translate('no_items_msg'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 0,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 350,
                            mainAxisSpacing: 32,
                            crossAxisSpacing: 32,
                            childAspectRatio: 0.7,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => MenuItemCard(item: items[index]),
                        childCount: items.length,
                      ),
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          ),
        ),

        // Right Pane: Cart Summary
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              left: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
          child: _buildPersistentCart(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, MenuLoaded state) {
    final categories = state.categorizedItems.keys.toList();
    _selectedCategory ??= categories.isNotEmpty ? categories.first : null;
    final items = state.categorizedItems[_selectedCategory] ?? [];

    return CustomScrollView(
      slivers: [
        // iOS Style Large Title AppBar
        SliverAppBar.large(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          pinned: true,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: Text(
              AppLocalizations.of(context)!.translate('menu'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            background: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          actions: [
            _buildCartBadge(context),
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language),
              onSelected: (Locale locale) {
                context.read<LanguageBloc>().add(ChangeLanguage(locale));
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<Locale>>[
                    const PopupMenuItem<Locale>(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    const PopupMenuItem<Locale>(
                      value: Locale('tk'),
                      child: Text('Türkmen'),
                    ),
                    const PopupMenuItem<Locale>(
                      value: Locale('ru'),
                      child: Text('Русский'),
                    ),
                  ],
            ),
          ],
        ),

        // Category Pills
        SliverToBoxAdapter(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected:
                      (val) => setState(() => _selectedCategory = category),
                  showCheckmark: false,
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'DM Sans',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide.none,
                );
              },
            ),
          ),
        ),

        // Menu Grid
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildStatusView(
              context: context,
              icon: Icons.restaurant_menu,
              title: AppLocalizations.of(context)!.translate('no_items'),
              message: AppLocalizations.of(context)!.translate('no_items_msg'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => MenuItemCard(item: items[index]),
                childCount: items.length,
              ),
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  // --- Components ---

  Widget _buildStatusView({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersistentCart(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return _buildStatusView(
            context: context,
            icon: Icons.shopping_bag_outlined,
            title: AppLocalizations.of(context)!.translate('cart_empty'),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                AppLocalizations.of(context)!.translate('current_order'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _buildCartItemTile(context, item);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.translate('total'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${state.totalPrice} TMT',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // In tablet mode, we might just show a success dialog or clear cart
                        context.read<CartBloc>().add(ClearCart());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.translate('order_sent'),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.translate('submit_order'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartItemTile(BuildContext context, CartItem item) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${item.quantity}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.menuItem.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${item.menuItem.price * item.quantity} TMT',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed:
              () => context.read<CartBloc>().add(RemoveCartItem(item.menuItem)),
          icon: Icon(
            Icons.close,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildCartBadge(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            showBadge: state.totalItems > 0,
            badgeStyle: badges.BadgeStyle(
              badgeColor: Theme.of(context).primaryColor,
            ),
            badgeContent: Text(
              '${state.totalItems}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
              ), // Slightly cleaner than shopping_cart
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderScreen()),
                  ),
            ),
          ),
        );
      },
    );
  }
}
