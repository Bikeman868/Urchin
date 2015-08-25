-- --------------------------------------------------------
-- Creates an Urchin server database in MySQL.
--
-- This script was exported from Heidi, but should also work
-- with other MySQL cients.
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping database structure for Urchin
CREATE DATABASE IF NOT EXISTS `Urchin` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `Urchin`;


-- Dumping structure for table Urchin.Environments
CREATE TABLE IF NOT EXISTS `Environments` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `ix_Name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table Urchin.Machines
CREATE TABLE IF NOT EXISTS `Machines` (
  `EnvironmentId` int(10) unsigned NOT NULL,
  `Name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`EnvironmentId`,`Name`),
  KEY `ix_Environment` (`EnvironmentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table Urchin.Rules
CREATE TABLE IF NOT EXISTS `Rules` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `EnvironmentId` int(10) unsigned DEFAULT NULL,
  `Machine` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Application` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Instance` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Config` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `Name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table Urchin.Settings
CREATE TABLE IF NOT EXISTS `Settings` (
  `Name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `Value` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table Urchin.Variables
CREATE TABLE IF NOT EXISTS `Variables` (
  `RuleId` int(11) NOT NULL,
  `Name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `Value` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`RuleId`,`Name`),
  KEY `ix_Rule` (`RuleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for procedure Urchin.sp_DeleteEnvironment
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_DeleteEnvironment`(IN `environmentName` VARCHAR(50))
BEGIN
	DECLARE environmentId INT UNSIGNED;
	
	SELECT e.Id
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environmentName;
	
	DELETE FROM m USING Machines AS m
	WHERE m.EnvironmentId = environmentId;
	
	DELETE FROM e USING Environments AS e
	WHERE e.Id = environmentId;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_DeleteEnvironmentMachines
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_DeleteEnvironmentMachines`(IN `environmentName` VARCHAR(50))
BEGIN
	DECLARE environmentId INT UNSIGNED;
	
	SELECT e.Id
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environmentName;

	DELETE FROM m USING Machines AS m
	WHERE m.EnvironmentId = environmentId;

END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_DeleteRule
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_DeleteRule`(IN `ruleName` VARCHAR(50))
BEGIN
	DECLARE ruleId INT UNSIGNED;
	
	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE r.Name = ruleName;

	DELETE FROM v USING Variables AS v
	WHERE v.RuleId = ruleId;
	
	DELETE FROM r USING Rules AS r
	WHERE r.Id = ruleId;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_DeleteRuleVariables
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_DeleteRuleVariables`(IN `ruleName` VARCHAR(50))
BEGIN
	DECLARE ruleId INT UNSIGNED;
	
	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE r.Name = ruleName;

	DELETE FROM v USING Variables AS v
	WHERE v.RuleId = ruleId;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_GetDefaultEnvironment
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetDefaultEnvironment`()
BEGIN
	SELECT s.Value AS DefaultEnvironment
	FROM Settings s
	WHERE s.Name = 'DefaultEnvironment';
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_GetEnvironment
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetEnvironment`(IN `environmentName` VARCHAR(50))
BEGIN
	SELECT environmentName AS Name;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_GetEnvironmentMachines
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetEnvironmentMachines`(IN `environmentName` VARCHAR(50))
BEGIN
	DECLARE environmentId INT UNSIGNED;
	
	SELECT e.Id
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environmentName;
	
	SELECT m.Name
	FROM Machines m
	WHERE m.EnvironmentId = environmentId;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_GetEnvironmentNames
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetEnvironmentNames`()
BEGIN
	SELECT e.Name
	FROM Environments e;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_GetRule
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetRule`(IN `ruleName` VARCHAR(50))
BEGIN
	SELECT
		r.Name,
		e.Name AS Environment,
		r.Machine,
		r.Application,
		r.Instance,
		r.Config
	FROM 
		Rules r LEFT JOIN
		Environments e ON r.EnvironmentId = e.Id
	WHERE r.Name = ruleName;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_GetRuleNames
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetRuleNames`()
BEGIN
	SELECT r.Name
	FROM Rules r;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_GetRuleVariables
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetRuleVariables`(IN `ruleName` VARCHAR(50))
BEGIN
	DECLARE ruleId INT UNSIGNED;
	
	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE r.Name = ruleName;

	SELECT 
		v.Name,
		v.Value
	FROM Variables v
	WHERE v.RuleId = ruleId;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_InsertEnvironmentMachine
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertEnvironmentMachine`(IN `environmentName` VARCHAR(50), IN `machineName` VARCHAR(50))
BEGIN
	DECLARE environmentId INT UNSIGNED;

	CALL sp_InsertUpdateEnvironment(environmentName);
	
	SELECT e.Id
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environmentName;

	INSERT IGNORE INTO Machines
	(
		EnvironmentId,
		Name
	) VALUES (
		environmentId,
		machineName
	);
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_InsertRuleVariable
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertRuleVariable`(IN `ruleName` VARCHAR(50), IN `variableName` VARCHAR(50), IN `variableValue` TEXT)
BEGIN
	DECLARE ruleId INT UNSIGNED;

	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE r.Name = ruleName;

	INSERT IGNORE INTO Variables
	(
		RuleId,
		Name,
		Value
	) VALUES (
		ruleId,
		variableName,
		variableValue
	);
	
	UPDATE Variables v
	SET v.Value = variableValue
	WHERE v.RuleId = ruleId AND v.Name = variableName;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_InsertUpdateEnvironment
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertUpdateEnvironment`(IN `environmentName` VARCHAR(50))
BEGIN
	DECLARE environmentId INT UNSIGNED;
	
	SELECT e.Id 
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environmentName;

	IF environmentId IS NULL THEN
		INSERT IGNORE INTO Environments
		(
			Name
		) VALUES (
			environmentName
		);

		SELECT e.Id 
		INTO environmentId
		FROM Environments e
		WHERE e.Name = environmentName;
	END IF;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_InsertUpdateRule
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertUpdateRule`(IN `ruleName` VARCHAR(50), IN `application` VARCHAR(50), IN `environment` VARCHAR(50), IN `instance` VARCHAR(50), IN `machine` VARCHAR(50), IN `config` TEXT)
BEGIN
	DECLARE environmentId INT UNSIGNED;
	DECLARE ruleId INT UNSIGNED;
	
	CALL sp_InsertUpdateEnvironment(environment);
	
	SELECT e.Id 
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environment;

	INSERT IGNORE INTO Rules
	(
		Name,
		Application,
		EnvironmentId,
		Machine,
		Instance,
		Config
	) VALUES (
		ruleName,
		application,
		environmentId,
		machine,
		instance,
		config
	);
	
	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE r.Name = ruleName;
	
	UPDATE Rules r
	SET
		r.Name = ruleName,
		r.Application = application,
		r.EnvironmentId = environmentId,
		r.Machine = machine,
		r.Instance = instance,
		r.Config = config
	WHERE r.Id = ruleId;
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_UpdateDefaultEnvironment
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_UpdateDefaultEnvironment`(IN `environmentName` VARCHAR(50))
BEGIN
	CALL sp_UpdateSetting('DefaultEnvironment', environmentName);
END//
DELIMITER ;


-- Dumping structure for procedure Urchin.sp_UpdateSetting
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_UpdateSetting`(IN `settingName` VARCHAR(50), IN `settingValue` TEXT)
BEGIN
	INSERT IGNORE INTO Settings(
			Name, 
			Value
		) VALUES (
			settingName,
			settingValue
		);
		
	UPDATE Settings s
	SET s.Value = settingValue
	WHERE s.Name = settingName;

END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
