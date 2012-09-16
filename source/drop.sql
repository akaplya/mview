DELIMITER $$

USE `mview`$$

DROP PROCEDURE IF EXISTS `drop`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `drop`(
  p_schema_name VARCHAR(64),
  p_mview_name  VARCHAR(60)
  )
BEGIN
  DECLARE l_view_name VARCHAR(64);
  DECLARE l_changelog_enabled INTEGER;
  SELECT view_name, changelog_enabled
  INTO l_view_name, l_changelog_enabled
  FROM mview.metadata
  WHERE mview_name = p_mview_name
    AND mview_schema = p_schema_name;
    IF (l_changelog_enabled = 1) THEN
    BEGIN
      SELECT 'Cannot drop materialized view, changelog enabled!';
    END;
    ELSE
    BEGIN
      SET @l_view_drop_script     := CONCAT('DROP VIEW IF EXISTS ', p_schema_name, '.', l_view_name);
      SET @l_table_drop_script    := CONCAT('DROP TABLE IF EXISTS ', p_schema_name, '.', p_mview_name);
      PREPARE drop_view FROM @l_view_drop_script;
      EXECUTE drop_view;
      PREPARE drop_table FROM @l_table_drop_script;
      EXECUTE drop_table;
      DELETE FROM mview.metadata
      WHERE mview_name = p_mview_name
        AND mview_schema = p_schema_name;
    END;
    END IF;
END$$

DELIMITER ;
