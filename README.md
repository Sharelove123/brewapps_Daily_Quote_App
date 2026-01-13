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
    git clone https://github.com/Sharelove123/brewapps_Daily_Quote_App.git
    cd brewapps_Daily_Quote_App
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

> ![Screenshot_20260113_125951](https://github.com/user-attachments/assets/7423604a-01de-41b1-8ff1-e19e0d74a41e)
![Screenshot_20260113_125954](https://github.com/user-attachments/assets/e753cd69-cd25-44f5-a1bb-20a2190d18ca)
![Screenshot_20260113_125958](https://github.com/user-attachments/assets/45429ab4-3ddd-45f3-b58e-880c5b184e04)
![Screenshot_20260113_130031](https://github.com/user-attachments/assets/b3d78b2a-06cd-475b-821f-791892cb70d9)
![Screenshot_20260113_130034](https://github.com/user-attachments/assets/216a4734-5fda-4761-ac4f-b9eca4f4f235)
![Screenshot_20260113_130038](https://github.com/user-attachments/assets/b71cb450-dbf2-46bc-a344-bc43e769f7b3)
![Screenshot_20260113_130047](https://github.com/user-attachments/assets/b975be73-2edf-47cb-8a6f-064177fe5a5d)
![Screenshot_20260113_130303](https://github.com/user-attachments/assets/b812f991-7578-44e5-befb-9e41e6ca3b56)
![Screenshot_20260113_130306](https://github.com/user-attachments/assets/a46d76c0-684d-425a-b953-555b5f9e5fd3)
![Screenshot_20260113_130309](https://github.com/user-attachments/assets/a7846833-5faf-4eea-87cd-27860ec5046d)
![Screenshot_20260113_130326](https://github.com/user-attachments/assets/902f82f2-9c01-4a13-943e-e1d5050a75e6)
![Screenshot_20260113_130330](https://github.com/user-attachments/assets/e91f11ac-f279-4196-b966-6f212b8defb0)
![Screenshot_20260113_130334](https://github.com/user-attachments/assets/8aec81ca-9bcb-4196-aa1f-fd814e2f3f40)
![Screenshot_20260113_130337](https://github.com/user-attachments/assets/b831edc0-9526-44e7-8da4-0b6ca365093b)
![Screenshot_20260113_130340](https://github.com/user-attachments/assets/6d4d1fd1-8009-4e47-9b8e-f2c73f8b2d22)
![Screenshot_20260113_130344](https://github.com/user-attachments/assets/956c6fc3-7829-4f7e-932b-2206c38fb936)
![Screenshot_20260113_130351](https://github.com/user-attachments/assets/379ab6a3-8f63-4235-baf8-2b4e2f548241)
![Screenshot_20260113_130359](https://github.com/user-attachments/assets/7fac4cf2-1bf1-44c3-bef9-f1bb26ed2ac0)
![Screenshot_20260113_130404](https://github.com/user-attachments/assets/ec025ad0-0ab0-42d3-91fa-48081ca59195)
![Screenshot_20260113_130411](https://github.com/user-attachments/assets/2009f3d7-96d4-4058-992a-7f30a015956f)
![Screenshot_20260113_130421](https://github.com/user-attachments/assets/bb9110c2-060d-4564-9bab-17dc7c016449)
![Screenshot_20260113_130427](https://github.com/user-attachments/assets/f0c2fc05-1eb5-454c-8b33-1601032c9e33)


---

## 📄 License

This project is for **demonstration purposes** only.

---

<p align="center">
  Made with ❤️ and AI
</p>
