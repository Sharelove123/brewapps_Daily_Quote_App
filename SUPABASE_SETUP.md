# QuoteVault - Supabase Setup Guide

## 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the project to initialize (takes ~2 minutes)
3. From **Project Settings → API**, copy:
   - `Project URL` → paste into `.env` as `SUPABASE_URL`
   - `anon public` key → paste into `.env` as `SUPABASE_ANON_KEY`

---

## 2. Create Database Tables

Go to **SQL Editor** and run this script:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Categories table
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quotes table
CREATE TABLE quotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  text TEXT NOT NULL,
  author TEXT NOT NULL,
  category_id UUID REFERENCES categories(id),
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User profiles table (extends auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  notification_time TIME DEFAULT '08:00:00',
  theme TEXT DEFAULT 'system',
  accent_color TEXT DEFAULT 'purple',
  font_scale REAL DEFAULT 1.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User favorites table
CREATE TABLE user_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, quote_id)
);

-- Collections table
CREATE TABLE collections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT DEFAULT '#A855F7',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Collection quotes junction table
CREATE TABLE collection_quotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  collection_id UUID REFERENCES collections(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(collection_id, quote_id)
);

-- Daily quotes table
CREATE TABLE daily_quotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  date DATE NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_quotes_category ON quotes(category_id);
CREATE INDEX idx_quotes_featured ON quotes(is_featured);
CREATE INDEX idx_user_favorites_user ON user_favorites(user_id);
CREATE INDEX idx_collections_user ON collections(user_id);
CREATE INDEX idx_collection_quotes_collection ON collection_quotes(collection_id);
CREATE INDEX idx_daily_quotes_date ON daily_quotes(date);
```

---

## 3. Enable Row Level Security (RLS)

Run this in SQL Editor:

```sql
-- Enable RLS for all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE collection_quotes ENABLE ROW LEVEL SECURITY;

-- Quotes and categories are public read
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_quotes ENABLE ROW LEVEL SECURITY;

-- Policies for public read access
CREATE POLICY "Quotes are viewable by everyone" ON quotes FOR SELECT USING (true);
CREATE POLICY "Categories are viewable by everyone" ON categories FOR SELECT USING (true);
CREATE POLICY "Daily quotes are viewable by everyone" ON daily_quotes FOR SELECT USING (true);

-- Policies for user-specific data
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view own favorites" ON user_favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can add own favorites" ON user_favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own favorites" ON user_favorites FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own collections" ON collections FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own collections" ON collections FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own collections" ON collections FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own collections" ON collections FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own collection quotes" ON collection_quotes FOR SELECT 
  USING (EXISTS (SELECT 1 FROM collections WHERE collections.id = collection_quotes.collection_id AND collections.user_id = auth.uid()));
CREATE POLICY "Users can add to own collections" ON collection_quotes FOR INSERT 
  WITH CHECK (EXISTS (SELECT 1 FROM collections WHERE collections.id = collection_quotes.collection_id AND collections.user_id = auth.uid()));
CREATE POLICY "Users can remove from own collections" ON collection_quotes FOR DELETE 
  USING (EXISTS (SELECT 1 FROM collections WHERE collections.id = collection_quotes.collection_id AND collections.user_id = auth.uid()));
```

---

## 4. Seed Sample Data

Run this in SQL Editor:

```sql
-- Insert categories
INSERT INTO categories (name, icon) VALUES
  ('Motivation', '🔥'),
  ('Love', '❤️'),
  ('Success', '🏆'),
  ('Wisdom', '🦉'),
  ('Humor', '😄');

-- Insert sample quotes (Motivation)
INSERT INTO quotes (text, author, category_id, is_featured) VALUES
  ('The only way to do great work is to love what you do.', 'Steve Jobs', (SELECT id FROM categories WHERE name = 'Motivation'), true),
  ('Believe you can and you''re halfway there.', 'Theodore Roosevelt', (SELECT id FROM categories WHERE name = 'Motivation'), false),
  ('The future belongs to those who believe in the beauty of their dreams.', 'Eleanor Roosevelt', (SELECT id FROM categories WHERE name = 'Motivation'), true),
  ('Success is not final, failure is not fatal: it is the courage to continue that counts.', 'Winston Churchill', (SELECT id FROM categories WHERE name = 'Motivation'), true),
  ('It does not matter how slowly you go as long as you do not stop.', 'Confucius', (SELECT id FROM categories WHERE name = 'Motivation'), false);

