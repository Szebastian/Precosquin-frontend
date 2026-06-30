-- Precosquin - Initial Schema
-- Run this migration to set up the database

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =====================================================
-- PROFILES (extends Supabase Auth)
-- =====================================================
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN ('admin', 'organizador', 'staff', 'jurado')),
    organization_id UUID,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    permissions JSONB DEFAULT '[]',
    preferences JSONB DEFAULT '{}',
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- =====================================================
-- ORGANIZATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE profiles ADD CONSTRAINT fk_profiles_organization
    FOREIGN KEY (organization_id) REFERENCES organizations(id);

-- =====================================================
-- CATEGORIES & SUBCATEGORIES
-- =====================================================
CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('MUSICA', 'DANZA')),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS subcategories (
    id TEXT PRIMARY KEY,
    category_id TEXT NOT NULL REFERENCES categories(id),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Seed categories
INSERT INTO categories (id, name, type) VALUES
    ('musica', 'Música', 'MUSICA'),
    ('danza', 'Danza', 'DANZA');

INSERT INTO subcategories (id, category_id, name, description) VALUES
    ('solista_vocal', 'musica', 'Solista Vocal', 'Artista solista vocal'),
    ('solista_instrumental', 'musica', 'Solista Instrumental', 'Artista solista instrumental'),
    ('conjunto_instrumental', 'musica', 'Conjunto Instrumental', 'Grupo instrumental'),
    ('conjunto_vocal', 'musica', 'Conjunto Vocal', 'Grupo vocal'),
    ('tema_inedito', 'musica', 'Tema Inédito', 'Obra inédita original'),
    ('malambo_masculino', 'danza', 'Solista de Malambo Masculino', 'Malambo solista masculino'),
    ('malambo_femenino', 'danza', 'Solista de Malambo Femenino', 'Malambo solista femenino'),
    ('pareja_tradicional', 'danza', 'Pareja Tradicional', 'Pareja de baile tradicional'),
    ('pareja_estilizada', 'danza', 'Pareja Estilizada', 'Pareja de baile estilizada'),
    ('conjunto_malambo', 'danza', 'Conjunto de Malambo', 'Grupo de malambo'),
    ('conjunto_baile_folklorico', 'danza', 'Conjunto de Baile Folklórico', 'Grupo de baile folklórico');

-- =====================================================
-- INSCRIPTIONS (Artists submit forms, no login)
-- =====================================================
CREATE TABLE IF NOT EXISTS inscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    full_name TEXT NOT NULL,
    stage_name TEXT,
    dni TEXT,
    category TEXT NOT NULL REFERENCES categories(id),
    subcategory TEXT NOT NULL REFERENCES subcategories(id),
    province TEXT,
    city TEXT,
    experience_years INTEGER,
    bio TEXT,
    website TEXT,
    instagram TEXT,
    youtube TEXT,
    spotify TEXT,
    status TEXT NOT NULL DEFAULT 'PENDIENTE' CHECK (status IN ('PENDIENTE', 'EN_REVISION', 'APROBADA', 'RECHAZADA', 'CONTRATO_FIRMADO')),
    rejection_reason TEXT,
    internal_notes TEXT,
    staff_observations TEXT,
    assigned_jury UUID[],
    updated_by UUID,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_inscriptions_email ON inscriptions(email);
CREATE INDEX idx_inscriptions_status ON inscriptions(status);
CREATE INDEX idx_inscriptions_category ON inscriptions(category, subcategory);

-- =====================================================
-- INSCRIPTION AUDIT LOG
-- =====================================================
CREATE TABLE IF NOT EXISTS inscription_audit (
    id BIGSERIAL PRIMARY KEY,
    inscription_id UUID NOT NULL REFERENCES inscriptions(id),
    action TEXT NOT NULL,
    from_status TEXT,
    to_status TEXT,
    reason TEXT,
    user_id UUID,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_inscription_audit_inscription ON inscription_audit(inscription_id, created_at DESC);

-- =====================================================
-- DOCUMENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID NOT NULL REFERENCES inscriptions(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('dni', 'cv', 'rider', 'audio', 'video', 'medical', 'other')),
    filename TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    size_bytes BIGINT,
    status TEXT DEFAULT 'uploaded',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_documents_artist ON documents(artist_id);

-- =====================================================
-- RUBRICS (Música & Danza)
-- =====================================================
CREATE TABLE IF NOT EXISTS rubrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subcategory_id TEXT NOT NULL REFERENCES subcategories(id),
    name TEXT NOT NULL,
    criteria JSONB NOT NULL DEFAULT '[]',
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Seed rubrics for Música
INSERT INTO rubrics (subcategory_id, name, criteria) VALUES
    ('solista_vocal', 'Rúbrica Solista Vocal Música', '[
        {"id": "tecnica", "name": "Técnica Vocal", "weight": 30, "scale_min": 1, "scale_max": 10},
        {"id": "originalidad", "name": "Originalidad", "weight": 20, "scale_min": 1, "scale_max": 10},
        {"id": "arreglos", "name": "Arreglos", "weight": 25, "scale_min": 1, "scale_max": 10},
        {"id": "puesta_escena", "name": "Puesta en Escena", "weight": 25, "scale_min": 1, "scale_max": 10}
    ]'),
    ('solista_instrumental', 'Rúbrica Solista Instrumental Música', '[
        {"id": "tecnica", "name": "Técnica Instrumental", "weight": 30, "scale_min": 1, "scale_max": 10},
        {"id": "originalidad", "name": "Originalidad", "weight": 20, "scale_min": 1, "scale_max": 10},
        {"id": "arreglos", "name": "Arreglos", "weight": 25, "scale_min": 1, "scale_max": 10},
        {"id": "puesta_escena", "name": "Puesta en Escena", "weight": 25, "scale_min": 1, "scale_max": 10}
    ]');

-- Seed rubrics for Danza
INSERT INTO rubrics (subcategory_id, name, criteria) VALUES
    ('malambo_masculino', 'Rúbrica Malambo Masculino', '[
        {"id": "tecnica", "name": "Técnica", "weight": 25, "scale_min": 1, "scale_max": 10},
        {"id": "coreografia", "name": "Coreografía", "weight": 20, "scale_min": 1, "scale_max": 10},
        {"id": "vestuario", "name": "Vestuario", "weight": 15, "scale_min": 1, "scale_max": 10},
        {"id": "expresion_escenica", "name": "Expresión Escénica", "weight": 20, "scale_min": 1, "scale_max": 10},
        {"id": "autenticidad", "name": "Autenticidad Folklórica", "weight": 20, "scale_min": 1, "scale_max": 10}
    ]');

-- =====================================================
-- JURY ASSIGNMENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS jury_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    jury_id UUID NOT NULL REFERENCES profiles(id),
    artist_id UUID NOT NULL REFERENCES inscriptions(id),
    subcategory_id TEXT NOT NULL REFERENCES subcategories(id),
    round_number INTEGER DEFAULT 1,
    status TEXT DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'DECLINED', 'COMPLETED')),
    assigned_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(jury_id, artist_id, round_number)
);

