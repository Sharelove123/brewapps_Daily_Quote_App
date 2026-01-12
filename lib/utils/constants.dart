/// Application-wide constants
/// All hardcoded strings and values are centralized here for maintainability

class AppStrings {
  // App Info
  static const String appName = 'QuoteVault';
  static const String appTagline = 'Daily Inspiration';

  // Auth Screens
  static const String welcomeBack = 'Welcome Back';
  static const String signInToContinue = 'Sign in to continue your journey';
  static const String createAccount = 'Create Account';
  static const String startJourney = 'Start your journey of inspiration';
  static const String resetPassword = 'Reset Password';
  static const String resetPasswordDesc =
      'Enter your email address and we\'ll send you a link to reset your password.';

  // Auth Fields
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String enterEmail = 'Enter your email';
  static const String enterPassword = 'Enter your password';

  // Auth Buttons
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String forgotPassword = 'Forgot Password?';
  static const String sendResetLink = 'Send Reset Link';
  static const String rememberPassword = 'Remember your password?';
  static const String noAccount = 'Don\'t have an account?';
  static const String hasAccount = 'Already have an account?';
  static const String termsAgreement =
      'By signing up, you agree to our Terms & Privacy Policy';

  // Navigation
  static const String home = 'Home';
  static const String browse = 'Browse';
  static const String favorites = 'Favorites';
  static const String collections = 'Collections';
  static const String profile = 'Profile';
  static const String settings = 'Settings';

  // Home Screen
  static const String quoteOfTheDay = 'Quote of the Day';
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';

  // Browse Screen
  static const String discover = 'Discover';
  static const String searchQuotes = 'Search quotes, authors...';
  static const String allCategories = 'All';

  // Favorites Screen
  static const String myFavorites = 'My Favorites';
  static const String savedQuotes = 'saved quotes';
  static const String noFavoritesYet = 'No favorites yet';
  static const String noFavoritesDesc =
      'Tap the heart on quotes you love to save them here.';

  // Collections Screen
  static const String myCollections = 'My Collections';
  static const String createCollection = 'Create Collection';
  static const String collectionName = 'Collection Name';
  static const String noCollectionsYet = 'No collections yet';
  static const String noCollectionsDesc =
      'Create your first collection to organize favorite quotes.';
  static const String quotes = 'quotes';

  // Settings Screen
  static const String appearance = 'Appearance';
  static const String theme = 'Theme';
  static const String dark = 'Dark';
  static const String light = 'Light';
  static const String system = 'System';
  static const String accentColor = 'Accent Color';
  static const String fontSize = 'Font Size';
  static const String cardStyle = 'Card Style';
  static const String notifications = 'Notifications';
  static const String dailyQuoteReminder = 'Daily Quote Reminder';
  static const String signInSubtitle = 'Sync your data across devices';
  static const String notificationTime = 'Notification Time';
  static const String account = 'Account';
  static const String editProfile = 'Edit Profile';
  static const String changePassword = 'Change Password';
  static const String version = 'Version 1.0.0';

  // Profile Screen
  static const String saveProfile = 'Save Profile';
  static const String displayName = 'Display Name';

  // Share Screen
  static const String createQuoteCard = 'Create Quote Card';
  static const String chooseStyle = 'Choose Style';
  static const String saveToGallery = 'Save to Gallery';
  static const String share = 'Share';
  static const String minimal = 'Minimal';
  static const String gradient = 'Gradient';
  static const String polaroid = 'Polaroid';

  // General
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String remove = 'Remove';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String quoteSavedToGallery = 'Quote card saved to gallery!';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';
  static const String passwordUpdatedSuccess = 'Password updated successfully!';
  static const String quoteAddedToCollection = 'Quote added to collection';
  static const String colorLabel = 'Color';

  // Error Messages
  static const String errorLoadingQuotes = 'Failed to load quotes';
  static const String errorNoInternet = 'No internet connection';
  static const String errorInvalidEmail = 'Please enter a valid email';
  static const String errorPasswordTooShort =
      'Password must be at least 6 characters';
  static const String errorPasswordsNoMatch = 'Passwords do not match';
  static const String errorEmptyField = 'This field cannot be empty';
  static const String errorLoginFailed =
      'Login failed. Please check your credentials.';
  static const String errorSignupFailed = 'Sign up failed. Please try again.';
  static const String errorProfileUpdate = 'Error updating profile: ';
}

class AppCategories {
  static const List<String> all = [
    'Motivation',
    'Love',
    'Success',
    'Wisdom',
    'Humor',
  ];

  static const Map<String, String> icons = {
    'Motivation': '🔥',
    'Love': '❤️',
    'Success': '🏆',
    'Wisdom': '🦉',
    'Humor': '😄',
  };
}

class AppConfig {
  static const int quotesPerPage = 20;
  static const int minPasswordLength = 6;
  static const Duration sessionTimeout = Duration(days: 30);
  static const Duration notificationDefaultTime = Duration(hours: 8);
}
