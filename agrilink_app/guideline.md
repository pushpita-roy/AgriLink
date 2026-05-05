# AgriLink Flutter Mobile App — Complete Setup & Development Guide

## 📌 What is AgriLink?

AgriLink is a mobile application that connects **farmers** directly with **urban buyers**, eliminating middlemen in the agricultural supply chain. The app has three user roles: **Farmer**, **Buyer**, and **Admin**.

---

## 🚀 Prerequisites — What You Need to Install

### 1. Install Flutter SDK

1. Go to [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2. Download the Flutter SDK for **Windows**
3. Extract to a location like `C:\flutter`
4. Add `C:\flutter\bin` to your **System PATH** environment variable
5. Open a terminal and run:
   ```
   flutter doctor
   ```
   This shows what else you need to install.

### 2. Install Android Studio (for Android development)

1. Download from [https://developer.android.com/studio](https://developer.android.com/studio)
2. During installation, make sure to install:
   - Android SDK
   - Android SDK Command-line Tools
   - Android Emulator
3. Open Android Studio → **Settings** → **Plugins** → Install **Flutter** plugin (it will also install the Dart plugin)
4. Accept Android licenses by running:
   ```
   flutter doctor --android-licenses
   ```

### 3. Install VS Code (recommended editor)

1. Download from [https://code.visualstudio.com/](https://code.visualstudio.com/)
2. Install the **Flutter** extension from the Extensions marketplace
3. Install the **Dart** extension as well

### 4. Set Up an Emulator or Physical Device

**Option A: Android Emulator**
- Open Android Studio → **Device Manager** → Create a Virtual Device
- Choose a phone like **Pixel 6** → Download a system image (API 33+) → Finish
- Launch the emulator

**Option B: Physical Android Device**
- Enable **Developer Options** on your phone (tap Build Number 7 times in Settings → About Phone)
- Enable **USB Debugging** in Developer Options
- Connect your phone via USB cable
- Run `flutter devices` to confirm it's detected

---

## 📂 Project Structure

The Flutter project is already created at:
```
AgriLink/agrilink_app/
```

Here's the folder structure:

```
agrilink_app/
├── assets/
│   └── images/
│       └── logo.jpg                    # App logo
├── lib/
│   ├── main.dart                       # App entry point
│   ├── models/
│   │   ├── user_model.dart             # User data model (farmer/buyer/admin)
│   │   ├── product_model.dart          # Product data model
│   │   ├── cart_item_model.dart        # Cart item data model
│   │   └── order_model.dart            # Order & Order Item data models
│   ├── providers/
│   │   ├── auth_provider.dart          # Authentication state management
│   │   ├── product_provider.dart       # Product listing state management
│   │   ├── cart_provider.dart          # Shopping cart state management
│   │   └── order_provider.dart         # Orders state management
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── splash_screen.dart      # Splash/loading screen
│   │   │   └── login_screen.dart       # Login & Sign Up screen
│   │   ├── farmer/
│   │   │   ├── farmer_home_screen.dart       # Farmer main navigation
│   │   │   ├── farmer_products_screen.dart   # Farmer's product grid
│   │   │   └── farmer_add_product_screen.dart # Add/Edit product form
│   │   ├── buyer/
│   │   │   ├── buyer_home_screen.dart        # Buyer main navigation
│   │   │   ├── buyer_dashboard_screen.dart   # Buyer home (popular/available products)
│   │   │   ├── buyer_shop_screen.dart        # Searchable product shop
│   │   │   ├── buyer_cart_screen.dart        # Shopping cart & checkout
│   │   │   └── product_detail_screen.dart    # Full product detail page
│   │   └── common/
│   │       ├── profile_screen.dart           # User profile screen
│   │       └── orders_screen.dart            # My Orders screen
│   ├── utils/
│   │   ├── constants.dart              # Colors, text styles, dimensions
│   │   └── theme.dart                  # App-wide theming
│   ├── widgets/                        # Reusable widgets (extend here)
│   └── services/                       # API services (extend here)
├── pubspec.yaml                        # Dependencies & assets config
└── test/
    └── widget_test.dart                # Basic test
```

---

## ▶️ How to Run the App

1. Open a terminal/command prompt
2. Navigate to the project:
   ```
   cd E:\WorkBench\rubai-projects\AgriLink\agrilink_app
   ```
3. Get dependencies (already done, but run again if needed):
   ```
   flutter pub get
   ```
4. Make sure an emulator is running or a phone is connected:
   ```
   flutter devices
   ```
5. Run the app:
   ```
   flutter run
   ```
   - The app will build and install on the device/emulator
   - **Hot Reload**: Press `r` in the terminal to reload changes instantly
   - **Hot Restart**: Press `R` to fully restart the app

---

## 📱 App Screens (What's Built)

### 1. Splash Screen
- Shows the AgriLink logo with animation
- Auto-navigates to Login after 3 seconds

### 2. Login / Sign Up Screen
- Toggle between **Login** and **Sign Up** tabs
- **Login**: Email + Password + User Role (Farmer/Buyer) selector
- **Sign Up**: Name + Email + Password + Role selector
- Demo credentials displayed on the login form:
  - **Farmer**: `farmer@gmail.com` / `123456`
  - **Buyer**: `buyer@gmail.com` / `123456`

### 3. Farmer — My Products (Grid View)
- Shows all products added by the logged-in farmer
- 2-column grid with product image, name, price (TK/kg), stock, harvest date
- Each card has an **Edit** button
- **Floating Action Button**: "Add Product"

### 4. Farmer — Add/Edit Product
- Form with: Product Name, Category, Description, Quantity, Unit, Price, Location
- Image upload placeholder (ready for backend integration)
- Edit mode pre-fills existing data
- Delete option in edit mode

### 5. Buyer — Home/Dashboard
- User header showing name and location
- **Popular Products**: Horizontal scrollable cards with rating
- **Available Products**: 2-column grid with "Add to Cart" buttons

### 6. Buyer — Shop
- Full searchable product listing
- Category filter chips (All, Fruits, Vegetables, Seeds, etc.)
- 2-column product grid with "Add to Cart" buttons
- Products already in cart show "In Cart" (disabled)

### 7. Buyer — Cart & Checkout
- List of cart items with quantity controls (+/-)
- Per-item and total pricing
- Remove items or clear all
- **Checkout**: Bottom sheet with shipping address, payment method (COD/Bkash/Nagad), place order

### 8. Product Detail Screen
- Full-screen product image header
- Name, rating, category badge
- Price, farmer info, location, stock, harvest date
- Description
- "Add to Cart" bottom button

### 9. Profile Screen
- Stats: Total Orders, Pending Orders
- User info card (name, location, email)
- Menu: My Orders, Payment Method, Order History, Settings, Privacy Policy
- **Log Out** button

### 10. Orders Screen
- List of orders with status badges (Pending/Confirmed/Shipped/Delivered/Cancelled)
- Order items with quantity and prices
- Payment method and date

---

## 🔧 Key Technologies Used

| Package | Purpose |
|---------|---------|
| `provider` | State management (managing app data across screens) |
| `google_fonts` | Poppins font throughout the app |
| `cached_network_image` | Loading and caching product images |
| `flutter_rating_bar` | Star ratings display |
| `intl` | Date formatting |

---

## 🛠️ What to Do Next — Step by Step

### Step 1: Run and Test the App
```
cd E:\WorkBench\rubai-projects\AgriLink\agrilink_app
flutter run
```
- Test login with **farmer** and **buyer** credentials
- Browse products, add to cart, checkout
- Test add/edit product as farmer

### Step 2: Connect to a Real Backend (PHP/MySQL)
The current app uses **demo data** hardcoded in the providers. To connect to your existing PHP backend:

1. **Create a REST API** in PHP that exposes endpoints:
   - `POST /api/login` — authenticate user
   - `POST /api/register` — create account
   - `GET /api/products` — list all products
   - `POST /api/products` — add a product (farmer)
   - `PUT /api/products/{id}` — update a product
   - `DELETE /api/products/{id}` — delete a product
   - `GET /api/cart` — get user's cart
   - `POST /api/cart` — add to cart
   - `POST /api/orders` — place an order
   - `GET /api/orders` — get user's orders

2. **Install HTTP package** in Flutter:
   ```yaml
   # Already available via dependencies, or add:
   dependencies:
     http: ^1.2.0
   ```

3. **Create API service** in `lib/services/api_service.dart`:
   ```dart
   import 'dart:convert';
   import 'package:http/http.dart' as http;

   class ApiService {
     // Change this to your server's IP address
     // Use 10.0.2.2 for Android emulator to access localhost
     static const String baseUrl = 'http://10.0.2.2/agrilink/api';

     Future<Map<String, dynamic>> login(String email, String password) async {
       final response = await http.post(
         Uri.parse('$baseUrl/login'),
         body: {'email': email, 'password': password},
       );
       return json.decode(response.body);
     }

     // Add more methods for each endpoint...
   }
   ```

4. **Update providers** to call the API instead of using demo data

### Step 3: Add Image Upload
1. Add `image_picker` package:
   ```yaml
   dependencies:
     image_picker: ^1.0.7
   ```
2. Update the Add Product screen to pick images from camera/gallery
3. Upload images to your PHP server using multipart form data

### Step 4: Add Real Payment Integration
- For **bKash/Nagad**: Use their merchant API or Flutter SDK
- For testing: Keep COD as the default payment method

### Step 5: Build the APK for Installation
```
flutter build apk --release
```
The APK file will be at:
```
agrilink_app/build/app/outputs/flutter-apk/app-release.apk
```
Transfer this file to any Android phone and install it.

### Step 6: Optional Enhancements
- [ ] Add push notifications for order updates
- [ ] Add real-time delivery tracking with Google Maps
- [ ] Add AI-based product recommendations
- [ ] Add weather tips for farmers
- [ ] Build an Admin dashboard screen
- [ ] Add image picker for product photos
- [ ] Add user profile editing
- [ ] Add product reviews/feedback system

---

## 🐛 Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| `flutter: command not found` | Add Flutter to PATH |
| `No connected devices` | Start an emulator or connect phone with USB debugging |
| `Gradle build failed` | Run `flutter clean` then `flutter pub get` then `flutter run` |
| `Network images not loading` | Add internet permission (already included by default) |
| Black/white screen on launch | Run `flutter clean` and rebuild |

---

## 📝 Quick Reference Commands

| Command | What it does |
|---------|-------------|
| `flutter run` | Run the app on a connected device |
| `flutter run -d chrome` | Run on Chrome (web) |
| `flutter build apk` | Build Android APK |
| `flutter build apk --release` | Build release APK |
| `flutter clean` | Clean build cache |
| `flutter pub get` | Install dependencies |
| `flutter analyze` | Check code for errors |
| `flutter doctor` | Check development setup |
| `r` (during run) | Hot reload (fast update) |
| `R` (during run) | Hot restart (full restart) |

---

## 📞 Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Farmer | farmer@gmail.com | 123456 |
| Buyer | buyer@gmail.com | 123456 |

---

*This app was built based on the AgriLink project report and UI mockup designs.*
