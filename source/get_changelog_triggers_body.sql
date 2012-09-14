DELIMITER $$

USE `mview`$$

DROP PROCEDURE IF EXISTS `get_changelog_triggers_body`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_changelog_triggers_body`(
  p_schema_name VARCHAR(64),
  p_table_name  VARCHAR(64)
  )
BEGIN
  DECLARE l_done        INT DEFAULT FALSE;
  DECLARE l_changelog   VARCHAR(64);
  DECLARE l_log_column  VARCHAR(64);
  DECLARE l_rule_column VARCHAR(64);
  DECLARE l_insert_trigger_script MEDIUMTEXT;
  DECLARE l_update_trigger_script MEDIUMTEXT;
  DECLARE l_delete_trigger_script MEDIUMTEXT;

  DECLARE changelog_tables CURSOR
  FOR SELECT
    changelog.changelog, changelog.log_column, metadata.rule_column
  FROM mview.changelog
  INNER JOIN mview.metadata ON metadata.id = changelog.mview_id
    AND metadata.mview_schema = changelog.mview_schema
  WHERE table_name = p_table_name
    AND metadata.mview_schema = p_schema_name;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT CONCAT(IFNULL(l_insert_trigger_script, ''), CHAR(10),
      IFNULL(l_update_trigger_script, ''), CHAR(10), IFNULL(l_delete_trigger_script, ''));
  END;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_done = 1;

  OPEN changelog_tables;
  create_trigger_loop: LOOP
    FETCH changelog_tables INTO l_changelog, l_log_column, l_rule_column;
    IF l_done THEN
      LEAVE create_trigger_loop;
    END IF;
    SET l_insert_trigger_script := CONCAT(IFNULL(l_insert_trigger_script, ''), CHAR(10),
      'DELIMITER $$', CHAR(10),
      'DROP TRIGGER IF EXISTS ', p_schema_name, '.trg_',
        p_table_name, '_after_insert; $$', CHAR(10),
      'CREATE TRIGGER ', p_schema_name, '.trg_', p_table_name, '_after_insert', CHAR(10),
      'AFTER INSERT ON ', p_schema_name, '.', p_table_name, CHAR(10),
      'FOR EACH ROW', CHAR(10),
      'BEGIN', CHAR(10),
      'INSERT IGNORE INTO ', p_schema_name, '.', l_changelog, ' (', l_rule_column, ') VALUE (NEW.', l_log_column, ');', CHAR(10),
      'END $$');

    SET l_update_trigger_script := CONCAT(IFNULL(l_update_trigger_script, ''), CHAR(10),
      'DELIMITER $$', CHAR(10),
      'DROP TRIGGER IF EXISTS ', p_schema_name, '.trg_',
        p_table_name, '_after_update; $$', CHAR(10),
      'CREATE TRIGGER ', p_schema_name, '.trg_', p_table_name, '_after_update', CHAR(10),
      'AFTER UPDATE ON ', p_schema_name, '.', p_table_name, CHAR(10),
      'FOR EACH ROW', CHAR(10),
      'BEGIN', CHAR(10),
      'INSERT IGNORE INTO ', p_schema_name, '.', l_changelog, ' (', l_rule_column, ') VALUE (OLD.', l_log_column, ');', CHAR(10),
      'END $$');
    SET l_delete_trigger_script := CONCAT(IFNULL(l_delete_trigger_script, ''), CHAR(10),
      'DELIMITER $$', CHAR(10),
      'DROP TRIGGER IF EXISTS ', p_schema_name, '.trg_',
        p_table_name, '_after_delete; $$', CHAR(10),
      'CREATE TRIGGER ', p_schema_name, '.trg_', p_table_name, '_after_delete', CHAR(10),
      'AFTER DELETE ON ', p_schema_name, '.', p_table_name, CHAR(10),
      'FOR EACH ROW', CHAR(10),
      'BEGIN', CHAR(10),
      'INSERT IGNORE INTO ', p_schema_name, '.', l_changelog, ' (', l_rule_column, ') VALUE (OLD.', l_log_column, ');', CHAR(10),
      'END $$');
    END LOOP;
  CLOSE changelog_tables;
  SELECT CONCAT(l_insert_trigger_script, CHAR(10), l_update_trigger_script, CHAR(10), l_delete_trigger_script);
END$$

DELIMITER ;
