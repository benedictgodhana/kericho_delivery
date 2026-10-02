import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/data/models/merchant_model.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AppProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) => _buildFavoriteCard(context, favorites[index]),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No favorites yet',
            style: GoogleFonts.afacad(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart on a restaurant to save it here',
            style: GoogleFonts.afacad(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => AppRouter.pushNamedAndRemoveUntil(AppRouter.home),
            child: const Text('Browse Restaurants'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, MerchantModel merchant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        onTap: () => AppRouter.pushNamed(
          AppRouter.merchant,
          arguments: {'merchantId': merchant.id, 'merchantName': merchant.name},
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 64,
            height: 64,
            child: merchant.imageUrl == null
                ? Container(color: Colors.grey[200], child: const Icon(Icons.storefront))
                : (merchant.imageUrl!.startsWith('http')
                    ? CachedNetworkImage(imageUrl: merchant.imageUrl!, fit: BoxFit.cover)
                    : Image.asset(merchant.imageUrl!, fit: BoxFit.cover)),
          ),
        ),
        title: Text(merchant.name, style: GoogleFonts.afacad(fontWeight: FontWeight.w700, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text('${merchant.rating}', style: GoogleFonts.afacad(fontSize: 13)),
              const SizedBox(width: 10),
              Icon(Icons.timer_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('${merchant.deliveryTime} min', style: GoogleFonts.afacad(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: AppTheme.primaryColor),
          onPressed: () => context.read<AppProvider>().toggleFavorite(merchant),
        ),
      ),
    );
  }
}
