# TaskMe Blueprint

## App Overview

TaskMe is a modern productivity app built with Flutter and Supabase that combines task management with gamification elements. This blueprint provides detailed specifications for rebuilding the entire application.

## Tech Stack & Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.10.25
  flutter_riverpod: ^2.4.9
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  go_router: ^13.0.1
  flutter_hooks: ^0.20.3
  hooks_riverpod: ^2.4.9
  cached_network_image: ^3.3.0
  flutter_secure_storage: ^9.0.0
  logger: ^2.0.2+1
  intl: ^0.18.1
  uuid: ^4.2.2
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  custom_lint: ^0.5.7
  riverpod_lint: ^2.3.7
  flutter_lints: ^2.0.0
```

## Architecture

### Directory Structure

```
lib/
├── config/
│   ├── app_config.dart        # Environment configuration
│   ├── theme_config.dart      # App theming
│   └── route_config.dart      # Navigation routes
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── app_error.dart
│   │   └── error_handler.dart
│   └── utils/
│       ├── logger.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_state.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── task_repository.dart
│   │   │   └── task_state.dart
│   │   ├── models/
│   │   │   └── task.dart
│   │   ├── providers/
│   │   │   └── task_provider.dart
│   │   └── presentation/
│   │       ├── task_list_screen.dart
│   │       └── task_detail_screen.dart
│   └── profile/
│       ├── data/
│       │   ├── profile_repository.dart
│       │   └── profile_state.dart
│       ├── models/
│       │   └── profile.dart
│       ├── providers/
│       │   └── profile_provider.dart
│       └── presentation/
│           └── profile_screen.dart
├── shared/
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── app_text_field.dart
│   │   └── loading_indicator.dart
│   └── extensions/
│       ├── context_extensions.dart
│       └── string_extensions.dart
└── main.dart
```

## Data Models

### Task Model
```dart
@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required String description,
    required TaskStatus status,
    required DateTime dueDate,
    required int priority,
    required String userId,
    required DateTime createdAt,
    DateTime? completedAt,
    @Default(false) bool isDeleted,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

enum TaskStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed
}
```

### User Profile Model
```dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    required String username,
    String? avatarUrl,
    @Default(1) int level,
    @Default(0) int xp,
    @Default(0) int totalTasksCompleted,
    required DateTime createdAt,
    DateTime? lastLoginAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => 
    _$UserProfileFromJson(json);
}
```

## Database Schema

### Profiles Table
```sql
create table public.profiles (
  id uuid references auth.users primary key,
  email text not null,
  username text unique,
  avatar_url text,
  level int default 1,
  xp int default 0,
  total_tasks_completed int default 0,
  created_at timestamptz default now(),
  last_login_at timestamptz,
  updated_at timestamptz default now()
);

-- RLS Policies
alter table public.profiles enable row level security;

create policy "Users can view their own profile"
  on public.profiles for select
  using ( auth.uid() = id );

create policy "Users can update their own profile"
  on public.profiles for update
  using ( auth.uid() = id );
```

### Tasks Table
```sql
create table public.tasks (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  description text,
  status text default 'not_started',
  due_date timestamptz,
  priority int default 1,
  user_id uuid references auth.users not null,
  created_at timestamptz default now(),
  completed_at timestamptz,
  is_deleted boolean default false,
  updated_at timestamptz default now()
);

-- RLS Policies
alter table public.tasks enable row level security;

create policy "Users can CRUD their own tasks"
  on public.tasks
  using ( auth.uid() = user_id );
```

## Feature Implementation

### Authentication
```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final SupabaseClient _supabase;
  
  @override
  FutureOr<AuthState> build() {
    _supabase = ref.watch(supabaseClientProvider);
    return _checkAuthState();
  }

  Future<AuthState> _checkAuthState() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return const AuthState.unauthenticated();
    
    try {
      final profile = await _fetchUserProfile(session.user.id);
      return AuthState.authenticated(profile);
    } catch (e, st) {
      ref.read(loggerProvider).error('Error fetching profile', e, st);
      return const AuthState.error('Failed to load profile');
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = await AsyncValue.guard(() => _checkAuthState());
    } catch (e, st) {
      ref.read(loggerProvider).error('Sign in error', e, st);
      state = AsyncValue.error('Authentication failed', st);
    }
  }
}
```

### Task Management
```dart
@riverpod
class TaskNotifier extends _$TaskNotifier {
  late final TaskRepository _repository;
  
  @override
  FutureOr<List<Task>> build() {
    _repository = ref.watch(taskRepositoryProvider);
    return _fetchTasks();
  }

