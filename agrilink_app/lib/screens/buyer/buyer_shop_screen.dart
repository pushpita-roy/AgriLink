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

class BuyerShopScreen extends StatefulWidget {
  const BuyerShopScreen({super.key});

  @override
  State<BuyerShopScreen> createState() => _BuyerShopScreenState();
}

class _BuyerShopScreenState extends State<BuyerShopScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Vegetables', 'Fruits', 'Seeds', 'Dairy'];

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
    final productProvider = context.watch<ProductProvider>();

    // Logic to filter products based on selected category locally
    final filteredProducts = _selectedCategory == 'All'
        ? productProvider.products
        : productProvider.products.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () => productProvider.fetchProducts(),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
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
                onSubmitted: (value) => productProvider.fetchProducts(search: value),
              ),
            ),

            // Category Selector
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Product Grid
            Expanded(
              child: filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                padding: const EdgeInsets.all(AppDimens.paddingMedium),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) => _AvailableProductCard(product: filteredProducts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("No products found in this category.", style: TextStyle(color: Colors.grey)),
    );
  }
}

class _AvailableProductCard extends StatelessWidget {
  final Product product;
  const _AvailableProductCard({required this.product});

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
                  errorWidget: (context, url, error) => const Icon(Icons.eco, size: 40, color: Colors.grey),
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
                      product.stockQty > 0 ? 'Stock: ${product.stockQty.toInt()}' : 'Out of Stock',
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
                          }
                        }),
                      ],
                    )
                        : ElevatedButton(
                      onPressed: () {
                        if (product.stockQty > 0) {
                          cartProvider.addToCart(product, user.id);
                        }
                      },
                      child: const Text('Add', style: TextStyle(fontSize: 12)),
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