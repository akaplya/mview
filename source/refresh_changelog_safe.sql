DELIMITER $$

USE `mview`$$

DROP PROCEDURE IF EXISTS `refresh_changelog_safe`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `refresh_changelog_safe`(p_schema_name VARCHAR(60), p_mview_name VARCHAR(60))
BEGIN
  DECLARE l_table_name        VARCHAR(64);
  DECLARE l_view_name         VARCHAR(64);
  DECLARE l_id_field          VARCHAR(64);
  DECLARE l_changelog_enabled VARCHAR(64);
  DECLARE l_current_time      TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
      SELECT CONCAT('Refresh failed, previous data has been restored:', CHAR(10),
        @l_delete_script, CHAR(10), @l_insert_script);
      
  END;
  SELECT table_name, view_name, id_field, changelog_enabled
  INTO l_table_name, l_view_name, l_id_field, l_changelog_enabled
  FROM mview_metadata
  WHERE mview_name   = p_mview_name
    AND mview_schema = p_schema_name;
  IF (l_id_field IS NOT NULL AND l_changelog_enabled = 1) THEN
  BEGIN
    SET @l_delete_script  := CONCAT('DELETE mw ',
      'FROM ', p_mview_schema, '.', l_table_name, ' AS mw ',
      'INNER JOIN ', p_mview_schema, '.', l_table_name, '_changelog AS mwc ON mwc.',
      l_id_field, ' = mw.', l_id_field);
    
    SET @l_insert_script  := CONCAT('INSERT INTO ', p_mview_schema, '.', l_table_name,
      ' SELECT vw.* FROM ', p_mview_schema, '.', l_view_name, ' AS vw ',
      'INNER JOIN ', p_mview_schema, '.', l_table_name, '_changelog AS mwc ON mwc.',
      l_id_field, ' = vw.', l_id_field);

    SET @clear_changelog  := CONCAT('DELETE FROM ',
      p_schema_name, '.', l_table_name, '_changelog');

    START TRANSACTION;
      PREPARE delete_data FROM @l_delete_script;
      EXECUTE delete_data;
      PREPARE insert_data FROM @l_insert_script;
      EXECUTE insert_data;
  
      PREPARE clear_changelog FROM @l_clear_changelog;
      EXECUTE clear_changelog;
      
    UPDATE mview.metadata
      SET refreshed_at = l_current_time
    WHERE mview_name = p_mview_name
      AND mview_schema = p_schema_name;
    COMMIT;
  END;
  ELSE
  BEGIN
    SELECT 'Current materialized view does not support changelog!!!';
  END;
  END IF;
END$$

DELIMITER ;
