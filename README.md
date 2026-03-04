# 💰 Wallet App - Mobile Banking Home Screen

A Flutter mobile banking application built with **Clean Architecture** and **BLoC/Cubit** state management, demonstrating professional handling of loading states, error flows, and pagination.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Design Decisions](#design-decisions)
- [State Management](#state-management)
- [Features](#features)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [Testing](#testing)
- [Demo Video](#demo-video)

---

## 🎯 Overview

This project implements a mobile banking home screen that displays:

- **Wallet balance** with hide/show toggle
- **Transaction list** with infinite scroll pagination
- **Pull-to-refresh** functionality
- **Comprehensive error handling** with retry mechanisms
- **Mock API** with configurable modes for testing (success, network error, server error, timeout)

### Key Highlights

✅ **Clean Architecture** with clear separation of concerns  
✅ **73 unit tests** covering all layers  
✅ **State maintenance** during loading and errors  
✅ **Professional UI** with shimmer loading and error states  
✅ **Debug menu** for runtime error simulation

---

## 🏗️ Architecture

The application follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Widgets, Cubit, States)          │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│  (Entities, Use Cases, Repositories)   │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Models, Data Sources, Repo Impl)     │
└─────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. **Domain Layer** (Business Logic)

- **Entities**: Pure Dart classes representing business objects
  - `Balance`, `Transaction`, `WalletOverview`
- **Repositories**: Abstract interfaces defining data contracts
- **Use Cases**: Encapsulated business logic
  - `GetWalletOverviewUseCase`
  - `GetTransactionsUseCase`

#### 2. **Data Layer** (Data Management)

- **Models**: Entities with JSON serialization
  - `BalanceModel`, `TransactionModel`, `WalletOverviewModel`
- **Data Sources**: API communication
  - `WalletRemoteDataSource` with mock API (47 transactions)
- **Repository Implementations**: Error handling and data mapping
  - Maps `Exception` → `Failure` (NetworkFailure, ServerFailure)

#### 3. **Presentation Layer** (UI)

- **Cubit**: State management with `WalletCubit`
  - `getWalletOverview()`, `loadMoreTransactions()`, `refresh()`, `reset()`
- **States**: `WalletInitial`, `WalletLoading`, `TransactionsLoading`, `WalletLoaded`, `WalletError`
- **Widgets**: Reusable UI components
  - `BalanceCard`, `TransactionTile`, `ErrorRetryWidget`
  - `BalanceShimmer`, `TransactionListShimmer`

---

## 🎨 Design Decisions

### 1. **State Maintenance Pattern**

**Decision**: Preserve existing data during refresh and pagination.

**Rationale**:

- Better UX - users see their data while new content loads
- No flickering or blank screens during refresh
- Clear visual feedback with loading indicators

**Implementation**:

```dart
WalletLoading(
  transactions: state.transactions, // ✅ Preserved
  balance: state.balance,           // ✅ Preserved
  meta: state.meta,                 // ✅ Preserved
)
```

### 2. **Separate Loading States**

**Decision**: Distinguish between initial loading and pagination loading.

**Rationale**:

- Different UI feedback for different contexts
- `WalletLoading` → Full shimmer on initial load
- `TransactionsLoading` → Bottom indicator for pagination

**Implementation**:

```dart
// Initial load
emit(WalletLoading(transactions: [], balance: null));

// Pagination
emit(TransactionsLoading(transactions: existing, balance: existing));
```

### 3. **Error Flow Strategy**

**Decision**: Different error displays based on context.

**Rationale**:

- **Initial load failure** → Full-screen retry widget (no data to show)
- **Pagination/refresh failure** → Bottom SnackBar (data still visible)

**Implementation**:

```dart
// Initial error
if (state.transactions.isEmpty) {
  return ErrorRetryWidget(message: error, onRetry: retry);
}

// Pagination error
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(error), action: SnackBarAction(...))
);
```

### 4. **Mock API with Testable Modes**

**Decision**: Implement runtime-switchable error simulation.

**Rationale**:

- Easy testing of all error scenarios
- No need for real backend during development
- Demonstrates error handling capabilities

**Implementation**:

```dart
enum MockMode { success, networkError, serverError, timeout }

// Switch via debug menu
dataSource.setMode(MockMode.networkError);
cubit.reset(); // Triggers reload with new mode
```

### 5. **Dependency Injection with GetIt**

**Decision**: Use service locator pattern for dependency management.

**Rationale**:

- Loose coupling between layers
- Easy testing with mock implementations
- Single source of truth for dependencies

### 6. **Functional Error Handling with Dartz**

**Decision**: Use `Either<Failure, Success>` for error handling.

**Rationale**:

- Type-safe error handling
- Forces explicit error handling
- No uncaught exceptions

---

## 🔄 State Management

### WalletCubit States

```dart
WalletInitial()
  ↓ getWalletOverview()
WalletLoading(empty)
  ↓ success
WalletLoaded(balance, transactions, meta)
  ↓ loadMoreTransactions()
TransactionsLoading(preserved data)
  ↓ success
WalletLoaded(balance, updated transactions, new meta)
```

### State Transitions

| Action              | From State      | To State                                           | Data Preservation |
| ------------------- | --------------- | -------------------------------------------------- | ----------------- |
| Initial Load        | `WalletInitial` | `WalletLoading` → `WalletLoaded`                   | None (empty)      |
| Refresh             | `WalletLoaded`  | `WalletLoading` → `WalletLoaded`                   | ✅ All data       |
| Load More           | `WalletLoaded`  | `TransactionsLoading` → `WalletLoaded`             | ✅ All data       |
| Reset (Mode Switch) | `WalletLoaded`  | `WalletInitial` → `WalletLoading` → `WalletLoaded` | ❌ Cleared        |
| Error               | Any             | `WalletError`                                      | ✅ Preserved      |

---

## ✨ Features

### 1. **Balance Display**

- European number format (€ 25.175,00)
- Hide/Show toggle with pill button
- 24-hour change indicator

### 2. **Transaction List**

- Crypto-branded icons with color coding
- Dual amount display (€ + crypto)
- Infinite scroll pagination (80% trigger)
- 47 mock transactions across 5 pages

### 3. **Loading States**

- **Shimmer placeholders** on initial load
- **Bottom indicator** during pagination
- **Pull-to-refresh** with RefreshIndicator

### 4. **Error Handling**

- **Network errors**: "No internet connection"
- **Server errors**: "Internal server error (500)"
- **Timeout errors**: "Request timed out"
- **Retry mechanisms**: Full-screen widget or SnackBar action

### 5. **Debug Menu**

- Runtime mode switching (🐛 icon in AppBar)
- 4 modes: Success, Network Error, Server Error, Timeout
- Instant state reset for testing

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── entities/          # Shared entities (Meta)
│   ├── error/             # Failures & Exceptions
│   ├── models/            # Shared models (MetaModel)
│   ├── theme/             # App theme
│   └── usecases/          # Base UseCase class
├── features/
│   ├── home/
│   │   └── presentation/
│   │       └── screens/
│   │           └── home_screen.dart
│   └── wallet/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── wallet_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── balance_model.dart
│       │   │   ├── transaction_model.dart
│       │   │   └── wallet_overview_model.dart
│       │   └── repositories/
│       │       └── wallet_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── balance.dart
│       │   │   ├── transaction.dart
│       │   │   └── wallet_overview.dart
│       │   ├── repositories/
│       │   │   └── wallet_repository.dart
│       │   └── usecases/
│       │       ├── get_wallet_overview_usecase.dart
│       │       └── get_transactions_usecase.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── wallet_cubit.dart
│           │   └── wallet_state.dart
│           └── widgets/
│               ├── balance_card.dart
│               ├── balance_shimmer.dart
│               ├── error_retry_widget.dart
│               ├── transaction_list.dart
│               ├── transaction_list_shimmer.dart
│               └── transaction_tile.dart
├── injection_container.dart
└── main.dart

test/
└── features/
    └── wallet/
        ├── domain/
        │   ├── entities/
        │   └── usecases/
        ├── data/
        │   ├── models/
        │   ├── datasources/
        │   └── repositories/
        └── presentation/
            └── cubit/
```

---

## 🚀 Setup & Installation

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)

### Installation

```bash
# Clone the repository
git clone https://github.com/hverby/wallet_app.git
cd wallet_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Run on Specific Platform

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome
```

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

**Result**: ✅ **73 tests passing**

### Run Specific Test Suites

```bash
# Domain layer
flutter test test/features/wallet/domain/

# Data layer
flutter test test/features/wallet/data/

# Presentation layer
flutter test test/features/wallet/presentation/
```

### Test Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Breakdown

| Layer            | Tests  | Coverage                       |
| ---------------- | ------ | ------------------------------ |
| **Domain**       | 12     | Entities, Use Cases            |
| **Data**         | 33     | Models, DataSource, Repository |
| **Presentation** | 28     | Cubit, States, Flows           |
| **Total**        | **73** | All layers                     |

---

## 🎬 Demo Video

A 30-second video demonstration showcasing:

- ✅ Initial load with shimmer
- ✅ Balance display with hide/show
- ✅ Transaction list with pagination
- ✅ Pull-to-refresh
- ✅ Error simulation via debug menu
- ✅ Error retry flows


https://github.com/user-attachments/assets/655c2013-6b98-4166-822f-24d145d8951e


---

## 📦 Dependencies

### Production

- `flutter_bloc: ^8.1.6` - State management
- `equatable: ^2.0.5` - Value equality
- `get_it: ^7.7.0` - Dependency injection
- `dartz: ^0.10.1` - Functional programming
- `shimmer: ^3.0.0` - Loading placeholders
- `google_fonts: ^6.3.3` - Typography

### Development

- `flutter_test` - Testing framework
- `mocktail: ^1.0.4` - Mocking
- `bloc_test: ^9.1.7` - Cubit testing
- `flutter_lints: ^5.0.0` - Linting

---

## 🎯 What Was Evaluated

### ✅ Architecture

- Clean separation of concerns
- Dependency inversion
- Single responsibility principle
- Testable design

### ✅ State Management

- Proper state transitions
- Data preservation during loading
- Error state handling
- Loading state differentiation

### ✅ UI/UX

- Professional shimmer loading
- Smooth pagination
- Clear error messages
- Intuitive retry mechanisms

### ✅ Code Quality

- 73 comprehensive unit tests
- Type-safe error handling
- Reusable components
- Clean code principles

---

## 👨‍💻 Author

Built with ❤️ using Flutter and Clean Architecture principles.

---

## 📄 License

This project is for demonstration purposes.
