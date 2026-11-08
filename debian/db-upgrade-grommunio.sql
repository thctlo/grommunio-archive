-- grommunio-archive schema upgrade: piler 1.3.x snapshot -> piler 1.4.9
--
-- Applied automatically by the package's post-install scriptlet with the
-- database settings from grommunio-archive.conf. It can also be run by hand
-- against the archive database (mysqldb=, "groarchive" by default).
-- Idempotent. Every check uses DATABASE() instead of upstream's hardcoded
-- table_schema='piler', and avoids CREATE INDEX IF NOT EXISTS so it also works
-- on MySQL, not only MariaDB.

-- piler 1.4.4 renamed the `group` table to `usergroup`; the 1.4.9 webui only
-- knows the new name (TABLE_GROUP in config.php).
SET @has_old := (SELECT COUNT(*) FROM information_schema.tables
                 WHERE table_schema = DATABASE() AND table_name = 'group'
                 AND table_type = 'BASE TABLE');
SET @has_new := (SELECT COUNT(*) FROM information_schema.tables
                 WHERE table_schema = DATABASE() AND table_name = 'usergroup');
SET @q := IF(@has_old > 0 AND @has_new = 0,
             'RENAME TABLE `group` TO `usergroup`', 'DO 0');
PREPARE stmt FROM @q; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- audit.ipaddr was widened from char(15) so IPv6 addresses fit.
SET @len := (SELECT character_maximum_length FROM information_schema.columns
             WHERE table_schema = DATABASE() AND table_name = 'audit'
             AND column_name = 'ipaddr');
SET @q := IF(@len < 39,
             'ALTER TABLE `audit` MODIFY `ipaddr` varchar(39) NOT NULL', 'DO 0');
PREPARE stmt FROM @q; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Composite indexes used by pilerpurge.py and the oldest-message lookup.
SET @q := IF((SELECT COUNT(*) FROM information_schema.statistics
              WHERE table_schema = DATABASE() AND table_name = 'metadata'
              AND index_name = 'metadata_idx_purge') = 0,
             'CREATE INDEX `metadata_idx_purge` ON `metadata` (`deleted`, `retained`)', 'DO 0');
PREPARE stmt FROM @q; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @q := IF((SELECT COUNT(*) FROM information_schema.statistics
              WHERE table_schema = DATABASE() AND table_name = 'metadata'
              AND index_name = 'metadata_idx_oldest') = 0,
             'CREATE INDEX `metadata_idx_oldest` ON `metadata` (`deleted`, `sent`)', 'DO 0');
PREPARE stmt FROM @q; EXECUTE stmt; DEALLOCATE PREPARE stmt;
