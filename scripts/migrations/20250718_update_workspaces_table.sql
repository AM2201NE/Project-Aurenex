-- Migration: Add missing columns to workspaces table for Workspace model
ALTER TABLE workspaces ADD COLUMN id TEXT;
ALTER TABLE workspaces ADD COLUMN name TEXT;
ALTER TABLE workspaces ADD COLUMN description TEXT;
ALTER TABLE workspaces ADD COLUMN createdAt INTEGER;
ALTER TABLE workspaces ADD COLUMN updatedAt INTEGER;
ALTER TABLE workspaces ADD COLUMN pages TEXT;
ALTER TABLE workspaces ADD COLUMN pageOrder TEXT;
ALTER TABLE workspaces ADD COLUMN settings TEXT;
