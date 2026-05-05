import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _searchQuery = '';
  String _categoryFilter = 'All';
  RangeValues? _priceRange;
  bool? _inStockFilter;
  String _sortBy = 'name_asc';

  List<Product> _applyFilters(List<Product> products) {
    var filtered = products.toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.farmerName.toLowerCase().contains(query) ||
            p.location.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    }

    if (_categoryFilter != 'All') {
      filtered =
          filtered.where((p) => p.category == _categoryFilter).toList();
    }

    if (_priceRange != null) {
      filtered = filtered.where((p) {
        return p.pricePerUnit >= _priceRange!.start &&
            p.pricePerUnit <= _priceRange!.end;
      }).toList();
    }

    if (_inStockFilter != null) {
      if (_inStockFilter!) {
        filtered = filtered.where((p) => p.stockQty > 0).toList();
      } else {
        filtered = filtered.where((p) => p.stockQty <= 0).toList();
      }
    }

    switch (_sortBy) {
      case 'name_asc':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_low':
        filtered
            .sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit));
        break;
      case 'price_high':
        filtered
            .sort((a, b) => b.pricePerUnit.compareTo(a.pricePerUnit));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'stock_low':
        filtered.sort((a, b) => a.stockQty.compareTo(b.stockQty));
        break;
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _categoryFilter = 'All';
      _priceRange = null;
      _inStockFilter = null;
      _sortBy = 'name_asc';
    });
  }

  bool get _hasActiveFilters =>
      _categoryFilter != 'All' ||
      _priceRange != null ||
      _inStockFilter != null;

  void _showPriceRangeDialog(double maxPrice) {
    var range = _priceRange ?? RangeValues(0, maxPrice);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Price Range', style: AppTextStyles.heading3),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RangeSlider(
                    values: range,
                    min: 0,
                    max: maxPrice,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    labels: RangeLabels(
                      '৳${range.start.toInt()}',
                      '৳${range.end.toInt()}',
                    ),
                    onChanged: (v) => setDialogState(() => range = v),
                  ),
                  Text(
                    '৳${range.start.toInt()} - ৳${range.end.toInt()}',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => _priceRange = null);
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _priceRange = range);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final allProducts = provider.products;
    final categories = provider.categories;
    final filteredProducts = _applyFilters(allProducts);
    final maxPrice = allProducts.isEmpty
        ? 100.0
        : allProducts
            .map((p) => p.pricePerUnit)
            .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search products, farmers, locations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final selected = _categoryFilter == cat;
                return ChoiceChip(
                  label: Text(cat, style: const TextStyle(fontSize: 13)),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _categoryFilter = cat),
                  selectedColor:
                      AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Advanced filters row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Price range
                OutlinedButton.icon(
                  onPressed: () => _showPriceRangeDialog(maxPrice),
                  icon: const Icon(Icons.attach_money, size: 16),
                  label: Text(
                    _priceRange != null
                        ? '৳${_priceRange!.start.toInt()}-৳${_priceRange!.end.toInt()}'
                        : 'Price',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    side: BorderSide(
                      color: _priceRange != null
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Stock filter
                ChoiceChip(
                  label: const Text('In Stock',
                      style: TextStyle(fontSize: 12)),
                  selected: _inStockFilter == true,
                  onSelected: (_) => setState(() {
                    _inStockFilter =
                        _inStockFilter == true ? null : true;
                  }),
                  selectedColor:
                      AppColors.primary.withValues(alpha: 0.15),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Out of Stock',
                      style: TextStyle(fontSize: 12)),
                  selected: _inStockFilter == false,
                  onSelected: (_) => setState(() {
                    _inStockFilter =
                        _inStockFilter == false ? null : false;
                  }),
                  selectedColor: AppColors.error.withValues(alpha: 0.15),
                  visualDensity: VisualDensity.compact,
                ),

                const Spacer(),

                // Sort
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, size: 20),
                  onSelected: (v) => setState(() => _sortBy = v),
                  itemBuilder: (_) => [
                    _buildSortItem('name_asc', 'Name: A-Z'),
                    _buildSortItem('name_desc', 'Name: Z-A'),
                    _buildSortItem('price_low', 'Price: Low to High'),
                    _buildSortItem('price_high', 'Price: High to Low'),
                    _buildSortItem('rating', 'Top Rated'),
                    _buildSortItem('stock_low', 'Stock: Low First'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Results & clear
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredProducts.length} product${filteredProducts.length != 1 ? 's' : ''} found',
                  style: AppTextStyles.bodySmall,
                ),
                const Spacer(),
                if (_hasActiveFilters)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 14),
                    label: const Text('Clear Filters',
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Products List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No products match your filters'),
                        if (_hasActiveFilters)
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear Filters'),
                          ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _ProductCard(
                          product: filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSortItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (_sortBy == value)
            const Icon(Icons.check, size: 16, color: AppColors.primary)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Image
          SizedBox(
            width: 90,
            height: 90,
            child: CachedNetworkImage(
              imageUrl: product.imagePath,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${product.farmerName} • ${product.location}',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '৳${product.pricePerUnit.toStringAsFixed(0)}/${product.unitType}',
                        style: AppTextStyles.price.copyWith(fontSize: 14),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.starYellow,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.stockQty > 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.stockQty > 0
                              ? '${product.stockQty.toInt()} left'
                              : 'Out',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: product.stockQty > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
