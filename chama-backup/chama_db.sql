/*
SQLyog Community v13.1.6 (64 bit)
MySQL - 10.4.32-MariaDB : Database - mbari_app
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`mbari_app` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `mbari_app`;

/*Table structure for table `attendance` */

DROP TABLE IF EXISTS `attendance`;

CREATE TABLE `attendance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `meeting_id` int(11) NOT NULL,
  `status` enum('present','late','absent') DEFAULT 'present',
  `arrival_time` time DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_member_meeting` (`member_id`,`meeting_id`),
  KEY `attendance_ibfk_2` (`meeting_id`),
  CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `attendance` */

insert  into `attendance`(`id`,`member_id`,`meeting_id`,`status`,`arrival_time`,`created_at`) values 
(1,4,5,'present','13:30:27','2025-07-11 13:50:27'),
(2,5,5,'present','13:32:27','2025-07-11 13:50:27'),
(3,6,5,'present','13:34:27','2025-07-11 13:50:27'),
(9,13,5,'present','06:16:02','2025-07-14 06:16:02');

/*Table structure for table `attendance_schedules` */

DROP TABLE IF EXISTS `attendance_schedules`;

CREATE TABLE `attendance_schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) NOT NULL,
  `check_time` datetime NOT NULL,
  `check_type` enum('start_check','end_check') NOT NULL,
  `is_processed` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_check_time` (`check_time`,`is_processed`),
  KEY `attendance_schedules_ibfk_1` (`meeting_id`),
  CONSTRAINT `attendance_schedules_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `attendance_schedules` */

insert  into `attendance_schedules`(`id`,`meeting_id`,`check_time`,`check_type`,`is_processed`,`created_at`) values 
(1,4,'2025-07-11 13:38:48','start_check',1,'2025-07-11 13:36:48'),
(2,4,'2025-07-11 13:41:48','end_check',1,'2025-07-11 13:36:48'),
(3,5,'2025-07-11 13:50:42','start_check',1,'2025-07-11 13:48:42'),
(4,5,'2025-07-11 13:53:42','end_check',1,'2025-07-11 13:48:42'),
(5,27,'2025-07-14 06:20:56','start_check',1,'2025-07-14 06:15:56'),
(6,27,'2025-07-14 06:25:56','end_check',1,'2025-07-14 06:15:56'),
(11,33,'2025-07-31 16:12:00','start_check',0,'2025-07-14 16:13:58'),
(12,33,'2025-07-31 19:13:00','end_check',0,'2025-07-14 16:13:58'),
(17,40,'2025-07-16 05:42:00','start_check',0,'2025-07-15 14:51:31'),
(18,40,'2025-07-16 06:42:00','end_check',0,'2025-07-15 14:51:31'),
(25,44,'2025-07-16 08:30:00','start_check',0,'2025-07-15 16:07:52'),
(26,44,'2025-07-16 09:22:00','end_check',0,'2025-07-15 16:07:52'),
(43,47,'2025-07-17 10:14:16','start_check',0,'2025-07-16 16:37:08'),
(44,47,'2025-07-17 10:44:16','end_check',0,'2025-07-16 16:37:08');

/*Table structure for table `banks` */

DROP TABLE IF EXISTS `banks`;

CREATE TABLE `banks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `code` varchar(10) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `banks` */

/*Table structure for table `chamas` */

DROP TABLE IF EXISTS `chamas`;

CREATE TABLE `chamas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `monthly_contribution` decimal(10,2) NOT NULL,
  `meeting_fee` decimal(10,2) DEFAULT 0.00,
  `late_fine` decimal(10,2) DEFAULT 0.00,
  `absent_fine` decimal(10,2) DEFAULT 0.00,
  `meeting_day` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `rules` mediumtext DEFAULT NULL,
  `admin_id` int(11) NOT NULL DEFAULT 2,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `fk_chamas_admin` (`admin_id`),
  CONSTRAINT `fk_chamas_admin` FOREIGN KEY (`admin_id`) REFERENCES `members` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `chamas` */

insert  into `chamas`(`id`,`name`,`monthly_contribution`,`meeting_fee`,`late_fine`,`absent_fine`,`meeting_day`,`created_at`,`updated_at`,`rules`,`admin_id`) values 
(1,'mbogo_family',500.00,100.00,50.00,100.00,'first sunday of every month','2025-07-09 05:51:37','2025-07-09 05:51:37','MBOGO FAMILY CHAMA RULES AND REGULATIONS\r\n\r\nFINANCIAL CONTRIBUTIONS:\r\n1. Monthly Contribution: Every member must contribute KSH 500 on or before the monthly meeting\r\n2. Meeting Fee: KSH 100 attendance fee for every meeting\r\n3. Late Fine: KSH 50 penalty for arriving late to meetings\r\n4. Absence Fine: KSH 100 penalty for missing a meeting without prior notice\r\n\r\nMEETING GUIDELINES:\r\n- Meetings are held on the first Sunday of every month\r\n- Members must arrive on time to avoid late fines\r\n- Advance notice of absence (24 hours minimum) may waive the absence fine\r\n- All financial contributions must be made \r\n\r\nGENERAL CONDUCT:\r\n- Respect all members and maintain confidentiality\r\n- Active participation in discussions is encouraged\r\n\r\n\r\nEMERGENCY SUPPORT:\r\n- Emergency fund available for members facing genuine hardships\r\n- Medical emergency support available with proper documentation\r\n- Family emergency support for immediate family members\r\n\r\nDISCIPLINE AND PENALTIES:\r\n- All fines must be paid before next meeting\r\n\r\nAMENDMENTS:\r\n- Rule changes require 80% member approval\r\n- Annual review of rules and regulations\r\n- Suggestions for improvements are welcome\r\n\r\nRemember: Unity, Trust, and Prosperity for all members!',2),
(2,'Test Chama Delta',1000.00,50.00,50.00,100.00,'Friday','2025-07-11 13:46:40','2025-07-11 13:46:40','Test chama rules: Be punctual, contribute monthly, attend all meetings',2),
(4,'testing on monday',1000.00,50.00,50.00,100.00,'Friday','2025-07-14 05:38:13','2025-07-14 05:38:13','Test chama rules: Be punctual, contribute monthly, attend all meetings',2),
(5,'testing on at 6 oclock',1000.00,50.00,50.00,100.00,'Friday','2025-07-14 06:04:57','2025-07-14 06:04:57','Test chama rules: Be punctual, contribute monthly, attend all meetings',2);

/*Table structure for table `contributions` */

DROP TABLE IF EXISTS `contributions`;

CREATE TABLE `contributions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `meeting_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `contribution_type` enum('monthly','meeting_fee','fine','extra') DEFAULT 'monthly',
  `payment_method` varchar(50) DEFAULT 'cash',
  `paid_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `member_id` (`member_id`),
  KEY `contributions_ibfk_2` (`meeting_id`),
  CONSTRAINT `contributions_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE,
  CONSTRAINT `contributions_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `contributions` */

