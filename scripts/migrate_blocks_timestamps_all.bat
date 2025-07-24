@echo off
REM Find and migrate all SQLite DBs in the workspace for blocks timestamps
set MIGRATION="%~dp0migrations\20250626_add_timestamps_to_blocks.sql"
for /r "%~dp0.." %%F in (*.db *.sqlite *.sqlite3 *.data) do (
  echo Migrating %%F ...
  sqlite3 "%%F" ".read %MIGRATION%"
)
echo Migration complete. If no DBs were found, run this script again after your app creates the database.