  Future<List<Task>> _fetchTasks() async {
    final tasks = await _repository.getTasks();
    return tasks.where((task) => !task.isDeleted).toList();
  }

  Future<void> createTask(Task task) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createTask(task);
      state = await AsyncValue.guard(() => _fetchTasks());
    } catch (e, st) {
      state = AsyncValue.error('Failed to create task', st);
    }
  }
}
```

### UI Components

#### Custom Button
```dart
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
  });

  final VoidCallback onPressed;
  final String label;
  final bool isLoading;
  final ButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: _getButtonStyle(context),
      child: isLoading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
```

## State Management

### Provider Setup
```dart
@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authNotifierProvider);
  
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      // ... other routes
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final isOnAuthPage = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isOnAuthPage) return '/auth/login';
      if (isAuthenticated && isOnAuthPage) return '/';
      return null;
    },
  );
}
```

## Error Handling

### Error Types
```dart
@freezed
class AppError with _$AppError {
  const factory AppError.network([String? message]) = NetworkError;
  const factory AppError.authentication([String? message]) = AuthenticationError;
  const factory AppError.validation([String? message]) = ValidationError;
  const factory AppError.unexpected([String? message]) = UnexpectedError;
}
```

### Error Handler
```dart
class ErrorHandler {
  static String getMessage(AppError error) {
    return error.when(
      network: (message) => 
        message ?? 'Network error occurred. Please check your connection.',
      authentication: (message) => 
        message ?? 'Authentication error. Please sign in again.',
      validation: (message) => 
        message ?? 'Please check your input and try again.',
      unexpected: (message) => 
        message ?? 'An unexpected error occurred. Please try again.',
    );
  }

  static void showError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SelectableText.rich(
          TextSpan(
            text: getMessage(error),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

## Theme Configuration
```dart
final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.light,
  ),
  // ... other theme configurations
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.dark,
  ),
  // ... other theme configurations
);
```

## Environment Configuration
```dart
@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String apiUrl,
    required bool enableAnalytics,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) => 
    _$AppConfigFromJson(json);
}

final appConfigProvider = Provider<AppConfig>((ref) {
  const environment = String.fromEnvironment('ENVIRONMENT', 
    defaultValue: 'development');
    
  switch (environment) {
    case 'production':
      return const AppConfig(
        supabaseUrl: 'PRODUCTION_URL',
        supabaseAnonKey: 'PRODUCTION_KEY',
        apiUrl: 'PRODUCTION_API',
        enableAnalytics: true,
      );
    default:
      return const AppConfig(
        supabaseUrl: 'DEVELOPMENT_URL',
        supabaseAnonKey: 'DEVELOPMENT_KEY',
        apiUrl: 'DEVELOPMENT_API',
        enableAnalytics: false,
      );
  }
});
```

## Testing Strategy

### Unit Tests
```dart
void main() {
  group('TaskNotifier Tests', () {
    late ProviderContainer container;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    test('initial state should be loading', () {
      final taskNotifier = container.read(taskNotifierProvider);
      expect(taskNotifier, const AsyncValue<List<Task>>.loading());
    });

    // ... more tests
  });
}
```

## Build & Deploy

### Build Configuration
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/config/

  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

## Security Considerations

1. **API Security**
   - Use environment variables for sensitive data
   - Implement request rate limiting
   - Use HTTPS for all network requests

2. **Data Security**
   - Implement proper RLS policies in Supabase
   - Encrypt sensitive data before storage
   - Regular security audits

3. **Authentication Security**
   - Implement proper session management
   - Use secure storage for tokens
   - Implement proper password policies

## Performance Optimization

1. **State Management**
   - Use proper caching strategies
   - Implement pagination for lists
   - Optimize rebuilds with proper provider scoping

2. **Image Optimization**
   - Use proper image caching
   - Implement lazy loading
   - Optimize image assets

3. **Database Optimization**
   - Implement proper indexing
   - Use efficient queries
   - Implement proper caching strategies

## Deployment Checklist

1. **Pre-deployment**
   - Run all tests
   - Check for lint issues
   - Update version numbers

2. **Deployment**
   - Update environment variables
   - Deploy database migrations
   - Deploy app to stores

3. **Post-deployment**
   - Monitor for crashes
   - Check analytics
   - Monitor performance metrics

This blueprint provides a comprehensive guide for rebuilding the TaskMe application. Follow the directory structure, implement the features as described, and ensure all security and performance considerations are addressed. 