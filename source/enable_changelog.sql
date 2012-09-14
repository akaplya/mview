DELIMITER $$

USE `mview`$$

DROP PROCEDURE IF EXISTS `enable_changelog`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `enable_changelog`(
  p_schema_name VARCHAR(64),
  p_mview_name  VARCHAR(60),
  p_table_name  VARCHAR(64),
  p_log_column  VARCHAR(64)
  )
BEGIN
  DECLARE l_rule_column VARCHAR(64);
  DECLARE l_mview_id    VARCHAR(64);
  DECLARE l_changelog   VARCHAR(64);
  SELECT rule_column, id
  INTO l_rule_column, l_mview_id
  FROM mview.metadata
  WHERE mview_name = p_mview_name
    AND mview_schema = p_schema_name;
  IF (l_rule_column IS NOT NULL) THEN
  BEGIN
  
  SET l_changelog := CONCAT(p_mview_name, '_changelog');
    SET @l_changelog_script := CONCAT('CREATE TABLE IF NOT EXISTS ', p_schema_name, '.', l_changelog,
      '( ', l_rule_column, ' INT NOT NULL, PRIMARY KEY (', l_rule_column, ') )');
    INSERT INTO changelog (mview_id, table_name, table_schema, log_column, changelog, mview_schema)
    VALUES (l_mview_id, p_table_name, p_schema_name, IFNULL(p_log_column, l_rule_column), l_changelog, p_schema_name);
    PREPARE create_changelog FROM @l_changelog_script;
    EXECUTE create_changelog;

    UPDATE mview.metadata
      SET changelog_enabled = 1
    WHERE mview_name = p_mview_name
      AND mview_schema = p_schema_name;
  END;
  ELSE
  BEGIN 
    SELECT 'Id field is not set, changelog can not be enabled';
  END;
  END IF;
END$$

DELIMITER ;