-- =====================================================
-- EVALUATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID NOT NULL REFERENCES jury_assignments(id),
    jury_id UUID NOT NULL REFERENCES profiles(id),
    artist_id UUID NOT NULL REFERENCES inscriptions(id),
    rubric_id UUID NOT NULL REFERENCES rubrics(id),
    round_number INTEGER DEFAULT 1,
    scores JSONB DEFAULT '{}',
    comments JSONB DEFAULT '{}',
    total_score DECIMAL(5,2),
    status TEXT DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'IN_PROGRESS', 'SUBMITTED')),
    started_at TIMESTAMPTZ DEFAULT now(),
    submitted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- =====================================================
-- SCHEDULE
-- =====================================================
CREATE TABLE IF NOT EXISTS venues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    capacity INTEGER,
    technical_specs JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS schedule_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID NOT NULL REFERENCES inscriptions(id),
    venue_id UUID NOT NULL REFERENCES venues(id),
    slot_type TEXT NOT NULL CHECK (slot_type IN ('soundcheck', 'show', 'load_in', 'load_out')),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'confirmed', 'notified', 'cancelled')),
    notes TEXT,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_schedule_slots_venue ON schedule_slots(venue_id, start_time);
CREATE INDEX idx_schedule_slots_artist ON schedule_slots(artist_id);

-- =====================================================
-- NOTIFICATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS communication_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    channel TEXT NOT NULL CHECK (channel IN ('email', 'whatsapp')),
    subject TEXT,
    body TEXT NOT NULL,
    variables JSONB DEFAULT '[]',
    status TEXT DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'ACTIVE', 'ARCHIVED')),
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS communications_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID REFERENCES inscriptions(id),
    sender_id UUID REFERENCES profiles(id),
    channel TEXT NOT NULL CHECK (channel IN ('email', 'whatsapp')),
    template_id UUID REFERENCES communication_templates(id),
    subject TEXT,
    body TEXT,
    variables JSONB DEFAULT '{}',
    status TEXT DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SENT', 'DELIVERED', 'READ', 'FAILED', 'BLOCKED_OPT_OUT')),
    provider_message_id TEXT,
    error_message TEXT,
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- =====================================================
-- CONTRACTS
-- =====================================================
CREATE TABLE IF NOT EXISTS contract_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    html_template TEXT NOT NULL,
    required_fields JSONB DEFAULT '[]',
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS artist_contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID NOT NULL REFERENCES inscriptions(id),
    template_id UUID NOT NULL REFERENCES contract_templates(id),
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'signed', 'rejected', 'expired')),
    original_path TEXT,
    signed_path TEXT,
    token_hash TEXT,
    token_expires_at TIMESTAMPTZ,
    signed_at TIMESTAMPTZ,
    signed_by_ip INET,
    rejection_reason TEXT,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- =====================================================
