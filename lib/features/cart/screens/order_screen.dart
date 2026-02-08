import 'dart:convert';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_bloc.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_event.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_state.dart';
import 'package:restaurant_menu_app/features/cart/models/cart_item.dart';
import 'package:restaurant_menu_app/features/cart/widgets/quantity_control.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  bool _isBase64(String path) => path.startsWith('data:image');
  bool _isLocalFile(String path) =>
      path.startsWith('/') || path.startsWith('file://');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.translate('your_order'),
          style: GoogleFonts.outfit(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: theme.colorScheme.error,
            ),
            onPressed: () => _showClearConfirmDialog(context, theme),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return _buildEmptyCart(context, theme);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _buildOrderItem(context, item, theme);
                  },
                ),
              ),
              _buildCheckoutSection(context, state, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.translate('bag_empty'),
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.5),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.translate('back_to_menu'),
              style: GoogleFonts.dmSans(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, CartItem item, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 80,
              height: 80,
              child: _buildImage(item.menuItem.imageUrl),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem.name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.menuItem.price} TMT',
                  style: GoogleFonts.dmSans(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // Quantity Controls
          QuantityControl(
            quantity: item.quantity,
            onDecrement: () {
              context.read<CartBloc>().add(
                UpdateCartItemQuantity(item.menuItem, item.quantity - 1),
              );
            },
            onIncrement: () {
              context.read<CartBloc>().add(
                UpdateCartItemQuantity(item.menuItem, item.quantity + 1),
              );
            },
            primaryColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    CartState state,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.translate('total'),
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    letterSpacing: 1.5,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${state.totalPrice} TMT',
                  style: GoogleFonts.outfit(
                    color: theme.colorScheme.primary, // Beige Orange
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showOrderSuccessDialog(context, theme),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.translate('place_order'),
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) return const Icon(Icons.fastfood, color: Colors.grey);
    if (_isBase64(imageUrl)) {
      try {
        return Image.memory(
          base64Decode(imageUrl.split(',').last),
          fit: BoxFit.cover,
        );
      } catch (_) {
        return const Icon(Icons.error, color: Colors.grey);
      }
    }
    if (_isLocalFile(imageUrl)) {
      return Image.file(File(imageUrl), fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => const Icon(Icons.error),
    );
  }

  void _showClearConfirmDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              AppLocalizations.of(context)!.translate('clear_order_title'),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.translate('clear_order_msg'),
              style: GoogleFonts.dmSans(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.translate('cancel'),
                  style: GoogleFonts.dmSans(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<CartBloc>().add(ClearCart());
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('clear'),
                  style: GoogleFonts.dmSans(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showOrderSuccessDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            icon: Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
              size: 64,
            ),
            title: Text(
              AppLocalizations.of(context)!.translate('order_placed'),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.translate('order_placed_msg'),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: Colors.white70),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FilledButton(
                    onPressed: () {
                      context.read<CartBloc>().add(ClearCart());
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('excellent'),
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
