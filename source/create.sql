DELIMITER $$

USE `mview`$$

DROP PROCEDURE IF EXISTS `create`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create`(
  p_schema_name VARCHAR(64),
  p_mview_name  VARCHAR(60),
  p_mview_sql   MEDIUMTEXT
  )
BEGIN
  DECLARE l_view_name      VARCHAR(64);
  DECLARE l_current_time   TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
  SET l_view_name      := CONCAT('vw_', p_mview_name);
  SET @l_view_script   := CONCAT('CREATE VIEW ', p_schema_name, '.', l_view_name,
    ' AS ', p_mview_sql);
  SET @l_table_script  := CONCAT('CREATE TABLE ', p_schema_name, '.', p_mview_name,
    ' AS SELECT * FROM ', p_schema_name, '.', l_view_name, ' LIMIT 0');
  SET @l_insert_script := CONCAT('INSERT INTO ', p_schema_name, '.', p_mview_name,
    ' SELECT * FROM ', p_schema_name, '.', l_view_name);
  PREPARE create_view FROM @l_view_script;
  EXECUTE create_view;
  PREPARE create_table FROM @l_table_script;
  EXECUTE create_table;
  PREPARE insert_data FROM @l_insert_script;
  EXECUTE insert_data;
  INSERT INTO mview.metadata (
    mview_name, view_name, mview_schema, created_at, refreshed_at)
  VALUES (
    p_mview_name, l_view_name, p_schema_name, l_current_time, l_current_time);
END$$

DELIMITER ;
