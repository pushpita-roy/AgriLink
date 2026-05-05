-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Apr 27, 2026 at 06:26 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `agrilink_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `authtoken_token`
--

CREATE TABLE `authtoken_token` (
  `key` varchar(40) NOT NULL,
  `created` datetime(6) NOT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `authtoken_token`
--

INSERT INTO `authtoken_token` (`key`, `created`, `user_id`) VALUES
('8a0c75127fd2b3aacd4bff2d0471839ee89a06c0', '2026-04-27 16:16:56.587033', 3),
('b40afda34f8e831651c549c5a14fb7ffc442bc7a', '2026-04-27 16:25:04.766788', 2),
('d36dc3e12b3f6db53bbf1ae0db978953cdaaef9d', '2026-04-27 15:47:21.012540', 1);

-- --------------------------------------------------------

--
-- Table structure for table `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` bigint(20) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 2, 'add_permission'),
(6, 'Can change permission', 2, 'change_permission'),
(7, 'Can delete permission', 2, 'delete_permission'),
(8, 'Can view permission', 2, 'view_permission'),
(9, 'Can add group', 3, 'add_group'),
(10, 'Can change group', 3, 'change_group'),
(11, 'Can delete group', 3, 'delete_group'),
(12, 'Can view group', 3, 'view_group'),
(13, 'Can add content type', 4, 'add_contenttype'),
(14, 'Can change content type', 4, 'change_contenttype'),
(15, 'Can delete content type', 4, 'delete_contenttype'),
(16, 'Can view content type', 4, 'view_contenttype'),
(17, 'Can add session', 5, 'add_session'),
(18, 'Can change session', 5, 'change_session'),
(19, 'Can delete session', 5, 'delete_session'),
(20, 'Can view session', 5, 'view_session'),
(21, 'Can add Token', 6, 'add_token'),
(22, 'Can change Token', 6, 'change_token'),
(23, 'Can delete Token', 6, 'delete_token'),
(24, 'Can view Token', 6, 'view_token'),
(25, 'Can add Token', 7, 'add_tokenproxy'),
(26, 'Can change Token', 7, 'change_tokenproxy'),
(27, 'Can delete Token', 7, 'delete_tokenproxy'),
(28, 'Can view Token', 7, 'view_tokenproxy'),
(29, 'Can add user', 8, 'add_user'),
(30, 'Can change user', 8, 'change_user'),
(31, 'Can delete user', 8, 'delete_user'),
(32, 'Can view user', 8, 'view_user'),
(33, 'Can add product', 9, 'add_product'),
(34, 'Can change product', 9, 'change_product'),
(35, 'Can delete product', 9, 'delete_product'),
(36, 'Can view product', 9, 'view_product'),
(37, 'Can add order', 10, 'add_order'),
(38, 'Can change order', 10, 'change_order'),
(39, 'Can delete order', 10, 'delete_order'),
(40, 'Can view order', 10, 'view_order'),
(41, 'Can add order item', 11, 'add_orderitem'),
(42, 'Can change order item', 11, 'change_orderitem'),
(43, 'Can delete order item', 11, 'delete_orderitem'),
(44, 'Can view order item', 11, 'view_orderitem'),
(45, 'Can add cart item', 12, 'add_cartitem'),
(46, 'Can change cart item', 12, 'change_cartitem'),
(47, 'Can delete cart item', 12, 'delete_cartitem'),
(48, 'Can view cart item', 12, 'view_cartitem');

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` bigint(20) NOT NULL,
  `quantity` int(10) UNSIGNED NOT NULL CHECK (`quantity` >= 0),
  `created_at` datetime(6) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) UNSIGNED NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(8, 'accounts', 'user'),
