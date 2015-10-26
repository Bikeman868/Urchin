-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.6.26-log - MySQL Community Server (GPL)
-- Server OS:                    Win64
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping database structure for urchin
CREATE DATABASE IF NOT EXISTS `urchin` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `urchin`;


-- Dumping structure for table urchin.environments
CREATE TABLE IF NOT EXISTS `environments` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `Version` int(11) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `ix_Name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table urchin.machines
CREATE TABLE IF NOT EXISTS `machines` (
  `EnvironmentId` int(10) unsigned NOT NULL,
  `Name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`EnvironmentId`,`Name`),
  KEY `ix_Environment` (`EnvironmentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table urchin.rules
CREATE TABLE IF NOT EXISTS `rules` (
  `Id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Version` int(11) unsigned NOT NULL DEFAULT '0',
  `Name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `EnvironmentId` int(10) unsigned DEFAULT NULL,
  `Machine` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Application` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Instance` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Config` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `Name` (`Name`,`Version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table urchin.securityrules
CREATE TABLE IF NOT EXISTS `securityrules` (
  `EnvironmentId` int(11) unsigned NOT NULL,
  `StartIp` varchar(15) COLLATE utf8_unicode_ci DEFAULT NULL,
  `EndIp` varchar(15) COLLATE utf8_unicode_ci DEFAULT NULL,
  KEY `ix_Environment` (`EnvironmentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table urchin.settings
CREATE TABLE IF NOT EXISTS `settings` (
  `Name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `Value` varchar(250) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table urchin.variables
CREATE TABLE IF NOT EXISTS `variables` (
  `RuleId` int(11) NOT NULL,
  `Name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `Value` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`RuleId`,`Name`),
  KEY `ix_Rule` (`RuleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for table urchin.versions
CREATE TABLE IF NOT EXISTS `versions` (
  `Version` int(11) unsigned NOT NULL,
  `Name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`Version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Data exporting was unselected.


-- Dumping structure for procedure urchin.ip_EnsureVersion
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `ip_EnsureVersion`(IN `version` INT)
BEGIN
	IF NOT EXISTS 
		(
			SELECT v.Name 
			FROM Versions v 
			WHERE v.Version = version
		) THEN
		INSERT INTO Versions (
			Version,
			Name
		) VALUES (
			version,
			CONCAT('Version ', version)
		);
	END IF;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.ip_UpdateSetting
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `ip_UpdateSetting`(IN `settingName` VARCHAR(50), IN `settingValue` TEXT)
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


-- Dumping structure for procedure urchin.sp_DeleteEnvironment
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
	
	DELETE FROM r USING SecurityRules AS r
	WHERE r.EnvironmentId = environmentId;
	
	DELETE FROM e USING Environments AS e
	WHERE e.Id = environmentId;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_DeleteEnvironmentMachines
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


-- Dumping structure for procedure urchin.sp_DeleteEnvironmentSecurity
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_DeleteEnvironmentSecurity`(IN `environmentName` VARCHAR(50))
BEGIN
	DECLARE environmentId INT UNSIGNED;
	
	SELECT e.Id
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environmentName;

	DELETE FROM r USING SecurityRules AS r
	WHERE r.EnvironmentId = environmentId;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_DeleteRule
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_DeleteRule`(IN `ruleName` VARCHAR(50), IN `version` INT)
BEGIN
	DECLARE ruleId INT UNSIGNED;
	
	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE 
		r.Name = ruleName
			AND
		r.Version = version;

	DELETE FROM v USING Variables AS v
	WHERE v.RuleId = ruleId;
	
	DELETE FROM r USING Rules AS r
	WHERE r.Id = ruleId;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_DeleteRuleVariables
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_DeleteRuleVariables`(IN `ruleName` VARCHAR(50), IN `version` INT)
BEGIN
	DECLARE ruleId INT UNSIGNED;
	
	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE 
		r.Name = ruleName
			AND
		r.Version = version;

	DELETE FROM v USING Variables AS v
	WHERE v.RuleId = ruleId;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_DeleteVersion
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_DeleteVersion`(IN `version` INT)
BEGIN
	DELETE FROM v USING Variables AS v
	WHERE v.RuleId IN (SELECT r.RuleId FROM Rules r WHERE r.Version = version);

	DELETE FROM r USING Rules AS r
	WHERE r.Version = version;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_GetAdministratorPassword
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetAdministratorPassword`()
BEGIN
	SELECT s.Value AS AdministratorPassword
	FROM Settings s
	WHERE s.Name = 'AdministratorPassword';
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_GetDefaultEnvironment
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetDefaultEnvironment`()
BEGIN
	SELECT s.Value AS DefaultEnvironment
	FROM Settings s
	WHERE s.Name = 'DefaultEnvironment';
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_GetEnvironment
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetEnvironment`(IN `environmentName` VARCHAR(50))
BEGIN
	SELECT
		e.Id,
		e.Name,
		e.Version
	FROM Environments e
	WHERE e.Name = environmentName;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_GetEnvironmentMachines
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


-- Dumping structure for procedure urchin.sp_GetEnvironmentNames
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetEnvironmentNames`()
BEGIN
	SELECT e.Name
	FROM Environments e;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_GetEnvironmentSecurity
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetEnvironmentSecurity`(IN `environmentName` VARCHAR(50))
BEGIN
	DECLARE environmentId INT UNSIGNED;
	
	SELECT e.Id
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environmentName;
	
	SELECT 
		r.StartIp,
		r.EndIp
	FROM SecurityRules r
	WHERE r.EnvironmentId = environmentId;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_GetRule
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetRule`(IN `ruleName` VARCHAR(50), IN `version` INT)
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
	WHERE 
		r.Name = ruleName
			AND
		r.Version = version;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_GetRuleNames
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetRuleNames`(IN `version` INT)
BEGIN
	SELECT r.Name
	FROM Rules r
	WHERE r.Version = version;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_GetRuleVariables
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetRuleVariables`(IN `ruleName` VARCHAR(50), IN `version` INT)
BEGIN
	DECLARE ruleId INT UNSIGNED;
	
	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE 
		r.Name = ruleName
			AND
		r.Version = version;

	SELECT 
		v.Name,
		v.Value
	FROM Variables v
	WHERE v.RuleId = ruleId;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_GetVersionNumbers
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_GetVersionNumbers`()
BEGIN
	SELECT version
	FROM Versions;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_InsertEnvironmentMachine
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertEnvironmentMachine`(IN `environmentName` VARCHAR(50), IN `environmentVersion` INT, IN `machineName` VARCHAR(50))
BEGIN
	DECLARE environmentId INT UNSIGNED;

	CALL sp_InsertUpdateEnvironment(environmentName, environmentVersion);
	
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


-- Dumping structure for procedure urchin.sp_InsertEnvironmentSecurity
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertEnvironmentSecurity`(IN `environmentName` VARCHAR(50), IN `environmentVersion` INT, IN `startIP` VARCHAR(15), IN `endIp` VARCHAR(15))
BEGIN
	DECLARE environmentId INT UNSIGNED;

	CALL sp_InsertUpdateEnvironment(environmentName, environmentVersion);
	
	SELECT e.Id
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environmentName;

	INSERT IGNORE INTO SecurityRules
	(
		EnvironmentId,
		StartIp,
		EndIp
	) VALUES (
		environmentId,
		startIp,
		endIp
	);
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_InsertRuleVariable
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertRuleVariable`(IN `ruleName` VARCHAR(50), IN `version` INT, IN `variableName` VARCHAR(50), IN `variableValue` TEXT)
BEGIN
	DECLARE ruleId INT UNSIGNED;

	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE 
		r.Name = ruleName
			AND
		r.Version = version;

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


-- Dumping structure for procedure urchin.sp_InsertUpdateEnvironment
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertUpdateEnvironment`(IN `environmentName` VARCHAR(50), IN `version` INT)
BEGIN
	DECLARE environmentId INT UNSIGNED;
	
	SELECT e.Id 
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environmentName;

	IF environmentId IS NULL THEN
		INSERT IGNORE INTO Environments
		(
			Name,
			Version
		) VALUES (
			environmentName,
			version
		);
		SELECT e.Id
		INTO environmentId
		FROM Environments e
		WHERE e.Name = environmentName;
	END IF;
	
	UPDATE Environments e
	SET e.Version = version
	WHERE e.Id = environmentId;
	
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_InsertUpdateRule
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertUpdateRule`(IN `ruleName` VARCHAR(50), IN `version` INT, IN `application` VARCHAR(50), IN `environment` VARCHAR(50), IN `instance` VARCHAR(50), IN `machine` VARCHAR(50), IN `config` TEXT)
BEGIN
	DECLARE environmentId INT UNSIGNED;
	DECLARE ruleId INT UNSIGNED;
	
	CALL ip_EnsureVersion(version);
	CALL sp_InsertUpdateEnvironment(environment, version);
	
	SELECT e.Id 
	INTO environmentId
	FROM Environments e
	WHERE e.Name = environment;

	INSERT IGNORE INTO Rules
	(
		Name,
		Version,
		Application,
		EnvironmentId,
		Machine,
		Instance,
		Config
	) VALUES (
		ruleName,
		version,
		application,
		environmentId,
		machine,
		instance,
		config
	);
	
	SELECT r.Id
	INTO ruleId
	FROM Rules r
	WHERE 
		r.Name = ruleName
			AND
		r.Version = version;
	
	UPDATE Rules r
	SET
		r.Name = ruleName,
		r.Version = version,
		r.Application = application,
		r.EnvironmentId = environmentId,
		r.Machine = machine,
		r.Instance = instance,
		r.Config = config
	WHERE r.Id = ruleId;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_InsertUpdateVersion
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_InsertUpdateVersion`(IN `version` INT, IN `name` VARCHAR(50))
BEGIN
	INSERT IGNORE INTO Versions
	(
		Version,
		Name
	) VALUES (
		version,
		name
	);
	
	UPDATE Versions v
	SET v.Name = name
	WHERE v.Version = version;
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_UpdateAdministratorPassword
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_UpdateAdministratorPassword`(IN `newPassword` VARCHAR(50))
BEGIN
	CALL ip_UpdateSetting('AdministratorPassword', newPassword);
END//
DELIMITER ;


-- Dumping structure for procedure urchin.sp_UpdateDefaultEnvironment
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_UpdateDefaultEnvironment`(IN `environmentName` VARCHAR(50))
BEGIN
	CALL ip_UpdateSetting('DefaultEnvironment', environmentName);
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
