import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = '';
  UserRole? _selectedRole;
  bool? _verifiedFilter;

  List<UserModel> _applyFilters(List<UserModel> users) {
    var filtered = users.toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((u) {
        return u.name.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query) ||
            u.district.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedRole != null) {
      filtered = filtered.where((u) => u.role == _selectedRole).toList();
    }

    if (_verifiedFilter != null) {
      filtered =
          filtered.where((u) => u.isVerified == _verifiedFilter).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedRole = null;
      _verifiedFilter = null;
    });
  }

  bool get _hasActiveFilters =>
      _selectedRole != null || _verifiedFilter != null;

  @override
  Widget build(BuildContext context) {
    final allUsers = context.watch<AuthProvider>().allUsers;
    final filteredUsers = _applyFilters(allUsers);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name, email, or district...',
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

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChipWidget(
                  label: 'All Roles',
                  selected: _selectedRole == null,
                  onSelected: (_) =>
                      setState(() => _selectedRole = null),
                ),
                const SizedBox(width: 8),
                _FilterChipWidget(
                  label: 'Farmers',
                  selected: _selectedRole == UserRole.farmer,
                  onSelected: (_) =>
                      setState(() => _selectedRole = UserRole.farmer),
                ),
                const SizedBox(width: 8),
                _FilterChipWidget(
                  label: 'Buyers',
                  selected: _selectedRole == UserRole.buyer,
                  onSelected: (_) =>
                      setState(() => _selectedRole = UserRole.buyer),
                ),
                const SizedBox(width: 8),
                _FilterChipWidget(
                  label: 'Admins',
                  selected: _selectedRole == UserRole.admin,
                  onSelected: (_) =>
                      setState(() => _selectedRole = UserRole.admin),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.divider,
                ),
                const SizedBox(width: 16),
                _FilterChipWidget(
                  label: 'Verified',
                  selected: _verifiedFilter == true,
                  onSelected: (_) => setState(() {
                    _verifiedFilter =
                        _verifiedFilter == true ? null : true;
                  }),
                ),
                const SizedBox(width: 8),
                _FilterChipWidget(
                  label: 'Unverified',
                  selected: _verifiedFilter == false,
                  onSelected: (_) => setState(() {
                    _verifiedFilter =
                        _verifiedFilter == false ? null : false;
                  }),
                ),
                if (_hasActiveFilters) ...[
                  const SizedBox(width: 12),
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    onPressed: _clearFilters,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredUsers.length} user${filteredUsers.length != 1 ? 's' : ''} found',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Users List
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_off,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No users match your filters'),
                        if (_hasActiveFilters)
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear Filters'),
                          ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _UserCard(user: user);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChipWidget({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.divider,
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _roleColor(user.role).withValues(alpha: 0.15),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: _roleColor(user.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (user.isVerified)
                        const Icon(Icons.verified,
                            size: 16, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user.email, style: AppTextStyles.bodySmall),
                  if (user.district.isNotEmpty)
                    Text(
                      '${user.address.isNotEmpty ? '${user.address}, ' : ''}${user.district}',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                ],
              ),
            ),
            _RoleBadge(role: user.role),
          ],
        ),
      ),
    );
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return AppColors.primary;
      case UserRole.buyer:
        return Colors.blue;
      case UserRole.admin:
        return Colors.purple;
    }
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      UserRole.farmer => AppColors.primary,
      UserRole.buyer => Colors.blue,
      UserRole.admin => Colors.purple,
    };
    final label = switch (role) {
      UserRole.farmer => 'Farmer',
      UserRole.buyer => 'Buyer',
      UserRole.admin => 'Admin',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
