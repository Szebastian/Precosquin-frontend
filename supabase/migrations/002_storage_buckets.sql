-- Precosquin - Storage Buckets
-- Run this after the initial schema

-- =====================================================
-- STORAGE BUCKETS
-- =====================================================

-- Inscriptions bucket (for artist documents)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'inscriptions',
    'inscriptions',
    false,
    52428800, -- 50MB
    ARRAY[
        'application/pdf',
        'image/jpeg',
        'image/png',
        'video/mp4',
        'audio/mpeg',
        'audio/wav'
    ]
);

-- Public bucket for public assets
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES (
    'public',
    'public',
    true,
    10485760 -- 10MB
);

-- =====================================================
-- STORAGE POLICIES
-- =====================================================

-- Inscriptions: staff can upload, artists can read their own
CREATE POLICY "Staff can upload to inscriptions"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'inscriptions' AND
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'organizador', 'staff'))
);

CREATE POLICY "Staff can view inscriptions files"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'inscriptions' AND
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'organizador', 'staff'))
);

CREATE POLICY "Staff can delete inscriptions files"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'inscriptions' AND
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'organizador', 'staff'))
);

-- Public bucket: anyone can read, staff can upload
CREATE POLICY "Anyone can view public files"
ON storage.objects FOR SELECT
USING (bucket_id = 'public');

CREATE POLICY "Staff can upload to public"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'public' AND
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'organizador', 'staff'))
);

-- =====================================================
-- FOLDERS STRUCTURE
-- =====================================================
-- Note: Folders are created implicitly when files are uploaded
-- Expected structure:
-- inscriptions/
--   {inscription_id}/
--     dni/
--     cv/
--     rider/
--     audio/
--     video/
--     medical/
--     other/