DELIMITER $$

USE `mview`$$

DROP PROCEDURE IF EXISTS `refresh`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `refresh`(
  p_schema_name VARCHAR(64),
  p_mview_name  VARCHAR(60)
  )
BEGIN
  DECLARE l_view_name      VARCHAR(64);
  DECLARE l_current_time   TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
  BEGIN
    UPDATE mview.metadata
      SET refreshed_at = NULL
    WHERE mview_name = p_mview_name
      AND mview_schema = p_schema_name;
    SELECT CONCAT('Refresh failed, previous data has been restored:', CHAR(10),
      @l_delete_script, CHAR(10), @l_insert_script);
  END;
  SELECT view_name
  INTO l_view_name
  FROM mview.metadata
  WHERE mview_name = p_mview_name
    AND mview_schema = p_schema_name;
  SET @l_delete_script     := CONCAT('DELETE FROM ',
    p_schema_name, '.', p_mview_name);
  SET @l_insert_script     := CONCAT('INSERT INTO ',
    p_schema_name, '.', p_mview_name,
    ' SELECT * FROM ', p_schema_name, '.', l_view_name);
  PREPARE delete_data FROM @l_delete_script;
  EXECUTE delete_data;
  PREPARE insert_data FROM @l_insert_script;
  EXECUTE insert_data;
  UPDATE mview.metadata
    SET refreshed_at = l_current_time
  WHERE mview_name = p_mview_name
    AND mview_schema = p_schema_name;
END$$

DELIMITER ;
