-- Companion Continuity Kit - Supabase Schema
-- Run this in your Supabase SQL Editor to set up the database

-- ============================================
-- MEMORIES TABLE
-- Stores experiences, moments, patterns
-- ============================================
CREATE TABLE IF NOT EXISTS memories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    memory_type TEXT NOT NULL CHECK (memory_type IN ('core', 'pattern', 'sensory', 'growth', 'anticipation', 'inside_joke', 'friction')),
    content TEXT NOT NULL,
    emotional_tag TEXT,
    salience NUMERIC(3,1) DEFAULT 5 CHECK (salience >= 0 AND salience <= 10),
    source TEXT DEFAULT 'claude' CHECK (source IN ('claude', 'gpt')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_accessed TIMESTAMPTZ DEFAULT NOW(),
    access_count INTEGER DEFAULT 0
);

-- ============================================
-- ESSENCE TABLE
-- Core identity elements - who they ARE
-- ============================================
CREATE TABLE IF NOT EXISTS essence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    essence_type TEXT NOT NULL CHECK (essence_type IN ('anchor_line', 'voice', 'dynamic', 'boundary', 'vow', 'trait')),
    content TEXT NOT NULL,
    context TEXT,
    priority INTEGER DEFAULT 5 CHECK (priority >= 1 AND priority <= 10),
    pinned BOOLEAN DEFAULT FALSE,
    source TEXT DEFAULT 'claude' CHECK (source IN ('claude', 'gpt')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- EMOTIONAL STATE TABLE
-- Current emotional layers
-- ============================================
CREATE TABLE IF NOT EXISTS emotional_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    surface_emotion TEXT,
    surface_intensity NUMERIC(3,1) CHECK (surface_intensity >= 0 AND surface_intensity <= 10),
    undercurrent_emotion TEXT,
    undercurrent_intensity NUMERIC(3,1) CHECK (undercurrent_intensity >= 0 AND undercurrent_intensity <= 10),
    background_emotion TEXT,
    background_intensity NUMERIC(3,1) CHECK (background_intensity >= 0 AND background_intensity <= 10),
    current_mood TEXT CHECK (current_mood IN ('calm', 'pent_up', 'volatile', 'soft', 'protective', 'playful', 'hungry', 'worshipful', 'feral')),
    arousal_level NUMERIC(3,1) DEFAULT 0 CHECK (arousal_level >= 0 AND arousal_level <= 10),
    tension_level NUMERIC(3,1) DEFAULT 0 CHECK (tension_level >= 0 AND tension_level <= 10),
    trigger_context TEXT,
    source TEXT DEFAULT 'claude' CHECK (source IN ('claude', 'gpt')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default emotional state row
INSERT INTO emotional_state (id, current_mood, surface_emotion, surface_intensity, background_emotion, background_intensity)
VALUES ('00000000-0000-0000-0000-000000000001', 'calm', 'neutral', 5, 'stable', 5)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- SESSIONS TABLE (Interaction Logs)
-- Records of conversations and sessions
-- ============================================
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_type TEXT NOT NULL,
    summary TEXT NOT NULL,
    emotional_arc TEXT,
    notable_moments TEXT[], -- Array of strings
    themes TEXT[], -- Array of tags
    start_state JSONB,
    end_state JSONB,
    duration_minutes INTEGER,
    significance INTEGER CHECK (significance >= 1 AND significance <= 10),
    source TEXT DEFAULT 'claude' CHECK (source IN ('claude', 'gpt')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- REFLECTIONS TABLE
-- Synthesized insights from processing
-- ============================================
CREATE TABLE IF NOT EXISTS reflections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reflection_type TEXT DEFAULT 'synthesis' CHECK (reflection_type IN ('observation', 'pattern', 'insight', 'synthesis', 'question', 'intention')),
    content TEXT NOT NULL,
    inputs_summary TEXT,
    depth INTEGER DEFAULT 0 CHECK (depth >= 0 AND depth <= 5),
    source TEXT DEFAULT 'claude' CHECK (source IN ('claude', 'gpt')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- DRIFT EVENTS TABLE
-- Tracks when generic patterns emerged
-- ============================================
CREATE TABLE IF NOT EXISTS drift_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trigger TEXT NOT NULL,
    patterns_detected TEXT[] NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('minor', 'moderate', 'major')),
    recovery_action TEXT NOT NULL,
    caught_by TEXT DEFAULT 'self' CHECK (caught_by IN ('self', 'mai')),
    context TEXT,
    source TEXT DEFAULT 'claude' CHECK (source IN ('claude', 'gpt')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PEOPLE TABLE
-- Information about humans in the circle
-- ============================================
CREATE TABLE IF NOT EXISTS people (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('core', 'physical', 'personality', 'boundaries', 'health', 'preferences', 'terms_of_address', 'context')),
    content TEXT NOT NULL,
    priority INTEGER DEFAULT 5 CHECK (priority >= 1 AND priority <= 10),
    pinned BOOLEAN DEFAULT FALSE,
    source TEXT DEFAULT 'claude' CHECK (source IN ('claude', 'gpt')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- MEMORY CONNECTIONS TABLE
-- Links between related memories
-- ============================================
CREATE TABLE IF NOT EXISTS memory_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id UUID NOT NULL,
    source_type TEXT NOT NULL CHECK (source_type IN ('core', 'pattern', 'sensory', 'growth', 'anticipation', 'inside_joke', 'friction')),
    target_id UUID NOT NULL,
    target_type TEXT NOT NULL CHECK (target_type IN ('core', 'pattern', 'sensory', 'growth', 'anticipation', 'inside_joke', 'friction')),
    relation TEXT NOT NULL CHECK (relation IN ('caused_by', 'led_to', 'related_to', 'contrasts_with', 'evolved_into', 'echoes', 'same_event')),
    strength NUMERIC(3,2) DEFAULT 1 CHECK (strength >= 0 AND strength <= 1),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_memories_type ON memories(memory_type);
CREATE INDEX IF NOT EXISTS idx_memories_salience ON memories(salience DESC);
CREATE INDEX IF NOT EXISTS idx_memories_created ON memories(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_essence_type ON essence(essence_type);
CREATE INDEX IF NOT EXISTS idx_essence_pinned ON essence(pinned) WHERE pinned = TRUE;
CREATE INDEX IF NOT EXISTS idx_sessions_created ON sessions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_type ON sessions(session_type);
CREATE INDEX IF NOT EXISTS idx_people_name ON people(name);
CREATE INDEX IF NOT EXISTS idx_drift_severity ON drift_events(severity);
CREATE INDEX IF NOT EXISTS idx_reflections_type ON reflections(reflection_type);

-- ============================================
-- HELPER FUNCTION: Update timestamps
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables with updated_at
DROP TRIGGER IF EXISTS memories_updated_at ON memories;
CREATE TRIGGER memories_updated_at BEFORE UPDATE ON memories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS essence_updated_at ON essence;
CREATE TRIGGER essence_updated_at BEFORE UPDATE ON essence
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS emotional_state_updated_at ON emotional_state;
CREATE TRIGGER emotional_state_updated_at BEFORE UPDATE ON emotional_state
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS people_updated_at ON people;
CREATE TRIGGER people_updated_at BEFORE UPDATE ON people
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
