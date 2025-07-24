-- Migration: Add created_at and updated_at columns to blocks table
ALTER TABLE blocks ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE blocks ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP;
-- If you want to backfill existing rows, you can run an UPDATE after this migration.