-- STAFF CHECKLIST
-- =====================================================
CREATE TABLE IF NOT EXISTS checklist_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category TEXT NOT NULL CHECK (category IN ('rider', 'hospitality', 'transport', 'credentials')),
    title TEXT NOT NULL,
    description TEXT,
    default_order INTEGER,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS artist_checklist_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID NOT NULL REFERENCES inscriptions(id),
    template_id UUID REFERENCES checklist_templates(id),
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'blocked')),
    order_index INTEGER,
    completed_by UUID REFERENCES profiles(id),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_checklist_tasks_artist ON artist_checklist_tasks(artist_id, status);

-- =====================================================
-- INCIDENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID REFERENCES inscriptions(id),
    task_id UUID REFERENCES artist_checklist_tasks(id),
    reported_by UUID NOT NULL REFERENCES profiles(id),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    assigned_to UUID REFERENCES profiles(id),
    resolved_by UUID REFERENCES profiles(id),
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- =====================================================
-- CAPACITIES
-- =====================================================
CREATE TABLE IF NOT EXISTS edition_capacities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subcategory_id TEXT NOT NULL REFERENCES subcategories(id),
    max_capacity INTEGER NOT NULL,
    current_approved INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT now(),
    updated_by UUID REFERENCES profiles(id),
    UNIQUE(subcategory_id)
);

-- =====================================================
-- EVENT CONFIG
-- =====================================================
CREATE TABLE IF NOT EXISTS event_config (
    id INTEGER PRIMARY KEY DEFAULT 1,
    fecha_inicio DATE,
    fecha_fin DATE,
    cupos JSONB DEFAULT '{}',
    reglas JSONB DEFAULT '{}',
    inscription_open BOOLEAN DEFAULT false,
    updated_at TIMESTAMPTZ DEFAULT now(),
    CHECK (id = 1)
);

-- =====================================================
-- AUDIT LOGS
-- =====================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    actor_id UUID REFERENCES profiles(id),
    action TEXT NOT NULL,
    target_type TEXT,
    target_id UUID,
    metadata JSONB DEFAULT '{}',
    ip INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id, created_at DESC);
CREATE INDEX idx_audit_logs_action ON audit_logs(action, created_at DESC);

-- =====================================================
-- ANALYTICS EVENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type TEXT NOT NULL CHECK (event_type IN (
        'jury_profile_view', 'organizer_profile_view',
        'rider_download', 'contract_sent', 'contract_viewed', 'contract_signed'
    )),
    entity_id UUID NOT NULL,
    entity_type TEXT NOT NULL,
    categoria TEXT NOT NULL,
    subcategoria TEXT,
    user_id UUID REFERENCES profiles(id),
    session_id TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_analytics_events_cat_date ON analytics_events(categoria, created_at DESC);
CREATE INDEX idx_analytics_events_entity ON analytics_events(entity_type, entity_id);

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE inscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE jury_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedule_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE communications_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE artist_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Profiles: users see their own profile
CREATE POLICY "Users see own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Inscriptions: staff/org see all, public can insert
CREATE POLICY "Staff can view inscriptions" ON inscriptions
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'organizador', 'staff', 'jurado'))
    );

CREATE POLICY "Anyone can submit inscriptions" ON inscriptions
    FOR INSERT WITH CHECK (true);

-- Documents: staff see all
CREATE POLICY "Staff can view documents" ON documents
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'organizador', 'staff'))
    );

-- Jury assignments: jurors see their own
CREATE POLICY "Jurors see own assignments" ON jury_assignments
    FOR SELECT USING (auth.uid() = jury_id);

-- Evaluations: jurors see their own
CREATE POLICY "Jurors see own evaluations" ON evaluations
    FOR SELECT USING (auth.uid() = jury_id);

-- Audit logs: only admins
CREATE POLICY "Admins can view audit logs" ON audit_logs
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inscriptions_updated_at BEFORE UPDATE ON inscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedule_slots_updated_at BEFORE UPDATE ON schedule_slots
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_communication_templates_updated_at BEFORE UPDATE ON communication_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_artist_contracts_updated_at BEFORE UPDATE ON artist_contracts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_artist_checklist_tasks_updated_at BEFORE UPDATE ON artist_checklist_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_incidents_updated_at BEFORE UPDATE ON incidents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();