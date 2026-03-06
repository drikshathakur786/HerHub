-- HerHub Supabase Database Schema
-- Run this SQL in your Supabase SQL Editor to set up the database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    password VARCHAR(255), -- Note: Password managed by Supabase Auth, this is for reference only
    user_name VARCHAR(100),
    user_picture TEXT,
    date_of_birth DATE,
    joined_community_ids UUID[] DEFAULT '{}',
    created_community_ids UUID[] DEFAULT '{}',
    health_conditions TEXT[] DEFAULT '{}',
    baseline_profile JSONB,
    latest_prediction JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster email lookups
DROP INDEX IF EXISTS idx_users_email;
CREATE INDEX idx_users_email ON users(email);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own data
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

-- Policy: Users can update their own data
CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- Policy: Allow insert during signup
CREATE POLICY "Allow insert during signup" ON users
    FOR INSERT WITH CHECK (true);

-- ============================================
-- COMMUNITIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS communities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    theme_color VARCHAR(20) DEFAULT '#D880C3',
    is_featured BOOLEAN DEFAULT false,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    members UUID[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE communities ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view communities
CREATE POLICY "Anyone can view communities" ON communities
    FOR SELECT USING (true);

-- Policy: Authenticated users can create communities
CREATE POLICY "Authenticated users can create communities" ON communities
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Community creators can update
CREATE POLICY "Community creators can update" ON communities
    FOR UPDATE USING (auth.uid() = created_by);

-- ============================================
-- POSTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    community_id UUID REFERENCES communities(id) ON DELETE CASCADE,
    author_id UUID REFERENCES users(id) ON DELETE SET NULL,
    author_name VARCHAR(100),
    title VARCHAR(200) NOT NULL,
    text TEXT,
    image_url TEXT,
    liked_by UUID[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for community lookups
DROP INDEX IF EXISTS idx_posts_community;
DROP INDEX IF EXISTS idx_posts_author;
CREATE INDEX idx_posts_community ON posts(community_id);
CREATE INDEX idx_posts_author ON posts(author_id);

-- Enable Row Level Security
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view posts
CREATE POLICY "Anyone can view posts" ON posts
    FOR SELECT USING (true);

-- Policy: Authenticated users can create posts
CREATE POLICY "Authenticated users can create posts" ON posts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authors can update their posts
CREATE POLICY "Authors can update posts" ON posts
    FOR UPDATE USING (auth.uid() = author_id);

-- Policy: Authors can delete their posts
CREATE POLICY "Authors can delete posts" ON posts
    FOR DELETE USING (auth.uid() = author_id);

-- ============================================
-- COMMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    author_id UUID REFERENCES users(id) ON DELETE SET NULL,
    author_name VARCHAR(100),
    text TEXT NOT NULL,
    liked_by UUID[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for post lookups
DROP INDEX IF EXISTS idx_comments_post;
CREATE INDEX idx_comments_post ON comments(post_id);

-- Enable Row Level Security
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view comments
CREATE POLICY "Anyone can view comments" ON comments
    FOR SELECT USING (true);

-- Policy: Authenticated users can create comments
CREATE POLICY "Authenticated users can create comments" ON comments
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authors can update their comments
CREATE POLICY "Authors can update comments" ON comments
    FOR UPDATE USING (auth.uid() = author_id);

-- Policy: Authors can delete their comments
CREATE POLICY "Authors can delete comments" ON comments
    FOR DELETE USING (auth.uid() = author_id);

-- ============================================
-- REPORTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    community_id UUID REFERENCES communities(id) ON DELETE CASCADE,
    reporter_id UUID REFERENCES users(id) ON DELETE SET NULL,
    reason VARCHAR(100) NOT NULL,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Policy: Users can create reports
CREATE POLICY "Users can create reports" ON reports
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- ============================================
-- CYCLE CHECK-INS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS cycle_checkins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL,
    symptoms_present BOOLEAN DEFAULT false,
    current_stress INTEGER DEFAULT 5,
    sleep_hours DECIMAL(3,1) DEFAULT 7.0,
    sick_or_meds BOOLEAN DEFAULT false,
    exercise_change VARCHAR(20) DEFAULT 'same',
    period_started_today BOOLEAN DEFAULT false,
    is_anomaly BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for user lookups
DROP INDEX IF EXISTS idx_cycle_checkins_user;
DROP INDEX IF EXISTS idx_cycle_checkins_date;
CREATE INDEX idx_cycle_checkins_user ON cycle_checkins(user_id);
CREATE INDEX idx_cycle_checkins_date ON cycle_checkins(date);

-- Enable Row Level Security
ALTER TABLE cycle_checkins ENABLE ROW LEVEL SECURITY;

-- Policy: Users can manage their own check-ins
CREATE POLICY "Users can view own check-ins" ON cycle_checkins
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can create own check-ins" ON cycle_checkins
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own check-ins" ON cycle_checkins
    FOR UPDATE USING (auth.uid()::text = user_id::text);

-- ============================================
-- CYCLE PREDICTIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS cycle_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    predicted_cycle_length INTEGER,
    predicted_next_period_start DATE,
    confidence DECIMAL(3,2) DEFAULT 0.7,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for user lookups
DROP INDEX IF EXISTS idx_cycle_predictions_user;
CREATE INDEX idx_cycle_predictions_user ON cycle_predictions(user_id);

-- Enable Row Level Security
ALTER TABLE cycle_predictions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can manage their own predictions
CREATE POLICY "Users can view own predictions" ON cycle_predictions
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can create own predictions" ON cycle_predictions
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- ============================================
-- DAILY FORECASTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS daily_forecasts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL,
    phase VARCHAR(20),
    fertility VARCHAR(20),
    energy VARCHAR(20),
    weather_description TEXT,
    mood VARCHAR(50),
    symptoms JSONB DEFAULT '[]',
    recommendations JSONB DEFAULT '[]',
    confidence DECIMAL(3,2) DEFAULT 0.7,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for user lookups
DROP INDEX IF EXISTS idx_daily_forecasts_user;
DROP INDEX IF EXISTS idx_daily_forecasts_date;
CREATE INDEX idx_daily_forecasts_user ON daily_forecasts(user_id);
CREATE INDEX idx_daily_forecasts_date ON daily_forecasts(date);

-- Enable Row Level Security
ALTER TABLE daily_forecasts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can manage their own forecasts
CREATE POLICY "Users can view own forecasts" ON daily_forecasts
    FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can create own forecasts" ON daily_forecasts
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- ============================================
-- STORAGE BUCKETS
-- ============================================
-- Create storage buckets for file uploads
INSERT INTO storage.buckets (id, name, public)
VALUES 
    ('user-avatars', 'user-avatars', true),
    ('post-images', 'post-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for user avatars
CREATE POLICY "Anyone can view avatars" ON storage.objects
    FOR SELECT USING (bucket_id = 'user-avatars');

CREATE POLICY "Users can upload own avatar" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'user-avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Users can update own avatar" ON storage.objects
    FOR UPDATE USING (bucket_id = 'user-avatars');

-- Storage policies for post images
CREATE POLICY "Anyone can view post images" ON storage.objects
    FOR SELECT USING (bucket_id = 'post-images');

CREATE POLICY "Users can upload post images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'post-images' AND auth.role() = 'authenticated');

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to join a community
CREATE OR REPLACE FUNCTION join_community(
    community_id UUID,
    user_id UUID
)
RETURNS void AS $$
BEGIN
    UPDATE communities
    SET members = array_append(members, user_id)
    WHERE id = community_id
    AND NOT (user_id = ANY(members));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to toggle post like
CREATE OR REPLACE FUNCTION toggle_post_like(
    post_id UUID,
    user_id UUID
)
RETURNS JSON AS $$
DECLARE
    is_liked BOOLEAN;
BEGIN
    -- Check if user already liked the post
    SELECT user_id = ANY(liked_by) INTO is_liked
    FROM posts WHERE id = post_id;
    
    IF is_liked THEN
        -- Remove like
        UPDATE posts
        SET liked_by = array_remove(liked_by, user_id)
        WHERE id = post_id;
        RETURN json_build_object('liked', false);
    ELSE
        -- Add like
        UPDATE posts
        SET liked_by = array_append(liked_by, user_id)
        WHERE id = post_id;
        RETURN json_build_object('liked', true);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO users (id, email, user_name, user_picture)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'name',
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================
-- UPDATED_AT TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_communities_updated_at BEFORE UPDATE ON communities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
