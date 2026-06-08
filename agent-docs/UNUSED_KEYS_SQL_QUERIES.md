# SQL Queries for Translation Key Usage Analysis

This document provides SQL queries for analyzing translation key usage directly in the database.

## Basic Usage Queries

### Count of Keys by Status

```sql
SELECT
  CASE
    WHEN verified_at IS NULL THEN 'Never Used'
    WHEN verified_at < NOW() - INTERVAL '180 days' THEN 'Unused (180+ days)'
    WHEN verified_at < NOW() - INTERVAL '90 days' THEN 'Unused (90-180 days)'
    WHEN verified_at < NOW() - INTERVAL '30 days' THEN 'Rarely Used (30-90 days)'
    ELSE 'Active (< 30 days)'
  END AS usage_status,
  COUNT(*) as key_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage
FROM tr8n_translation_keys
GROUP BY usage_status
ORDER BY key_count DESC;
```

### Top 100 Oldest Unused Keys

```sql
SELECT
  id,
  label,
  description,
  verified_at,
  created_at,
  CASE
    WHEN verified_at IS NULL THEN 'Never'
    ELSE EXTRACT(DAY FROM NOW() - verified_at)::text || ' days ago'
  END as last_used
FROM tr8n_translation_keys
WHERE verified_at IS NULL
   OR verified_at < NOW() - INTERVAL '90 days'
ORDER BY verified_at ASC NULLS FIRST
LIMIT 100;
```

### Keys Never Verified (Potentially Never Used)

```sql
SELECT
  COUNT(*) as never_verified_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM tr8n_translation_keys), 2) as percentage
FROM tr8n_translation_keys
WHERE verified_at IS NULL;
```

## Usage Trends

### Keys Verified by Date Range (Last 30 Days)

```sql
SELECT
  DATE(verified_at) as verification_date,
  COUNT(*) as keys_accessed
FROM tr8n_translation_keys
WHERE verified_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(verified_at)
ORDER BY verification_date DESC;
```

### Activity Distribution

```sql
SELECT
  DATE_TRUNC('month', verified_at) as month,
  COUNT(*) as keys_accessed
FROM tr8n_translation_keys
WHERE verified_at IS NOT NULL
GROUP BY DATE_TRUNC('month', verified_at)
ORDER BY month DESC
LIMIT 12;
```

## Detailed Analysis

### Unused Keys with Translation Counts

```sql
SELECT
  tk.id,
  tk.label,
  tk.description,
  tk.verified_at,
  tk.translation_count,
  COUNT(t.id) as actual_translation_count
FROM tr8n_translation_keys tk
LEFT JOIN tr8n_translations t ON tk.id = t.translation_key_id
WHERE tk.verified_at IS NULL
   OR tk.verified_at < NOW() - INTERVAL '180 days'
GROUP BY tk.id, tk.label, tk.description, tk.verified_at, tk.translation_count
ORDER BY actual_translation_count DESC, tk.verified_at ASC NULLS FIRST
LIMIT 50;
```

This shows unused keys that have translations - these represent wasted translation effort.

### Unused Keys by Source/Domain

```sql
SELECT
  ts.source,
  COUNT(DISTINCT tk.id) as unused_key_count
FROM tr8n_translation_keys tk
JOIN tr8n_translation_key_sources tks ON tk.id = tks.translation_key_id
JOIN tr8n_translation_sources ts ON tks.translation_source_id = ts.id
WHERE tk.verified_at IS NULL
   OR tk.verified_at < NOW() - INTERVAL '180 days'
GROUP BY ts.source
ORDER BY unused_key_count DESC
LIMIT 20;
```

Helps identify which parts of your application have the most unused keys.

### Keys with Admin Flag (High Priority)

```sql
SELECT
  id,
  label,
  description,
  verified_at,
  admin
FROM tr8n_translation_keys
WHERE admin = true
  AND (verified_at IS NULL OR verified_at < NOW() - INTERVAL '180 days')
ORDER BY verified_at ASC NULLS FIRST;
```

Admin-flagged keys that are unused might indicate removed admin features.

## Cleanup Preparation

### Estimate Impact of Deletion

