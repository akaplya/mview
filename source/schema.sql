DROP SCHEMA IF EXISTS mview;
CREATE SCHEMA mview;

USE mview;

DROP TABLE IF EXISTS metadata;

CREATE TABLE mview.metadata (
  id                    INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  mview_name            VARCHAR(60)     NOT NULL,
  view_name             VARCHAR(64)     NOT NULL,
  mview_schema          VARCHAR(64)     NOT NULL,
  rule_column           VARCHAR(64)     NULL,
  changelog_enabled     TINYINT         NOT NULL DEFAULT 0,
  created_at            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  refreshed_at          TIMESTAMP       NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY pk_metadata_id(id),
  UNIQUE KEY uix_metadata_mview_schema_mview_name (mview_schema, mview_name),
  UNIQUE KEY uix_metadata_mview_schema_view_name (mview_schema, view_name)
);

CREATE TABLE mview.changelog (
  id                    INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  mview_id              INT UNSIGNED    NOT NULL,
  changelog             VARCHAR(64)     NOT NULL,
  table_name            VARCHAR(64)     NOT NULL,
  table_schema          VARCHAR(64)     NOT NULL,
  mview_schema          VARCHAR(64)     NOT NULL,
  log_column            VARCHAR(64)     NOT NULL,
  created_at            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY pk_changelog_id (id),
  UNIQUE KEY uix_changelog_mview_schema_mview_id_table_name (table_schema, mview_id, table_name),
  KEY ix_changelog_mview_schema_table_name (mview_schema, table_name),
  FOREIGN KEY fk_changelog_mview_id_metadata_id (mview_id) REFERENCES mview.metadata (id) ON DELETE CASCADE
);