/*Table structure for table `emergency_fund_contributions` */

DROP TABLE IF EXISTS `emergency_fund_contributions`;

CREATE TABLE `emergency_fund_contributions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `emergency_fund_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method_id` int(11) NOT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `payment_date` datetime DEFAULT NULL,
  `status` enum('pending','paid','failed') DEFAULT 'pending',
  `deducted_from_deposits` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_member_fund` (`emergency_fund_id`,`member_id`),
  KEY `member_id` (`member_id`),
  KEY `payment_method_id` (`payment_method_id`),
  CONSTRAINT `emergency_fund_contributions_ibfk_1` FOREIGN KEY (`emergency_fund_id`) REFERENCES `emergency_funds` (`id`),
  CONSTRAINT `emergency_fund_contributions_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `emergency_fund_contributions_ibfk_3` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `emergency_fund_contributions` */

/*Table structure for table `emergency_funds` */

DROP TABLE IF EXISTS `emergency_funds`;

CREATE TABLE `emergency_funds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chama_id` int(11) NOT NULL,
  `fund_name` varchar(100) NOT NULL,
  `target_amount` decimal(15,2) NOT NULL,
  `current_amount` decimal(15,2) DEFAULT 0.00,
  `per_member_contribution` decimal(10,2) NOT NULL,
  `status` enum('active','completed','cancelled') DEFAULT 'active',
  `purpose` text NOT NULL,
  `created_by` int(11) NOT NULL,
  `approved_meeting_id` int(11) DEFAULT NULL,
  `target_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `chama_id` (`chama_id`),
  KEY `created_by` (`created_by`),
  KEY `emergency_funds_ibfk_3` (`approved_meeting_id`),
  CONSTRAINT `emergency_funds_ibfk_1` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`),
  CONSTRAINT `emergency_funds_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `members` (`id`),
  CONSTRAINT `emergency_funds_ibfk_3` FOREIGN KEY (`approved_meeting_id`) REFERENCES `meetings` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `emergency_funds` */

/*Table structure for table `fines` */

DROP TABLE IF EXISTS `fines`;

CREATE TABLE `fines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `meeting_id` int(11) NOT NULL,
  `fine_type` enum('late','absent') NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_member_meeting` (`member_id`,`meeting_id`),
  KEY `fines_ibfk_2` (`meeting_id`),
  CONSTRAINT `fines_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `fines_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `fines` */

insert  into `fines`(`id`,`member_id`,`meeting_id`,`fine_type`,`amount`,`created_at`,`updated_at`) values 
(1,2,4,'absent',100.00,'2025-07-11 13:39:30','2025-07-11 13:39:30'),
(2,3,4,'absent',100.00,'2025-07-11 13:39:30','2025-07-11 13:39:30'),
(3,7,5,'absent',100.00,'2025-07-11 13:56:36','2025-07-11 13:56:36'),
(4,8,5,'absent',100.00,'2025-07-11 13:56:36','2025-07-11 13:56:36'),
(5,13,27,'absent',100.00,'2025-07-14 06:21:01','2025-07-14 06:21:01'),
(6,14,27,'absent',100.00,'2025-07-14 06:21:01','2025-07-14 06:21:01'),
(7,15,27,'absent',100.00,'2025-07-14 06:21:01','2025-07-14 06:21:01');

/*Table structure for table `meeting_attendance` */

DROP TABLE IF EXISTS `meeting_attendance`;

CREATE TABLE `meeting_attendance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `attendance_status` enum('present','late','absent') DEFAULT 'absent',
  `arrival_time` datetime DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_member_meeting` (`meeting_id`,`member_id`),
  KEY `member_id` (`member_id`),
  CONSTRAINT `meeting_attendance_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `meeting_attendance_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `meeting_attendance` */

insert  into `meeting_attendance`(`id`,`meeting_id`,`member_id`,`attendance_status`,`arrival_time`,`notes`,`created_at`) values 
(62,47,16,'present','2025-07-16 16:37:12','Arrival is ontime','2025-07-16 16:37:12'),
(63,47,2,'present','2025-07-16 16:37:17','Arrival is ontime','2025-07-16 16:37:17'),
(64,47,3,'present','2025-07-16 16:37:20','Arrival is ontime','2025-07-16 16:37:20');

/*Table structure for table `meeting_fees` */

DROP TABLE IF EXISTS `meeting_fees`;

