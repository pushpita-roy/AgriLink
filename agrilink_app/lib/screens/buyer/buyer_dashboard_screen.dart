import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import 'product_detail_screen.dart';
import '../../models/cart_item_model.dart';
import 'buyer_home_screen.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.products;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserHeader(context, user.name, user.division ?? "No Division"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.borderRadius),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      await productProvider.fetchProducts(search: value);
                      if (productProvider.products.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No products found for your search.')),
                        );
                      } else {
                        final homeState = context.findAncestorStateOfType<State<BuyerHomeScreen>>();
                        if (homeState != null) {
                          (homeState as dynamic).changeTab(1);
                        }
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Popular Product'),
              const SizedBox(height: 12),
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isPopularLoading) {
                    return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
                  }
                  if (provider.popularProducts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
                      child: Text("No popular products in your area.", style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
                      itemCount: provider.popularProducts.length,
                      itemBuilder: (context, index) => _PopularProductCard(product: provider.popularProducts[index]),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Available Products'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: allProducts.length > 4 ? 4 : allProducts.length,
                  itemBuilder: (context, index) => _AvailableProductCard(product: allProducts[index]),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, String name, String locationText) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text(locationText, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class _PopularProductCard extends StatelessWidget {
  final Product product;
  const _PopularProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.borderRadiusLarge)),
                child: CachedNetworkImage(
                  imageUrl: product.imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[100], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (context, url, error) => Container(color: Colors.grey[100], child: Icon(Icons.eco, size: 40, color: Colors.grey[400])),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(product.category, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TK ${product.pricePerUnit.toInt()}/${product.unitType}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.starYellow),
                            const SizedBox(width: 2),
                            Text(product.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableProductCard extends StatelessWidget {
  final Product product;
  const _AvailableProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final user = context.read<AuthProvider>().currentUser!;

    CartItem? cartItem;
    try {
      cartItem = cartProvider.items.firstWhere((item) => item.productId == product.id);
    } catch (_) {
      cartItem = null;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: product.imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  ),
                  errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.eco, size: 40, color: Colors.grey)
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.stockQty > 0 ? Colors.black.withOpacity(0.6) : Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.stockQty > 0
                          ? (product.unitType.toLowerCase() == 'dozen'
                          ? 'Stock: ${(product.stockQty / 12).toStringAsFixed(1)} Doz'
                          : 'Stock: ${product.stockQty.toInt()} ${product.unitType}')
                          : 'Out of Stock',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('TK ${product.pricePerUnit.toInt()}/${product.unitType}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: cartItem != null
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _qtyBtn(Icons.remove, () {
                          if (cartItem!.quantity > 1) {
                            cartProvider.updateQuantity(cartItem.id, cartItem.quantity - 1, product.stockQty.toInt());
                          } else {
                            cartProvider.removeFromCart(cartItem.id);
                          }
                        }),
                        Text('${cartItem.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        _qtyBtn(Icons.add, () {
                          if (cartItem!.quantity < product.stockQty) {
                            cartProvider.updateQuantity(cartItem.id, cartItem.quantity + 1, product.stockQty.toInt());
                          } else {
                            _showStockWarning(context, product.stockQty.toInt());
                          }
                        }),
                      ],
                    )
                        : ElevatedButton(
                      onPressed: () {
                        if (product.stockQty <= 0) {
                          _showStockWarning(context, 0);
                        } else {
                          cartProvider.addToCart(product, user.id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStockWarning(BuildContext context, int available) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(available <= 0
            ? 'Sorry, this item is out of stock.'
            : 'Stock limit reached! Only $available units available.'),
        backgroundColor: Colors.orange[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: AppColors.primary),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      ),
    );
  }
}