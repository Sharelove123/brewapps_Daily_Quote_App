# QuoteVault

QuoteVault is a beautiful, feature-rich Flutter application designed to inspire users with daily quotes, organized collections, and customizable sharing options. It features a modern, adaptive UI with dark/light mode support, user authentication, and cloud sync via Supabase.

## Features

*   **Authentication**: Secure Sign Up, Login, and Password Reset (Supabase Auth).
*   **Daily Inspiration**: "Quote of the Day" with notifications.
*   **Browse & Discovery**: Search quotes by text or author, and browse by categories (Motivation, Love, Wisdom, etc.).
*   **Collections**: Organize favorite quotes into custom collections.
*   **Favorites**: Quickly save quotes to your favorites list.
*   **Personalization**: 
    *   Dark/Light/System theme modes.
    *   Customizable accent colors.
    *   Adjustable font sizes.
    *   Multiple card styles (Modern, Minimal, Polaroid).
*   **Sharing**: Create beautiful shareable quote cards for social media.
*   **Widget**: Home screen widget for quick access to daily inspiration.

## Tech Stack

*   **Framework**: Flutter (Dart)
*   **State Management**: Riverpod
*   **Backend**: Supabase (PostgreSQL, Auth, Storage)
*   **Architecture**: MVVM / Clean Architecture-inspired separation of concerns.

## Project Structure

```
lib/
├── config/         # App configuration (Supabase, etc.)
├── models/         # Data models (Quote, UserProfile, etc.)
├── providers/      # Riverpod providers for state management
├── screens/        # UI Screens (Auth, Home, Settings, etc.)
├── services/       # Service layer (API calls, Storage, Auth)
├── utils/          # Utilities, Constants, Theme
├── widgets/        # Reusable UI components
└── main.dart       # Entry point
```

## Setup Instructions

### Prerequisites
*   Flutter SDK (Latest Stable)
*   Supabase Account

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/quotevault.git
    cd quotevault
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Supabase:**
    *   Create a new Supabase project.
    *   Run the SQL scripts provided in `SUPABASE_SETUP.md` to set up tables and security policies.
    *   (Optional) Run the content of `seed_large_dataset.sql` in the SQL Editor to populate the database with over 100 quotes.
    *   Create a `.env` file in the root directory (copy from `.env.example`):
        ```env
        SUPABASE_URL=your_supabase_url
        SUPABASE_ANON_KEY=your_supabase_anon_key
        ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)