CREATE TABLE `meeting_fees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `meeting_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 100.00,
  `payment_method_id` int(11) NOT NULL,
  `payment_date` datetime DEFAULT NULL,
  `status` enum('pending','paid') DEFAULT 'pending',
  `collected_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `member_id` (`member_id`),
  KEY `payment_method_id` (`payment_method_id`),
  KEY `collected_by` (`collected_by`),
  KEY `meeting_fees_ibfk_2` (`meeting_id`),
  CONSTRAINT `meeting_fees_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `meeting_fees_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `meeting_fees_ibfk_3` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_types` (`id`),
  CONSTRAINT `meeting_fees_ibfk_4` FOREIGN KEY (`collected_by`) REFERENCES `members` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `meeting_fees` */

insert  into `meeting_fees`(`id`,`member_id`,`meeting_id`,`amount`,`payment_method_id`,`payment_date`,`status`,`collected_by`,`notes`,`created_at`) values 
(10,16,47,100.00,1,NULL,'pending',NULL,'pending payment','2025-07-16 16:37:12'),
(11,2,47,100.00,1,NULL,'pending',NULL,'pending payment','2025-07-16 16:37:17'),
(12,3,47,100.00,1,NULL,'pending',NULL,'pending payment','2025-07-16 16:37:20');

/*Table structure for table `meeting_financials` */

DROP TABLE IF EXISTS `meeting_financials`;

