import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class FarmerAddProductScreen extends StatefulWidget {
  final Product? product; // null for new product, non-null for editing

  const FarmerAddProductScreen({super.key, this.product});

  @override
  State<FarmerAddProductScreen> createState() => _FarmerAddProductScreenState();
}

class _FarmerAddProductScreenState extends State<FarmerAddProductScreen> {
  Uint8List? _webImage;
  XFile? _pickedFile;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  String _selectedUnit = 'kg';
  String _selectedCategory = 'Fruits';

  final List<String> _units = ['kg', 'liter', 'dozen', 'crate', 'bundle', 'piece'];
  final List<String> _categories = ['Fruits', 'Vegetables', 'Seeds', 'Grains', 'Dairy', 'Other'];

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _quantityController = TextEditingController(text: widget.product?.stockQty.toInt().toString() ?? '');
    _priceController = TextEditingController(text: widget.product?.pricePerUnit.toInt().toString() ?? '');

    if (widget.product != null) {
      _selectedUnit = widget.product!.unitType;
      _selectedCategory = widget.product!.category.isNotEmpty ? widget.product!.category : 'Fruits';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _webImage = bytes;
        _pickedFile = image;
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().currentUser!;
    final productProvider = context.read<ProductProvider>();

    final product = Product(
      id: isEditing ? widget.product!.id : '0',
      farmerId: user.id,
      farmerName: user.name,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      unitType: _selectedUnit,
      pricePerUnit: double.parse(_priceController.text),
      stockQty: double.parse(_quantityController.text),
      // Automatically uses user's division
      location: user.division ?? 'Unknown',
      harvestDate: DateTime.now(),
      imagePath: widget.product?.imagePath ?? 'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400',
    );

    try {
      if (isEditing) {
        await productProvider.updateProduct(product);
      } else {
        await productProvider.addProduct(
          product,
          imageBytes: _webImage,
          imageName: _pickedFile?.name,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Product updated successfully!' : 'Product added successfully!'), backgroundColor: AppColors.primary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await context.read<ProductProvider>().deleteProduct(widget.product!.id);
                Navigator.pop(ctx);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Product Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppDimens.borderRadius),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: _webImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(AppDimens.borderRadius), child: Image.memory(_webImage!, fit: BoxFit.cover))
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Tap to add product image', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name', prefixIcon: Icon(Icons.eco_outlined)),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter product name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
              ),
              const SizedBox(height: 16),

              // --- UPDATED LOCATION FIELD (Automated) ---
              TextFormField(
                key: ValueKey(isEditing), // Forces refresh
                initialValue: isEditing
                    ? widget.product?.location
                    : context.read<AuthProvider>().currentUser?.division ?? 'Location not set',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity', prefixIcon: Icon(Icons.inventory_outlined)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (value) => setState(() => _selectedUnit = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price Per $_selectedUnit',
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  prefixText: 'TK ',
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter price' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(isEditing ? 'Update Product' : 'Add'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}