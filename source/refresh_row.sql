DELIMITER $$

USE `mview`$$

DROP PROCEDURE IF EXISTS `refresh_row`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `refresh_row`(
  p_schema_name VARCHAR(64),
  p_mview_name  VARCHAR(60),
  p_value       INTEGER
  )
BEGIN
  DECLARE l_view_name   VARCHAR(64);
  DECLARE l_rule_column VARCHAR(64);
  DECLARE l_id_field    VARCHAR(64);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    ROLLBACK;
    SELECT CONCAT('Refresh failed, previous data has been restored:', CHAR(10),
      IFNULL(@l_delete_script, ''), CHAR(10), IFNULL(@l_insert_script, ''));
  END;
  SELECT view_name, rule_column
  INTO l_view_name, l_rule_column
  FROM mview.metadata
  WHERE mview_name = p_mview_name
    AND mview_schema = p_schema_name;
  IF (l_rule_column IS NOT NULL) THEN
  BEGIN
    SET @l_delete_script  := CONCAT('DELETE FROM ', p_schema_name, '.',
      p_mview_name, ' WHERE ', l_rule_column, '= ?');
    SET @l_insert_script  := CONCAT('INSERT INTO ', p_schema_name, '.',
      p_mview_name, ' SELECT * FROM ', p_schema_name, '.', l_view_name,
        ' WHERE ', l_rule_column, '= ?');
    SET @p_value = p_value;    
    START TRANSACTION;
      PREPARE delete_data FROM @l_delete_script;
      EXECUTE delete_data USING @p_value;
      PREPARE insert_data FROM @l_insert_script;
      EXECUTE insert_data USING @p_value;
    COMMIT;
  END;
  ELSE
  BEGIN
    SELECT 'Update impossible, id field does not set';
  END;
  END IF;
 
END$$

DELIMITER ;