(1, 'admin', 'logentry'),
(3, 'auth', 'group'),
(2, 'auth', 'permission'),
(6, 'authtoken', 'token'),
(7, 'authtoken', 'tokenproxy'),
(12, 'cart', 'cartitem'),
(4, 'contenttypes', 'contenttype'),
(10, 'orders', 'order'),
(11, 'orders', 'orderitem'),
(9, 'products', 'product'),
(5, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Table structure for table `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2026-04-27 14:22:59.886556'),
(2, 'contenttypes', '0002_remove_content_type_name', '2026-04-27 14:22:59.903056'),
(3, 'auth', '0001_initial', '2026-04-27 14:22:59.975293'),
(4, 'auth', '0002_alter_permission_name_max_length', '2026-04-27 14:22:59.993566'),
(5, 'auth', '0003_alter_user_email_max_length', '2026-04-27 14:22:59.997096'),
(6, 'auth', '0004_alter_user_username_opts', '2026-04-27 14:23:00.001100'),
(7, 'auth', '0005_alter_user_last_login_null', '2026-04-27 14:23:00.004092'),
(8, 'auth', '0006_require_contenttypes_0002', '2026-04-27 14:23:00.005126'),
(9, 'auth', '0007_alter_validators_add_error_messages', '2026-04-27 14:23:00.009636'),
(10, 'auth', '0008_alter_user_username_max_length', '2026-04-27 14:23:00.013700'),
(11, 'auth', '0009_alter_user_last_name_max_length', '2026-04-27 14:23:00.017690'),
(12, 'auth', '0010_alter_group_name_max_length', '2026-04-27 14:23:00.025221'),
(13, 'auth', '0011_update_proxy_permissions', '2026-04-27 14:23:00.029740'),
(14, 'auth', '0012_alter_user_first_name_max_length', '2026-04-27 14:23:00.033733'),
(15, 'accounts', '0001_initial', '2026-04-27 14:23:00.127642'),
(16, 'admin', '0001_initial', '2026-04-27 14:23:00.154152'),
(17, 'admin', '0002_logentry_remove_auto_add', '2026-04-27 14:23:00.159686'),
(18, 'admin', '0003_logentry_add_action_flag_choices', '2026-04-27 14:23:00.162686'),
(19, 'authtoken', '0001_initial', '2026-04-27 14:23:00.181517'),
(20, 'authtoken', '0002_auto_20160226_1747', '2026-04-27 14:23:00.193993'),
(21, 'authtoken', '0003_tokenproxy', '2026-04-27 14:23:00.196522'),
(22, 'authtoken', '0004_alter_tokenproxy_options', '2026-04-27 14:23:00.199596'),
(23, 'products', '0001_initial', '2026-04-27 14:23:00.220112'),
(24, 'cart', '0001_initial', '2026-04-27 14:23:00.258916'),
(25, 'orders', '0001_initial', '2026-04-27 14:23:00.333945'),
(26, 'sessions', '0001_initial', '2026-04-27 14:23:00.344982');

-- --------------------------------------------------------

--
-- Table structure for table `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) NOT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `payment_method` varchar(20) NOT NULL,
  `payment_status` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `shipping_address` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `buyer_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `total_amount`, `payment_method`, `payment_status`, `status`, `shipping_address`, `created_at`, `buyer_id`) VALUES
(1, 550.00, 'COD', 'paid', 'delivered', 'Bhanga, Faridpur', '2026-04-27 14:23:11.763210', 2),
(2, 120.00, 'COD', 'pending', 'pending', 'Bhanga, Faridpur', '2026-04-27 14:23:11.765214', 2),
(3, 14.00, 'COD', 'pending', 'pending', 'Bhanga, Faridpur', '2026-04-27 15:43:45.863595', 2),
(4, 68.00, 'COD', 'pending', 'pending', 'Bhanga, Faridpur', '2026-04-27 15:44:37.148374', 2),
(5, 54.00, 'Bkash', 'pending', 'pending', 'Bhanga, Faridpur', '2026-04-27 15:56:23.564870', 2),
(6, 98.00, 'COD', 'pending', 'pending', 'Bhanga, Faridpur', '2026-04-27 15:56:46.421988', 2);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) NOT NULL,
  `product_name` varchar(200) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `quantity` int(10) UNSIGNED NOT NULL CHECK (`quantity` >= 0),
  `farmer_id` bigint(20) DEFAULT NULL,
  `order_id` bigint(20) NOT NULL,
  `product_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `product_name`, `unit_price`, `quantity`, `farmer_id`, `order_id`, `product_id`) VALUES