-- Insert sample quotes (Love)
INSERT INTO quotes (text, author, category_id, is_featured) VALUES
  ('The best thing to hold onto in life is each other.', 'Audrey Hepburn', (SELECT id FROM categories WHERE name = 'Love'), true),
  ('Where there is love there is life.', 'Mahatma Gandhi', (SELECT id FROM categories WHERE name = 'Love'), false),
  ('Love all, trust a few, do wrong to none.', 'William Shakespeare', (SELECT id FROM categories WHERE name = 'Love'), true);

-- Insert sample quotes (Success)
INSERT INTO quotes (text, author, category_id, is_featured) VALUES
  ('Success is not the key to happiness. Happiness is the key to success.', 'Albert Schweitzer', (SELECT id FROM categories WHERE name = 'Success'), true),
  ('Don''t be afraid to give up the good to go for the great.', 'John D. Rockefeller', (SELECT id FROM categories WHERE name = 'Success'), false);

-- Insert sample quotes (Wisdom)
INSERT INTO quotes (text, author, category_id, is_featured) VALUES
  ('The only true wisdom is in knowing you know nothing.', 'Socrates', (SELECT id FROM categories WHERE name = 'Wisdom'), true),
  ('In the middle of difficulty lies opportunity.', 'Albert Einstein', (SELECT id FROM categories WHERE name = 'Wisdom'), false),
  ('Life is really simple, but we insist on making it complicated.', 'Confucius', (SELECT id FROM categories WHERE name = 'Wisdom'), true);

-- Insert sample quotes (Humor)
INSERT INTO quotes (text, author, category_id, is_featured) VALUES
  ('I''m not lazy, I''m on energy saving mode.', 'Anonymous', (SELECT id FROM categories WHERE name = 'Humor'), false),
  ('I used to think I was indecisive, but now I''m not so sure.', 'Anonymous', (SELECT id FROM categories WHERE name = 'Humor'), false);
```

---

## 5. Enable Authentication

1. Go to **Authentication → Providers**
2. Enable **Email** provider
3. (Optional) Configure email templates under **Email Templates**
4. (Optional) Enable other providers like Google, Apple, etc.

---

## 6. Configure .env File

Create `.env` in your project root:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

> ⚠️ **Never commit .env to git!** It's already in `.gitignore`.

---

## 7. Run the App

```bash
flutter pub get
flutter run
```

---

## Database Schema Diagram

```
┌─────────────────┐       ┌─────────────────┐
│   categories    │       │     quotes      │
├─────────────────┤       ├─────────────────┤
│ id (PK)         │◄──────│ category_id(FK) │
│ name            │       │ id (PK)         │
│ icon            │       │ text            │
│ created_at      │       │ author          │
└─────────────────┘       │ is_featured     │
                          │ created_at      │
                          └────────┬────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
        ▼                          ▼                          ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ user_favorites  │       │ collection_quotes│       │  daily_quotes   │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id (PK)         │       │ id (PK)         │       │ id (PK)         │
│ user_id (FK)    │       │ collection_id(FK)│      │ quote_id (FK)   │
│ quote_id (FK)   │       │ quote_id (FK)   │       │ date            │
│ created_at      │       │ added_at        │       │ created_at      │
└────────┬────────┘       └────────┬────────┘       └─────────────────┘
         │                         │
         │                         │
         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐
│    profiles     │       │   collections   │
├─────────────────┤       ├─────────────────┤
│ id (PK/FK)      │◄──────│ user_id (FK)    │
│ display_name    │       │ id (PK)         │
│ avatar_url      │       │ name            │
│ notification_time│      │ description     │
│ theme           │       │ color           │
│ accent_color    │       │ created_at      │
│ font_scale      │       └─────────────────┘
│ created_at      │
│ updated_at      │
└─────────────────┘
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Missing Supabase configuration" | Ensure `.env` exists with valid credentials |
| Auth not working | Check Email provider is enabled in Supabase |
| No quotes showing | Run the seed data SQL script |
| RLS blocking data | Verify policies are created correctly |