CREATE TABLE `meeting_financials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) NOT NULL,
  `chama_id` int(11) NOT NULL,
  `total_contributions_expected` decimal(15,2) DEFAULT 0.00,
  `total_contributions_collected` decimal(15,2) DEFAULT 0.00,
  `contributions_count_paid` int(11) DEFAULT 0,
  `contributions_count_pending` int(11) DEFAULT 0,
  `total_meeting_fees_expected` decimal(15,2) DEFAULT 0.00,
  `total_meeting_fees_collected` decimal(15,2) DEFAULT 0.00,
  `meeting_fees_count_paid` int(11) DEFAULT 0,
  `meeting_fees_count_pending` int(11) DEFAULT 0,
  `total_fines_expected` decimal(15,2) DEFAULT 0.00,
  `total_fines_collected` decimal(15,2) DEFAULT 0.00,
  `fines_count_paid` int(11) DEFAULT 0,
  `fines_count_pending` int(11) DEFAULT 0,
  `total_debts_outstanding` decimal(15,2) DEFAULT 0.00,
  `total_debts_paid` decimal(15,2) DEFAULT 0.00,
  `debts_count_outstanding` int(11) DEFAULT 0,
  `debts_count_paid` int(11) DEFAULT 0,
  `total_cash_collected` decimal(15,2) DEFAULT 0.00,
  `total_mobile_collected` decimal(15,2) DEFAULT 0.00,
  `grand_total_collected` decimal(15,2) DEFAULT 0.00,
  `members_present` int(11) DEFAULT 0,
  `members_late` int(11) DEFAULT 0,
  `members_absent` int(11) DEFAULT 0,
  `total_members` int(11) DEFAULT 0,
  `is_finalized` tinyint(1) DEFAULT 0,
  `finalized_by` int(11) DEFAULT NULL,
  `finalized_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_meeting_financials` (`meeting_id`),
  KEY `chama_id` (`chama_id`),
  KEY `finalized_by` (`finalized_by`),
  CONSTRAINT `meeting_financials_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `meeting_financials_ibfk_2` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`),
  CONSTRAINT `meeting_financials_ibfk_3` FOREIGN KEY (`finalized_by`) REFERENCES `members` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `meeting_financials` */

insert  into `meeting_financials`(`id`,`meeting_id`,`chama_id`,`total_contributions_expected`,`total_contributions_collected`,`contributions_count_paid`,`contributions_count_pending`,`total_meeting_fees_expected`,`total_meeting_fees_collected`,`meeting_fees_count_paid`,`meeting_fees_count_pending`,`total_fines_expected`,`total_fines_collected`,`fines_count_paid`,`fines_count_pending`,`total_debts_outstanding`,`total_debts_paid`,`debts_count_outstanding`,`debts_count_paid`,`total_cash_collected`,`total_mobile_collected`,`grand_total_collected`,`members_present`,`members_late`,`members_absent`,`total_members`,`is_finalized`,`finalized_by`,`finalized_at`,`created_at`,`updated_at`) values 
(1,3,1,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,2,0,NULL,NULL,'2025-07-10 16:20:51','2025-07-10 16:20:51'),
(2,4,1,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,2,0,NULL,NULL,'2025-07-11 13:36:48','2025-07-11 13:36:48'),
(3,5,2,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,5,0,NULL,NULL,'2025-07-11 13:48:42','2025-07-11 13:48:42'),
(4,10,1,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,2,0,NULL,NULL,'2025-07-14 05:15:04','2025-07-14 05:15:04'),
(5,12,2,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,5,0,NULL,NULL,'2025-07-14 05:26:06','2025-07-14 05:26:06'),
(6,22,4,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,0,0,NULL,NULL,'2025-07-14 05:38:51','2025-07-14 05:38:51'),
(7,27,5,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,3,0,NULL,NULL,'2025-07-14 06:15:56','2025-07-14 06:15:56'),
(10,33,1,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,3,0,NULL,NULL,'2025-07-14 16:13:58','2025-07-14 16:13:58'),
(13,40,1,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,3,0,NULL,NULL,'2025-07-15 14:51:31','2025-07-15 14:51:31'),
(17,44,1,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,3,0,NULL,NULL,'2025-07-15 16:07:52','2025-07-15 16:07:52'),
(20,47,1,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,3,0,NULL,NULL,'2025-07-16 12:38:25','2025-07-16 12:38:25');

/*Table structure for table `meetings` */

DROP TABLE IF EXISTS `meetings`;

CREATE TABLE `meetings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chama_id` int(11) NOT NULL,
  `meeting_date` datetime NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `venue` varchar(255) DEFAULT NULL,
  `agenda` text DEFAULT NULL,
  `status` enum('scheduled','completed','cancelled') DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_chama_meeting` (`chama_id`,`meeting_date`),
  CONSTRAINT `fk_meetings_chama` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`),
  CONSTRAINT `meetings_ibfk_1` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `meetings` */

insert  into `meetings`(`id`,`chama_id`,`meeting_date`,`start_time`,`end_time`,`venue`,`agenda`,`status`,`created_at`,`updated_at`,`created_by`) values 
(3,1,'2023-10-21 00:00:00','00:00:00','00:00:00','Conference Room A','Monthly strategy meeting','scheduled','2025-07-10 16:20:51','2025-07-10 16:20:51',1),
(4,1,'2025-07-11 00:00:00','13:38:48','13:41:48','Conference Room A','Test meeting for attendance procedure validation','completed','2025-07-11 13:36:48','2025-07-11 13:56:36',1),
(5,2,'2025-07-11 00:00:00','13:50:42','13:53:42','Conference Room A','Monthly Planning Meeting - Real-time Test','completed','2025-07-11 13:48:42','2025-07-11 13:50:47',1),
(10,1,'2025-07-14 00:00:00','05:15:04','05:20:04','Conference Room A','Quick sync meeting for updates','scheduled','2025-07-14 05:15:04','2025-07-14 05:15:04',1),
(12,2,'2025-07-14 00:00:00','05:26:06','05:31:06','Conference Room A','Quick sync meeting for updates','scheduled','2025-07-14 05:26:06','2025-07-14 05:26:06',1),
(22,4,'2025-07-14 00:00:00','05:38:51','05:43:51','Conference Room A','Quick sync meeting for updates','scheduled','2025-07-14 05:38:51','2025-07-14 05:38:51',1),
(27,5,'2025-07-14 00:00:00','06:20:56','06:25:56','Community Hall','Discuss monthly contributions and new members','completed','2025-07-14 06:15:56','2025-07-14 06:26:01',1),
(33,1,'2025-07-31 00:00:00','16:12:00','19:13:00','Habanos','Where is the HR?','scheduled','2025-07-14 16:13:58','2025-07-14 16:13:58',2),
(40,1,'2025-07-15 14:51:00','14:51:00','15:51:00','kapslab','yeez','scheduled','2025-07-15 14:51:31','2025-07-15 14:51:31',2),
(44,1,'2025-07-15 16:15:00','16:15:00','17:07:00','home','app is crahing','scheduled','2025-07-15 16:07:52','2025-07-15 16:07:52',2),
(47,1,'2025-07-16 17:07:08','17:07:08','17:37:08','home','to test','scheduled','2025-07-16 12:38:25','2025-07-16 16:37:08',2);

/*Table structure for table `member_debts` */

DROP TABLE IF EXISTS `member_debts`;

CREATE TABLE `member_debts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `meeting_id` int(11) NOT NULL,
  `debt_type` enum('monthly_contribution','meeting_fee','late_fine','absent_fine') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `is_paid` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `paid_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `member_id` (`member_id`),
  KEY `member_debts_ibfk_2` (`meeting_id`),
  CONSTRAINT `member_debts_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE,
  CONSTRAINT `member_debts_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `member_debts` */

insert  into `member_debts`(`id`,`member_id`,`meeting_id`,`debt_type`,`amount`,`is_paid`,`created_at`,`paid_at`) values 
(1,16,47,'meeting_fee',100.00,0,'2025-07-16 16:37:12',NULL),
(2,2,47,'meeting_fee',100.00,0,'2025-07-16 16:37:17',NULL),
(3,3,47,'meeting_fee',100.00,0,'2025-07-16 16:37:20',NULL);

/*Table structure for table `member_deposits` */

DROP TABLE IF EXISTS `member_deposits`;

CREATE TABLE `member_deposits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `chama_id` int(11) NOT NULL,
  `total_contributions` decimal(15,2) DEFAULT 0.00,
  `total_meeting_fees` decimal(15,2) DEFAULT 0.00,
  `total_fines` decimal(15,2) DEFAULT 0.00,
  `investment_share` decimal(15,2) DEFAULT 0.00,
  `emergency_fund_contribution` decimal(15,2) DEFAULT 0.00,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_member_chama` (`member_id`,`chama_id`),
  KEY `chama_id` (`chama_id`),
  CONSTRAINT `member_deposits_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `member_deposits_ibfk_2` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `member_deposits` */

/*Table structure for table `members` */

DROP TABLE IF EXISTS `members`;