(1, 'Rice Seed', 55.00, 10, 1, 1, 1),
(2, 'Mango', 40.00, 3, 1, 2, 6),
(3, 'Cherry', 14.00, 1, 1, 3, 4),
(4, 'Mango', 40.00, 1, 1, 4, 6),
(5, 'Chilli', 14.00, 1, 1, 4, 5),
(6, 'Cherry', 14.00, 1, 1, 4, 4),
(7, 'Mango', 40.00, 1, 1, 5, 6),
(8, 'Chilli', 14.00, 1, 1, 5, 5),
(9, 'Mango', 40.00, 1, 1, 6, 6),
(10, 'Chilli', 14.00, 1, 1, 6, 5),
(11, 'Cherry', 14.00, 1, 1, 6, 4),
(12, 'Wheat Seed', 30.00, 1, 1, 6, 3);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) NOT NULL,
  `name` varchar(200) NOT NULL,
  `category` varchar(100) NOT NULL,
  `description` longtext NOT NULL,
  `unit_type` varchar(20) NOT NULL,
  `price_per_unit` decimal(10,2) NOT NULL,
  `stock_qty` decimal(10,2) NOT NULL,
  `location` varchar(255) NOT NULL,
  `harvest_date` date DEFAULT NULL,
  `image` varchar(100) DEFAULT NULL,
  `image_url` varchar(500) NOT NULL,
  `rating` decimal(3,1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `farmer_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `category`, `description`, `unit_type`, `price_per_unit`, `stock_qty`, `location`, `harvest_date`, `image`, `image_url`, `rating`, `created_at`, `farmer_id`) VALUES
(1, 'Rice Seed', 'Seeds', 'Premium quality rice seed for the season. Grown organically.', 'kg', 55.00, 50.00, 'Madhupur, Tangail', '2025-05-25', '', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400', 4.8, '2026-04-27 14:23:11.749213', 1),
(2, 'Lemon', 'Fruits', 'Fresh lemons from Tangail. Perfect for cooking and drinks.', 'kg', 14.00, 30.00, 'Madhupur, Tangail', '2025-05-20', '', 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=400', 4.5, '2026-04-27 14:23:11.752214', 1),
(3, 'Wheat Seed', 'Seeds', 'High-yield wheat seed variety suitable for all soil types.', 'kg', 30.00, 79.00, 'Madhupur, Tangail', '2025-05-15', '', 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400', 4.7, '2026-04-27 14:23:11.754570', 1),
(4, 'Cherry', 'Fruits', 'Sweet red cherries freshly picked from the orchard.', 'kg', 14.00, 17.00, 'Madhupur, Tangail', '2025-05-18', '', 'https://images.unsplash.com/photo-1528821128474-27f963b062bf?w=400', 4.6, '2026-04-27 14:23:11.756859', 1),
(5, 'Chilli', 'Vegetables', 'Spicy green and red chillies, organically grown.', 'kg', 14.00, 37.00, 'Madhupur, Tangail', '2025-05-22', '', 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=400', 4.3, '2026-04-27 14:23:11.758865', 1),
(6, 'Mango', 'Fruits', 'Langra variety mangoes, sweet and juicy.', 'kg', 40.00, 57.00, 'Madhupur, Tangail', '2025-05-10', '', 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400', 4.9, '2026-04-27 14:23:11.760878', 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) NOT NULL,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `role` varchar(10) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` varchar(255) NOT NULL,
  `district` varchar(100) NOT NULL,
  `farm_name` varchar(200) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL,
  `name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `password`, `last_login`, `is_superuser`, `username`, `first_name`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `role`, `phone`, `address`, `district`, `farm_name`, `is_verified`, `name`) VALUES
(1, 'pbkdf2_sha256$600000$2yK80qcgobtQWLJwr9OHDd$I4n4elO8uHJqdIw9VIOw9rtXdEFULmTDaC/LQWPnR9o=', NULL, 0, 'farmer@gmail.com', '', '', 'farmer@gmail.com', 0, 1, '2026-04-27 14:23:11.119273', 'farmer', '01712345678', 'Madhupur', 'Tangail', 'Rafique\'s Farm', 1, 'Rafique'),
(2, 'pbkdf2_sha256$600000$hFRjMM81Zz5tKjbkemmpQO$wSSHIthz754uHOHR9bC7yYyUI1nW8roQX3y/qNIXP6E=', NULL, 0, 'buyer@gmail.com', '', '', 'buyer@gmail.com', 0, 1, '2026-04-27 14:23:11.345587', 'buyer', '01812345678', 'Bhanga', 'Faridpur', NULL, 1, 'Pushpita'),
(3, 'pbkdf2_sha256$600000$WTWfeXDQZJWH7FrCxIAc8l$Ta12Bf4UyAwVZsZVutD84f84NxPLeoiUSkuvwXdnfmE=', NULL, 1, 'admin@gmail.com', '', '', 'admin@gmail.com', 1, 1, '2026-04-27 14:23:11.549720', 'admin', '01612345678', 'Dhaka', 'Dhaka', NULL, 1, 'Admin'),
(4, 'pbkdf2_sha256$600000$ztWa6LrFZXeWQ1gKCRd8G4$koOcAsIPMupsF0wcb6jb2kW0a049754T5F0+Cbjq1pE=', NULL, 0, 'mithila@gmail.com', '', '', 'mithila@gmail.com', 0, 1, '2026-04-27 15:46:01.866768', 'buyer', '', '', '', NULL, 0, 'Mithila');

-- --------------------------------------------------------

--
-- Table structure for table `users_groups`
--

CREATE TABLE `users_groups` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users_user_permissions`
--

CREATE TABLE `users_user_permissions` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `authtoken_token`
--
ALTER TABLE `authtoken_token`
  ADD PRIMARY KEY (`key`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indexes for table `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cart_items_user_id_product_id_e4319647_uniq` (`user_id`,`product_id`),
  ADD KEY `cart_items_product_id_9398bb89_fk_products_id` (`product_id`);

--
-- Indexes for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_users_id` (`user_id`);

--
-- Indexes for table `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indexes for table `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_buyer_id_3d1f9476_fk_users_id` (`buyer_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_farmer_id_f80e5aa3_fk_users_id` (`farmer_id`),
  ADD KEY `order_items_order_id_412ad78b_fk_orders_id` (`order_id`),
  ADD KEY `order_items_product_id_dd557d5a_fk_products_id` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `products_farmer_id_476bbea8_fk_users_id` (`farmer_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `users_groups`
--
ALTER TABLE `users_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_groups_user_id_group_id_fc7788e8_uniq` (`user_id`,`group_id`),
  ADD KEY `users_groups_group_id_2f3517aa_fk_auth_group_id` (`group_id`);

--
-- Indexes for table `users_user_permissions`
--
ALTER TABLE `users_user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_user_permissions_user_id_permission_id_3b86cbdf_uniq` (`user_id`,`permission_id`),
  ADD KEY `users_user_permissio_permission_id_6d08dcd2_fk_auth_perm` (`permission_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users_groups`
--
ALTER TABLE `users_groups`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users_user_permissions`
--
ALTER TABLE `users_user_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `authtoken_token`
--
ALTER TABLE `authtoken_token`
  ADD CONSTRAINT `authtoken_token_user_id_35299eff_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Constraints for table `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_product_id_9398bb89_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `cart_items_user_id_74745f54_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  ADD CONSTRAINT `django_admin_log_user_id_c564eba6_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_buyer_id_3d1f9476_fk_users_id` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_farmer_id_f80e5aa3_fk_users_id` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `order_items_order_id_412ad78b_fk_orders_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `order_items_product_id_dd557d5a_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_farmer_id_476bbea8_fk_users_id` FOREIGN KEY (`farmer_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users_groups`
--
ALTER TABLE `users_groups`
  ADD CONSTRAINT `users_groups_group_id_2f3517aa_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  ADD CONSTRAINT `users_groups_user_id_f500bee5_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users_user_permissions`
--
ALTER TABLE `users_user_permissions`
  ADD CONSTRAINT `users_user_permissio_permission_id_6d08dcd2_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `users_user_permissions_user_id_92473840_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
