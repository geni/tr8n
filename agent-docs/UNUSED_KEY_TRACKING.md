# Tracking and Removing Unused Translation Keys

This document explains how to track usage of translation keys and identify stale keys that are no longer referenced by your application.

## Overview

The tr8n gem includes a `verified_at` timestamp on each translation key that tracks the last time the key was accessed. This allows you to identify keys that haven't been used in a long time and are likely safe to remove.

## How It Works

### Automatic Tracking

When `enable_key_verification` is enabled in your tr8n configuration, the system automatically updates the `verified_at` timestamp whenever a translation key is accessed through the `find_or_create` method.

**Performance Optimization**: To minimize database write contention in high-traffic environments, updates are throttled to occur at most once per 24 hours per key. This reduces database writes by ~99% while still providing accurate usage tracking.

### Configuration

Enable key verification in your tr8n configuration:

```ruby
Tr8n::Config.configure do |config|
  config[:enable_key_verification] = true
end
```

## Finding Unused Keys

### Quick Report (Command Line)

To get a summary of unused translation keys:

```bash
rake tr8n:find_unused_keys
```

By default, this finds keys not used in the last 90 days. To customize:

```bash
rake tr8n:find_unused_keys days=180  # Find keys unused for 6 months
```

This will show:
- Total number of translation keys
- Number of unused keys
- Percentage of unused keys
- Sample of the first 20 unused keys with their labels and last verified date

### Export to CSV

For detailed analysis or sharing with your team:

```bash
rake tr8n:export_unused_keys
```

Custom options:

```bash
rake tr8n:export_unused_keys days=180 file=stale_keys.csv
```

The CSV includes:
- Translation key ID and hash
- Label and description
- Last verified timestamp
- Days since last verification
- Creation timestamp

## Removing Unused Keys

**⚠️ WARNING**: Always backup your database before deleting translation keys!

### Step 1: Review

First, export and review the unused keys to ensure they're truly safe to delete:

```bash
rake tr8n:export_unused_keys days=180 file=keys_to_review.csv
```

Review the CSV file with your team. Look for:
- Seasonal content (e.g., holiday messages used once per year)
- Feature-specific keys that might be in rarely-used code paths
- Keys from deprecated features that are intentionally being removed

### Step 2: Delete

Once you've confirmed the keys are safe to delete:

```bash
rake tr8n:delete_unverified_keys before=2026-01-01
```

This will delete all keys where:
- `verified_at` is NULL, OR
- `verified_at` is before the specified date

**Note**: The deletion is permanent and will also remove associated translations.

## Recommended Workflow

### Initial Setup (One-time)

1. Run the migration to add the index:
   ```bash
   rake db:migrate
   ```

2. Enable key verification in your configuration

3. Wait 90+ days to collect usage data

### Quarterly Cleanup

Every 3 months:

1. Export unused keys (180+ days old):
   ```bash
   rake tr8n:export_unused_keys days=180 file=unused_$(date +%Y%m%d).csv
   ```

2. Review the CSV with your team

3. Delete confirmed unused keys:
   ```bash
   rake tr8n:delete_unverified_keys before=$(date -d '180 days ago' +%Y-%m-%d)
   ```

4. Monitor application logs for any missing translation errors

## Database Schema

The tracking uses the existing `verified_at` column in the `tr8n_translation_keys` table:

```sql
-- Find keys not verified in last 90 days
SELECT id, label, description, verified_at
FROM tr8n_translation_keys
WHERE verified_at IS NULL OR verified_at < NOW() - INTERVAL '90 days'
ORDER BY verified_at ASC NULLS FIRST
LIMIT 100;
```

An index on `verified_at` ensures these queries are fast even with millions of keys.

## Performance Considerations

### High-Traffic Sites

The throttling mechanism (24-hour minimum between updates) is specifically designed for high-traffic environments:

- **Without throttling**: 100 req/sec × 86,400 sec/day = 8.6M DB writes/day
- **With throttling**: Only 1 write per key per day = ~thousands of writes/day

### Database Contention

If you still experience contention, consider:

1. **Async updates**: Move `verified_at` updates to a background job queue
2. **Batch updates**: Accumulate touched keys in Redis/Memcached and bulk update every hour
3. **Separate connection pool**: Use a dedicated database connection for these updates

See the code in `app/models/tr8n/translation_key.rb` (line 102-107) to implement these optimizations.

## Troubleshooting

### "All keys showing as unused"

Check that:
1. `enable_key_verification` is enabled in your config
2. The application has been running for sufficient time to collect data
3. The fix in `verify_key` method is in place (should reference `tkey`, not `existing_key`)

### "Performance issues with verification"

The throttling should prevent this, but if issues persist:
1. Verify the index on `verified_at` is present: `\d tr8n_translation_keys` in psql
2. Check your `verified_at` update query performance
3. Consider reducing throttle period from 24 hours to 48 or 72 hours

## Legacy Verification System

The gem previously included a log-file based verification system (tasks `verify_keys` and related). The timestamp-based approach documented here is simpler and more efficient for most use cases.