```sql
-- Count of records that would be affected by deletion
SELECT
  'Translation Keys' as table_name,
  COUNT(*) as records_to_delete
FROM tr8n_translation_keys
WHERE verified_at IS NULL OR verified_at < '2025-01-01'

UNION ALL

SELECT
  'Translations',
  COUNT(*)
FROM tr8n_translations
WHERE translation_key_id IN (
  SELECT id FROM tr8n_translation_keys
  WHERE verified_at IS NULL OR verified_at < '2025-01-01'
)

UNION ALL

SELECT
  'Translation Key Sources',
  COUNT(*)
FROM tr8n_translation_key_sources
WHERE translation_key_id IN (
  SELECT id FROM tr8n_translation_keys
  WHERE verified_at IS NULL OR verified_at < '2025-01-01'
)

UNION ALL

SELECT
  'Translation Key Locks',
  COUNT(*)
FROM tr8n_translation_key_locks
WHERE translation_key_id IN (
  SELECT id FROM tr8n_translation_keys
  WHERE verified_at IS NULL OR verified_at < '2025-01-01'
);
```

### Safe Delete Preview (Transaction Test)

```sql
-- Run this to see what would be deleted without actually deleting
BEGIN;

DELETE FROM tr8n_translation_keys
WHERE verified_at IS NULL OR verified_at < '2025-01-01'
RETURNING id, label, verified_at;

-- Review the output, then:
ROLLBACK;  -- Don't commit, just testing
```

## Performance Queries

### Check Index Usage

```sql
-- PostgreSQL
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE tablename = 'tr8n_translation_keys'
  AND indexname LIKE '%verified_at%';
```

### Slow Query Analysis (PostgreSQL)

```sql
EXPLAIN ANALYZE
SELECT id, label, verified_at
FROM tr8n_translation_keys
WHERE verified_at IS NULL
   OR verified_at < NOW() - INTERVAL '90 days'
ORDER BY verified_at ASC NULLS FIRST
LIMIT 100;
```

Should show index scan on `verified_at` index, not sequential scan.

## Reporting Queries

### Executive Summary

```sql
SELECT
  (SELECT COUNT(*) FROM tr8n_translation_keys) as total_keys,
  (SELECT COUNT(*) FROM tr8n_translation_keys
   WHERE verified_at > NOW() - INTERVAL '30 days') as active_last_30_days,
  (SELECT COUNT(*) FROM tr8n_translation_keys
   WHERE verified_at IS NULL OR verified_at < NOW() - INTERVAL '180 days') as unused_180_days,
  (SELECT COUNT(*) FROM tr8n_translations) as total_translations,
  (SELECT COUNT(*) FROM tr8n_translations t
   JOIN tr8n_translation_keys tk ON t.translation_key_id = tk.id
   WHERE tk.verified_at IS NULL OR tk.verified_at < NOW() - INTERVAL '180 days') as wasted_translations;
```

### Language-Specific Waste Analysis

```sql
SELECT
  l.english_name as language,
  l.locale,
  COUNT(t.id) as unused_translation_count,
  COUNT(DISTINCT tk.id) as unused_key_count
FROM tr8n_translations t
JOIN tr8n_translation_keys tk ON t.translation_key_id = tk.id
JOIN tr8n_languages l ON t.language_id = l.id
WHERE tk.verified_at IS NULL
   OR tk.verified_at < NOW() - INTERVAL '180 days'
GROUP BY l.id, l.english_name, l.locale
ORDER BY unused_translation_count DESC;
```

Shows which languages have the most translations for unused keys.

## Notes on Date Intervals

For MySQL, replace:
- `NOW() - INTERVAL '90 days'` with `DATE_SUB(NOW(), INTERVAL 90 DAY)`
- `DATE_TRUNC('month', verified_at)` with `DATE_FORMAT(verified_at, '%Y-%m-01')`
- `EXTRACT(DAY FROM NOW() - verified_at)` with `DATEDIFF(NOW(), verified_at)`

For SQLite, replace:
- `NOW() - INTERVAL '90 days'` with `datetime('now', '-90 days')`
- `DATE_TRUNC('month', verified_at)` with `date(verified_at, 'start of month')`
- `EXTRACT(DAY FROM NOW() - verified_at)` with `julianday('now') - julianday(verified_at)`

## Safety Reminders

1. Always test queries on a development/staging database first
2. Take a database backup before running DELETE operations
3. Use transactions (BEGIN/ROLLBACK/COMMIT) when testing destructive operations
4. Monitor query performance with EXPLAIN ANALYZE before running on production
5. Consider running large deletes in batches to avoid locking issues
