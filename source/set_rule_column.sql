DELIMITER $$

USE `mview`$$

DROP PROCEDURE IF EXISTS `set_rule_column`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `set_rule_column`(
  p_schema_name VARCHAR(64),
  p_mview_name  VARCHAR(60),
  p_rule_column VARCHAR(64)
  )
BEGIN
  UPDATE mview.metadata
    SET rule_column = p_rule_column
  WHERE mview_name = p_mview_name
    AND mview_schema = p_schema_name;
END$$

DELIMITER ;
