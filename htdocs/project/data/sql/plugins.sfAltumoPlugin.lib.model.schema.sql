
# This is a fix for InnoDB in MySQL >= 4.1.x
# It "suspends judgement" for fkey relationships until are tables are set.
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- country
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `country`;

CREATE TABLE `country`
(
	`id` INTEGER NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(64) NOT NULL,
	`iso_code` VARCHAR(12) NOT NULL,
	`iso_short_code` VARCHAR(2) NOT NULL,
	`created_at` DATETIME,
	`updated_at` DATETIME,
	PRIMARY KEY (`id`),
	UNIQUE INDEX `country_U_1` (`iso_short_code`),
	UNIQUE INDEX `country_U_2` (`iso_short_code`),
	INDEX `country_I_1` (`name`),
	INDEX `country_I_2` (`iso_short_code`),
	INDEX `country_I_3` (`iso_code`)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- state
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `state`;

CREATE TABLE `state`
(
	`id` INTEGER NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(64) NOT NULL,
	`iso_code` VARCHAR(12) NOT NULL,
	`iso_short_code` VARCHAR(2) NOT NULL,
	`country_id` INTEGER NOT NULL,
	`created_at` DATETIME,
	`updated_at` DATETIME,
	PRIMARY KEY (`id`),
	UNIQUE INDEX `state_U_1` (`iso_short_code`),
	UNIQUE INDEX `state_U_2` (`iso_short_code`),
	INDEX `state_I_1` (`name`),
	INDEX `state_I_2` (`iso_short_code`),
	INDEX `state_I_3` (`iso_code`),
	INDEX `state_FI_1` (`country_id`),
	CONSTRAINT `state_FK_1`
		FOREIGN KEY (`country_id`)
		REFERENCES `country` (`id`)
		ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- session
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `session`;

CREATE TABLE `session`
(
	`id` INTEGER NOT NULL AUTO_INCREMENT,
	`session_key` VARCHAR(32) NOT NULL,
	`data` LONGBLOB,
	`client_ip_address` VARCHAR(39),
	`session_type` VARCHAR(32),
	`time` INTEGER NOT NULL,
	PRIMARY KEY (`id`),
	UNIQUE INDEX `session_U_1` (`session_key`),
	INDEX `session_I_1` (`client_ip_address`),
	INDEX `session_I_2` (`time`)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- single_sign_on_key
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `single_sign_on_key`;

CREATE TABLE `single_sign_on_key`
(
	`id` INTEGER NOT NULL AUTO_INCREMENT,
	`secret` VARCHAR(32) NOT NULL,
	`used` TINYINT DEFAULT 0 NOT NULL,
	`session_id` INTEGER,
	`valid_for_minutes` INTEGER DEFAULT 1440 NOT NULL,
	`created_at` DATETIME,
	`updated_at` DATETIME,
	PRIMARY KEY (`id`),
	UNIQUE INDEX `single_sign_on_key_U_1` (`secret`),
	INDEX `secret_used` (`secret`, `used`),
	INDEX `single_sign_on_key_I_2` (`used`),
	INDEX `single_sign_on_key_FI_1` (`session_id`),
	CONSTRAINT `single_sign_on_key_FK_1`
		FOREIGN KEY (`session_id`)
		REFERENCES `session` (`id`)
		ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- system_event
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `system_event`;

CREATE TABLE `system_event`
(
	`id` INTEGER NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(64) NOT NULL,
	`unique_key` VARCHAR(64) NOT NULL,
	`slug` VARCHAR(255) NOT NULL,
	`enabled` TINYINT DEFAULT 1 NOT NULL,
	`created_at` DATETIME,
	`updated_at` DATETIME,
	PRIMARY KEY (`id`),
	UNIQUE INDEX `system_event_U_1` (`unique_key`),
	UNIQUE INDEX `system_event_U_2` (`slug`),
	INDEX `system_event_I_1` (`name`),
	INDEX `system_event_I_2` (`enabled`)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- system_event_subscription
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `system_event_subscription`;

CREATE TABLE `system_event_subscription`
(
	`id` INTEGER NOT NULL AUTO_INCREMENT,
	`system_event_id` INTEGER NOT NULL,
	`remote_url` VARCHAR(255),
	`enabled` TINYINT DEFAULT 1 NOT NULL,
	`created_at` DATETIME,
	`updated_at` DATETIME,
	PRIMARY KEY (`id`),
	INDEX `system_event_subscription_I_1` (`enabled`),
	INDEX `system_event_subscription_FI_1` (`system_event_id`),
	CONSTRAINT `system_event_subscription_FK_1`
		FOREIGN KEY (`system_event_id`)
		REFERENCES `system_event` (`id`)
		ON UPDATE CASCADE
		ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- system_event_instance
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `system_event_instance`;

CREATE TABLE `system_event_instance`
(
	`id` INTEGER NOT NULL AUTO_INCREMENT,
	`system_event_id` INTEGER NOT NULL,
	`message` TEXT,
	`created_at` DATETIME,
	`updated_at` DATETIME,
	PRIMARY KEY (`id`),
	INDEX `system_event_instance_FI_1` (`system_event_id`),
	CONSTRAINT `system_event_instance_FK_1`
		FOREIGN KEY (`system_event_id`)
		REFERENCES `system_event` (`id`)
		ON UPDATE CASCADE
		ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- system_event_instance_message
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `system_event_instance_message`;

CREATE TABLE `system_event_instance_message`
(
	`id` INTEGER NOT NULL AUTO_INCREMENT,
	`system_event_instance_id` INTEGER NOT NULL,
	`system_event_subscription_id` INTEGER NOT NULL,
	`received` TINYINT DEFAULT 0 NOT NULL,
	`received_at` DATETIME,
	`status_message` VARCHAR(255),
	`created_at` DATETIME,
	`updated_at` DATETIME,
	PRIMARY KEY (`id`),
	INDEX `system_event_instance_message_I_1` (`received`),
	INDEX `system_event_instance_message_FI_1` (`system_event_instance_id`),
	INDEX `system_event_instance_message_FI_2` (`system_event_subscription_id`),
	CONSTRAINT `system_event_instance_message_FK_1`
		FOREIGN KEY (`system_event_instance_id`)
		REFERENCES `system_event_instance` (`id`)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	CONSTRAINT `system_event_instance_message_FK_2`
		FOREIGN KEY (`system_event_subscription_id`)
		REFERENCES `system_event_subscription` (`id`)
		ON UPDATE CASCADE
		ON DELETE CASCADE
) ENGINE=InnoDB;

# This restores the fkey checks, after having unset them earlier
SET FOREIGN_KEY_CHECKS = 1;