CREATE TABLE `members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chama_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phoneNumber` varchar(20) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `joined_date` date DEFAULT curdate(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `status` enum('active','inactive') DEFAULT 'active',
  `role` varchar(255) NOT NULL DEFAULT 'member',
  PRIMARY KEY (`id`),
  UNIQUE KEY `phonenumber` (`phoneNumber`),
  UNIQUE KEY `phoneNumber_2` (`phoneNumber`),
  KEY `chama_id` (`chama_id`),
  CONSTRAINT `members_ibfk_1` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `members` */

insert  into `members`(`id`,`chama_id`,`name`,`phoneNumber`,`password_hash`,`is_active`,`joined_date`,`created_at`,`updated_at`,`status`,`role`) values 
(2,1,'davidkimemiathuku','0769922984','$2b$10$eN3scLFxrIHNn8xhfr9RFeHfrYYIBpHYHYi.BFCKJ6g3cL.9WaoBG',1,'2025-07-10','2025-07-10 09:45:25','2025-07-14 11:51:52','active','admin'),
(3,1,'GraceNgere','0796679887','$2b$10$kUjqbh.7NINi2MIF/.1R5ubvMp4wPTEP5GJUDidc/UqR8Zrc2Fiau',1,'2025-07-10','2025-07-10 10:17:14','2025-07-10 10:17:14','active','member'),
(4,2,'Alice Johnson','0712345678','$2y$10$example_hash_alice',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active','member'),
(5,2,'Bob Smith','0723456789','$2y$10$example_hash_bob',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active','member'),
(6,2,'Carol Davis','0734567890','$2y$10$example_hash_carol',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active','member'),
(7,2,'David Wilson','0745678901','$2y$10$example_hash_david',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active','member'),
(8,2,'Eve Brown','0756789012','$2y$10$example_hash_eve',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active','member'),
(9,2,'Frank Miller','0767890123','$2y$10$example_hash_frank',0,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','inactive','member'),
(13,5,'John Doe','0723456781','4dbd5e49147b5102ee2731ac03dd0db7decc3b8715c3df3c1f3ddc62dcbcf86d',1,'2025-07-14','2025-07-14 06:09:03','2025-07-14 06:09:03','active','member'),
(14,5,'mesh Doe','07234545781','4dbd5e49147b5102ee2731ac03dd0db7decc3b8715c3df3c1f3ddc62dcbcf86d',1,'2025-07-14','2025-07-14 06:11:04','2025-07-14 06:11:04','active','member'),
(15,5,'mesh again','079804545781','4dbd5e49147b5102ee2731ac03dd0db7decc3b8715c3df3c1f3ddc62dcbcf86d',1,'2025-07-14','2025-07-14 06:11:21','2025-07-14 06:11:21','active','member'),
(16,1,'sampleuser','0787654321','$2b$10$SAJx8UZJwCr2sfCGqPJjUeZFtzStFLPgRVyWZSqrn/gqU6aUdHcNS',1,'2025-07-14','2025-07-14 13:02:01','2025-07-14 13:02:01','active','member');

/*Table structure for table `paybills` */

DROP TABLE IF EXISTS `paybills`;

CREATE TABLE `paybills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chama_id` int(11) NOT NULL,
  `provider` varchar(50) NOT NULL,
  `paybill_number` varchar(20) NOT NULL,
  `account_number` varchar(50) DEFAULT NULL,
  `business_name` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `chama_id` (`chama_id`),
  CONSTRAINT `paybills_ibfk_1` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `paybills` */

/*Table structure for table `payedfines` */

DROP TABLE IF EXISTS `payedfines`;

CREATE TABLE `payedfines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `member_id` int(11) NOT NULL,
  `meeting_id` int(11) NOT NULL,
  `fine_type` enum('late','absent') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_types_id` int(11) NOT NULL,
  `paybill_id` int(11) NOT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `payment_date` datetime DEFAULT NULL,
  `status` enum('pending','paid','failed','waived') DEFAULT 'pending',
  `reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_member_meeting` (`member_id`,`meeting_id`),
  KEY `payment_types_id` (`payment_types_id`),
  KEY `paybill_id` (`paybill_id`),
  KEY `payedfines_ibfk_2` (`meeting_id`),
  CONSTRAINT `payedfines_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `payedfines_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `payedfines_ibfk_3` FOREIGN KEY (`payment_types_id`) REFERENCES `payment_types` (`id`),
  CONSTRAINT `payedfines_ibfk_4` FOREIGN KEY (`paybill_id`) REFERENCES `paybills` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `payedfines` */

/*Table structure for table `payment_types` */

DROP TABLE IF EXISTS `payment_types`;

CREATE TABLE `payment_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `payment_types` */

insert  into `payment_types`(`id`,`name`,`description`,`is_active`) values 
(1,'cash','Cash payments',1),
(2,'mobile','Mobile money payments (M-Pesa, Airtel Money)',1),
(3,'bank','Bank transfers',1);

/*Table structure for table `system_logs` */

DROP TABLE IF EXISTS `system_logs`;

CREATE TABLE `system_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `system_logs` */

insert  into `system_logs`(`id`,`message`,`created_at`) values 
(1,'Scheduled attendance checks for meeting ID: 27','2025-07-14 06:15:56'),
(2,'Processed meeting start for meeting ID: 27','2025-07-14 06:21:01'),
(3,'ProcessScheduledChecks: Processed 1 schedules','2025-07-14 06:21:01'),
(4,'Processed meeting end for meeting ID: 27','2025-07-14 06:26:01'),
(5,'ProcessScheduledChecks: Processed 1 schedules','2025-07-14 06:26:01'),
(6,'Scheduled attendance checks for meeting ID: 30','2025-07-14 15:54:21'),
(7,'Scheduled attendance checks for meeting ID: 32','2025-07-14 16:05:30'),
(8,'Scheduled attendance checks for meeting ID: 33','2025-07-14 16:13:58'),
(9,'Scheduled attendance checks for meeting ID: 38','2025-07-15 12:43:04'),
(10,'Scheduled attendance checks for meeting ID: 39','2025-07-15 14:41:49'),
(11,'Scheduled attendance checks for meeting ID: 40','2025-07-15 14:51:31'),
(12,'Scheduled attendance checks for meeting ID: 41','2025-07-15 14:54:01'),
(13,'Scheduled attendance checks for meeting ID: 42','2025-07-15 15:00:27'),
(14,'Scheduled attendance checks for meeting ID: 43','2025-07-15 15:39:26'),
(15,'Scheduled attendance checks for meeting ID: 44','2025-07-15 16:07:52'),
(16,'Scheduled attendance checks for meeting ID: 45','2025-07-16 10:17:56'),
(17,'Scheduled attendance checks for meeting ID: 46','2025-07-16 10:39:50'),
(18,'Scheduled attendance checks for meeting ID: 47','2025-07-16 12:38:25'),
(19,'Scheduled attendance checks for meeting ID: 47','2025-07-16 14:37:51'),
(20,'Scheduled attendance checks for meeting ID: 47','2025-07-16 15:10:18'),
(21,'Scheduled attendance checks for meeting ID: 47','2025-07-16 15:57:09'),
(22,'Scheduled attendance checks for meeting ID: 47','2025-07-16 15:57:48'),
(23,'Scheduled attendance checks for meeting ID: 47','2025-07-16 16:27:17'),
(24,'Scheduled attendance checks for meeting ID: 47','2025-07-16 16:37:08');

/* Trigger structure for table `meeting_attendance` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `update_meeting_financials_attendance` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `update_meeting_financials_attendance` AFTER UPDATE ON `meeting_attendance` FOR EACH ROW 
BEGIN
    UPDATE meeting_financials mf
    SET 
        members_present = (
            SELECT COUNT(*) FROM meeting_attendance 
            WHERE meeting_id = NEW.meeting_id AND attendance_status = 'present'
        ),
        members_late = (
            SELECT COUNT(*) FROM meeting_attendance 
            WHERE meeting_id = NEW.meeting_id AND attendance_status = 'late'
        ),
        members_absent = (
            SELECT COUNT(*) FROM meeting_attendance 
            WHERE meeting_id = NEW.meeting_id AND attendance_status = 'absent'
        ),
        total_fines_expected = (
            SELECT COALESCE(SUM(CASE 
                WHEN ma.attendance_status = 'late' THEN 50 
                WHEN ma.attendance_status = 'absent' THEN 100 
                ELSE 0 
            END), 0)
            FROM meeting_attendance ma 
            WHERE ma.meeting_id = NEW.meeting_id
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE mf.meeting_id = NEW.meeting_id;
END */$$


DELIMITER ;

/* Trigger structure for table `meeting_fees` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `create_meeting_fee_debt` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `create_meeting_fee_debt` AFTER INSERT ON `meeting_fees` FOR EACH ROW 
BEGIN
    IF NEW.status = 'pending' AND NEW.payment_date IS NULL THEN
        INSERT INTO member_debts (
            member_id,
            meeting_id,
            debt_type,
            amount
        )
        SELECT
            NEW.member_id,
            NEW.meeting_id,
            'meeting_fee',
            NEW.amount
        FROM meetings m
        WHERE m.id = NEW.meeting_id;
    END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `meeting_fees` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `update_member_deposits_meeting_fee` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `update_member_deposits_meeting_fee` AFTER UPDATE ON `meeting_fees` FOR EACH ROW 
BEGIN
    IF NEW.status = 'paid' AND OLD.status != 'paid' THEN
        INSERT INTO member_deposits (member_id, chama_id, total_meeting_fees)
        SELECT NEW.member_id, m.chama_id, NEW.amount
        FROM meetings m WHERE m.id = NEW.meeting_id
        ON DUPLICATE KEY UPDATE 
            total_meeting_fees = total_meeting_fees + NEW.amount,
            last_updated = CURRENT_TIMESTAMP;
    END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `meeting_fees` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `update_meeting_financials_meeting_fees` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `update_meeting_financials_meeting_fees` AFTER UPDATE ON `meeting_fees` FOR EACH ROW 
BEGIN
    IF NEW.status != OLD.status THEN
        UPDATE meeting_financials mf
        SET 
            total_meeting_fees_expected = (
                SELECT COUNT(*) * 100 FROM members m 
                JOIN meetings mt ON mt.chama_id = m.chama_id 
                WHERE mt.id = NEW.meeting_id AND m.status = 'active'
            ),
            total_meeting_fees_collected = (
                SELECT COALESCE(SUM(amount), 0) FROM meeting_fees 
                WHERE meeting_id = NEW.meeting_id AND status = 'paid'
            ),
            meeting_fees_count_paid = (
                SELECT COUNT(*) FROM meeting_fees 
                WHERE meeting_id = NEW.meeting_id AND status = 'paid'
            ),
            meeting_fees_count_pending = (
                SELECT COUNT(*) FROM meeting_fees 
                WHERE meeting_id = NEW.meeting_id AND status = 'pending'
            ),
            total_cash_collected = (
                SELECT COALESCE(SUM(amount), 0) FROM meeting_fees 
                WHERE meeting_id = NEW.meeting_id AND status = 'paid'
            ),
            updated_at = CURRENT_TIMESTAMP
        WHERE mf.meeting_id = NEW.meeting_id;
    END IF;
END */$$


DELIMITER ;

/* Trigger structure for table `meeting_financials` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `calculate_grand_total` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `calculate_grand_total` BEFORE UPDATE ON `meeting_financials` FOR EACH ROW 
BEGIN
    SET NEW.grand_total_collected = NEW.total_cash_collected + NEW.total_mobile_collected;
END */$$


DELIMITER ;

/* Trigger structure for table `meetings` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `initialize_meeting_financials` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `initialize_meeting_financials` AFTER INSERT ON `meetings` FOR EACH ROW 
BEGIN
    INSERT INTO meeting_financials (meeting_id, chama_id, total_members)
    SELECT NEW.id, NEW.chama_id, COUNT(*)
    FROM members m WHERE m.chama_id = NEW.chama_id AND m.status = 'active';
END */$$


DELIMITER ;

/* Trigger structure for table `meetings` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `after_meeting_insert` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `after_meeting_insert` AFTER INSERT ON `meetings` FOR EACH ROW 
BEGIN
    CALL ScheduleAttendanceChecks(NEW.id);
END */$$


DELIMITER ;

/* Trigger structure for table `meetings` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `after_meeting_update` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `after_meeting_update` AFTER UPDATE ON `meetings` FOR EACH ROW 
BEGIN
    -- Only reschedule if meeting time changed and meeting hasn't started
    IF (OLD.meeting_date != NEW.meeting_date OR OLD.start_time != NEW.start_time OR OLD.end_time != NEW.end_time) 
       AND TIMESTAMP(NEW.meeting_date, NEW.start_time) > NOW() THEN
        
        -- Delete old unprocessed schedules
        DELETE FROM attendance_schedules 
        WHERE meeting_id = NEW.id AND is_processed = FALSE;
        
        -- Create new schedules
        CALL ScheduleAttendanceChecks(NEW.id);
    END IF;
END */$$


DELIMITER ;

/*!50106 set global event_scheduler = 1*/;

/* Event structure for event `ProcessAttendanceChecks` */

/*!50106 DROP EVENT IF EXISTS `ProcessAttendanceChecks`*/;

DELIMITER $$

/*!50106 CREATE DEFINER=`root`@`localhost` EVENT `ProcessAttendanceChecks` ON SCHEDULE EVERY 2 MINUTE STARTS '2025-07-11 13:21:50' ON COMPLETION NOT PRESERVE ENABLE DO CALL ProcessScheduledChecks() */$$
DELIMITER ;

/* Event structure for event `process_attendance_checks` */

/*!50106 DROP EVENT IF EXISTS `process_attendance_checks`*/;

DELIMITER $$

/*!50106 CREATE DEFINER=`root`@`localhost` EVENT `process_attendance_checks` ON SCHEDULE EVERY 30 SECOND STARTS '2025-07-14 05:49:01' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    CALL ProcessScheduledChecks();
END */$$
DELIMITER ;

/* Event structure for event `run_attendance_checks` */

/*!50106 DROP EVENT IF EXISTS `run_attendance_checks`*/;

DELIMITER $$

/*!50106 CREATE DEFINER=`root`@`localhost` EVENT `run_attendance_checks` ON SCHEDULE EVERY 1 MINUTE STARTS '2025-07-11 13:56:36' ON COMPLETION NOT PRESERVE ENABLE DO CALL ProcessScheduledChecks() */$$
DELIMITER ;

/* Procedure structure for procedure `CheckMeetingEnd` */

/*!50003 DROP PROCEDURE IF EXISTS  `CheckMeetingEnd` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckMeetingEnd`(IN target_meeting_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE member_id_var INT;
    DECLARE late_fine_amount DECIMAL(10,2);
    
    -- Cursor for members who arrived but were marked absent
    DECLARE attendee_cursor CURSOR FOR
        SELECT DISTINCT a.member_id
        FROM attendance a
        JOIN fines f ON a.member_id = f.member_id AND a.meeting_id = f.meeting_id
        WHERE a.meeting_id = target_meeting_id
        AND f.fine_type = 'absent';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Get late fine amount
    SELECT c.late_fine 
    INTO late_fine_amount
    FROM meetings m
    JOIN chamas c ON m.chama_id = c.id
    WHERE m.id = target_meeting_id;
    
    OPEN attendee_cursor;
    
    attendee_loop: LOOP
        FETCH attendee_cursor INTO member_id_var;
        IF done THEN
            LEAVE attendee_loop;
        END IF;
        
        -- Change absent fine to late fine
        UPDATE fines 
        SET fine_type = 'late', 
            amount = late_fine_amount,
            updated_at = CURRENT_TIMESTAMP
        WHERE meeting_id = target_meeting_id 
        AND member_id = member_id_var
        AND fine_type = 'absent';
        
    END LOOP attendee_loop;
    
    CLOSE attendee_cursor;
    
    -- Update meeting status to completed
    UPDATE meetings 
    SET status = 'completed' 
    WHERE id = target_meeting_id;
    
    -- Mark end check as processed
    UPDATE attendance_schedules 
    SET is_processed = TRUE 
    WHERE meeting_id = target_meeting_id 
    AND check_type = 'end_check';
    
    -- Log the processing
    INSERT INTO system_logs (message) 
    VALUES (CONCAT('Processed meeting end for meeting ID: ', target_meeting_id));
    
END */$$
DELIMITER ;

/* Procedure structure for procedure `CheckMeetingStart` */

/*!50003 DROP PROCEDURE IF EXISTS  `CheckMeetingStart` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckMeetingStart`(IN target_meeting_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE chama_id_var INT;
    DECLARE member_id_var INT;
    DECLARE absent_fine_amount DECIMAL(10,2);
    
    -- Cursor for active members
    DECLARE member_cursor CURSOR FOR
        SELECT m.id 
        FROM members m
        JOIN meetings mt ON m.chama_id = mt.chama_id
        WHERE mt.id = target_meeting_id 
        AND m.status = 'active';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Get chama details
    SELECT m.chama_id, c.absent_fine 
    INTO chama_id_var, absent_fine_amount
    FROM meetings m
    JOIN chamas c ON m.chama_id = c.id
    WHERE m.id = target_meeting_id;
    
    OPEN member_cursor;
    
    member_loop: LOOP
        FETCH member_cursor INTO member_id_var;
        IF done THEN
            LEAVE member_loop;
        END IF;
        
        -- Mark member as absent (fine will be applied)
        INSERT INTO fines (member_id, meeting_id, fine_type, amount)
        VALUES (member_id_var, target_meeting_id, 'absent', absent_fine_amount)
        ON DUPLICATE KEY UPDATE 
            fine_type = 'absent',
            amount = absent_fine_amount,
            updated_at = CURRENT_TIMESTAMP;
        
    END LOOP member_loop;
    
    CLOSE member_cursor;
    
    -- Mark start check as processed
    UPDATE attendance_schedules 
    SET is_processed = TRUE 
    WHERE meeting_id = target_meeting_id 
    AND check_type = 'start_check';
    
    -- Log the processing
    INSERT INTO system_logs (message) 
    VALUES (CONCAT('Processed meeting start for meeting ID: ', target_meeting_id));
    
END */$$
DELIMITER ;

/* Procedure structure for procedure `CleanupOldSchedules` */

/*!50003 DROP PROCEDURE IF EXISTS  `CleanupOldSchedules` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `CleanupOldSchedules`()
BEGIN
    DELETE FROM attendance_schedules 
    WHERE is_processed = TRUE 
    AND created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
END */$$
DELIMITER ;

/* Procedure structure for procedure `GetMeetingAttendanceSummary` */

/*!50003 DROP PROCEDURE IF EXISTS  `GetMeetingAttendanceSummary` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMeetingAttendanceSummary`(IN meeting_id_param INT)
BEGIN
    SELECT 
        m.name AS member_name,
        m.phoneNumber,
        CASE 
            WHEN a.member_id IS NOT NULL AND f.fine_type = 'late' THEN 'Late'
            WHEN a.member_id IS NOT NULL AND f.fine_type IS NULL THEN 'Present'
            WHEN f.fine_type = 'absent' THEN 'Absent'
            ELSE 'Unknown'
        END AS attendance_status,
        COALESCE(f.amount, 0.00) AS fine_amount,
        a.arrival_time,
        f.created_at AS fine_date
    FROM meetings mt
    JOIN members m ON m.chama_id = mt.chama_id AND m.status = 'active'
    LEFT JOIN attendance a ON a.meeting_id = mt.id AND a.member_id = m.id
    LEFT JOIN fines f ON f.meeting_id = mt.id AND f.member_id = m.id
    WHERE mt.id = meeting_id_param
    ORDER BY m.name;
END */$$
DELIMITER ;

/* Procedure structure for procedure `ManualProcessMeeting` */

/*!50003 DROP PROCEDURE IF EXISTS  `ManualProcessMeeting` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `ManualProcessMeeting`(IN meeting_id_param INT)
BEGIN
    DECLARE meeting_started BOOLEAN DEFAULT FALSE;
    DECLARE meeting_ended BOOLEAN DEFAULT FALSE;
    
    -- Check if meeting has started
    SELECT TIMESTAMP(meeting_date, start_time) <= NOW() 
    INTO meeting_started
    FROM meetings 
    WHERE id = meeting_id_param;
    
    -- Check if meeting has ended
    SELECT TIMESTAMP(meeting_date, end_time) <= NOW() 
    INTO meeting_ended
    FROM meetings 
    WHERE id = meeting_id_param;
    
    IF meeting_started THEN
        CALL CheckMeetingStart(meeting_id_param);
    END IF;
    
    IF meeting_ended THEN
        CALL CheckMeetingEnd(meeting_id_param);
    END IF;
    
    INSERT INTO system_logs (message) 
    VALUES (CONCAT('Manually processed meeting ID: ', meeting_id_param));
    
END */$$
DELIMITER ;

/* Procedure structure for procedure `ProcessScheduledChecks` */

/*!50003 DROP PROCEDURE IF EXISTS  `ProcessScheduledChecks` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `ProcessScheduledChecks`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE schedule_id INT;
    DECLARE meeting_id_var INT;
    DECLARE check_type_var VARCHAR(20);
    DECLARE processed_count INT DEFAULT 0;
    
    -- Cursor for due checks
    DECLARE check_cursor CURSOR FOR
        SELECT id, meeting_id, check_type
        FROM attendance_schedules
        WHERE check_time <= NOW()
        AND is_processed = FALSE
        ORDER BY check_time ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN check_cursor;
    
    check_loop: LOOP
        FETCH check_cursor INTO schedule_id, meeting_id_var, check_type_var;
        IF done THEN
            LEAVE check_loop;
        END IF;
        
        -- Process the appropriate check type
        IF check_type_var = 'start_check' THEN
            CALL CheckMeetingStart(meeting_id_var);
            SET processed_count = processed_count + 1;
        ELSEIF check_type_var = 'end_check' THEN
            CALL CheckMeetingEnd(meeting_id_var);
            SET processed_count = processed_count + 1;
        END IF;
        
    END LOOP check_loop;
    
    CLOSE check_cursor;
    
    -- Log if any processing occurred
    IF processed_count > 0 THEN
        INSERT INTO system_logs (message) 
        VALUES (CONCAT('ProcessScheduledChecks: Processed ', processed_count, ' schedules'));
    END IF;
    
END */$$
DELIMITER ;

/* Procedure structure for procedure `ScheduleAttendanceChecks` */

/*!50003 DROP PROCEDURE IF EXISTS  `ScheduleAttendanceChecks` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `ScheduleAttendanceChecks`(IN meeting_id_param INT)
BEGIN
    DECLARE meeting_datetime DATETIME;
    DECLARE end_datetime DATETIME;
    
    -- Get meeting start and end datetime
    SELECT 
        TIMESTAMP(meeting_date, start_time),
        TIMESTAMP(meeting_date, end_time)
    INTO meeting_datetime, end_datetime
    FROM meetings 
    WHERE id = meeting_id_param;
    
    -- Schedule start check (at meeting start time)
    INSERT INTO attendance_schedules (meeting_id, check_time, check_type)
    VALUES (meeting_id_param, meeting_datetime, 'start_check');
    
    -- Schedule end check (at meeting end time)
    INSERT INTO attendance_schedules (meeting_id, check_time, check_type)
    VALUES (meeting_id_param, end_datetime, 'end_check');
    
    -- Log the scheduling
    INSERT INTO system_logs (message) 
    VALUES (CONCAT('Scheduled attendance checks for meeting ID: ', meeting_id_param));
    
END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
