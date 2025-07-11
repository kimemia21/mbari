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
  KEY `meeting_id` (`meeting_id`),
  CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `attendance` */

insert  into `attendance`(`id`,`member_id`,`meeting_id`,`status`,`arrival_time`,`created_at`) values 
(1,4,5,'present','13:30:27','2025-07-11 13:50:27'),
(2,5,5,'present','13:32:27','2025-07-11 13:50:27'),
(3,6,5,'present','13:34:27','2025-07-11 13:50:27');

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
  KEY `meeting_id` (`meeting_id`),
  KEY `idx_check_time` (`check_time`,`is_processed`),
  CONSTRAINT `attendance_schedules_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `attendance_schedules` */

insert  into `attendance_schedules`(`id`,`meeting_id`,`check_time`,`check_type`,`is_processed`,`created_at`) values 
(1,4,'2025-07-11 13:38:48','start_check',1,'2025-07-11 13:36:48'),
(2,4,'2025-07-11 13:41:48','end_check',1,'2025-07-11 13:36:48'),
(3,5,'2025-07-11 13:50:42','start_check',1,'2025-07-11 13:48:42'),
(4,5,'2025-07-11 13:53:42','end_check',1,'2025-07-11 13:48:42');

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
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `chamas` */

insert  into `chamas`(`id`,`name`,`monthly_contribution`,`meeting_fee`,`late_fine`,`absent_fine`,`meeting_day`,`created_at`,`updated_at`,`rules`) values 
(1,'mbogo_family',500.00,100.00,50.00,100.00,'first sunday of every month','2025-07-09 05:51:37','2025-07-09 05:51:37','MBOGO FAMILY CHAMA RULES AND REGULATIONS\r\n\r\nFINANCIAL CONTRIBUTIONS:\r\n1. Monthly Contribution: Every member must contribute KSH 500 on or before the monthly meeting\r\n2. Meeting Fee: KSH 100 attendance fee for every meeting\r\n3. Late Fine: KSH 50 penalty for arriving late to meetings\r\n4. Absence Fine: KSH 100 penalty for missing a meeting without prior notice\r\n\r\nMEETING GUIDELINES:\r\n- Meetings are held on the first Sunday of every month\r\n- Members must arrive on time to avoid late fines\r\n- Advance notice of absence (24 hours minimum) may waive the absence fine\r\n- All financial contributions must be made \r\n\r\nGENERAL CONDUCT:\r\n- Respect all members and maintain confidentiality\r\n- Active participation in discussions is encouraged\r\n\r\n\r\nEMERGENCY SUPPORT:\r\n- Emergency fund available for members facing genuine hardships\r\n- Medical emergency support available with proper documentation\r\n- Family emergency support for immediate family members\r\n\r\nDISCIPLINE AND PENALTIES:\r\n- All fines must be paid before next meeting\r\n\r\nAMENDMENTS:\r\n- Rule changes require 80% member approval\r\n- Annual review of rules and regulations\r\n- Suggestions for improvements are welcome\r\n\r\nRemember: Unity, Trust, and Prosperity for all members!'),
(2,'Test Chama Delta',1000.00,50.00,50.00,100.00,'Friday','2025-07-11 13:46:40','2025-07-11 13:46:40','Test chama rules: Be punctual, contribute monthly, attend all meetings');

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
  KEY `meeting_id` (`meeting_id`),
  CONSTRAINT `contributions_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE,
  CONSTRAINT `contributions_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE
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
  KEY `approved_meeting_id` (`approved_meeting_id`),
  CONSTRAINT `emergency_funds_ibfk_1` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`),
  CONSTRAINT `emergency_funds_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `members` (`id`),
  CONSTRAINT `emergency_funds_ibfk_3` FOREIGN KEY (`approved_meeting_id`) REFERENCES `meetings` (`id`)
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
  KEY `meeting_id` (`meeting_id`),
  CONSTRAINT `fines_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `fines_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `fines` */

insert  into `fines`(`id`,`member_id`,`meeting_id`,`fine_type`,`amount`,`created_at`,`updated_at`) values 
(1,2,4,'absent',100.00,'2025-07-11 13:39:30','2025-07-11 13:39:30'),
(2,3,4,'absent',100.00,'2025-07-11 13:39:30','2025-07-11 13:39:30'),
(3,7,5,'absent',100.00,'2025-07-11 13:56:36','2025-07-11 13:56:36'),
(4,8,5,'absent',100.00,'2025-07-11 13:56:36','2025-07-11 13:56:36');

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
  CONSTRAINT `meeting_attendance_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`),
  CONSTRAINT `meeting_attendance_ibfk_2` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `meeting_attendance` */

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
  KEY `meeting_id` (`meeting_id`),
  KEY `payment_method_id` (`payment_method_id`),
  KEY `collected_by` (`collected_by`),
  CONSTRAINT `meeting_fees_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `meeting_fees_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`),
  CONSTRAINT `meeting_fees_ibfk_3` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_types` (`id`),
  CONSTRAINT `meeting_fees_ibfk_4` FOREIGN KEY (`collected_by`) REFERENCES `members` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `meeting_fees` */

insert  into `meeting_fees`(`id`,`member_id`,`meeting_id`,`amount`,`payment_method_id`,`payment_date`,`status`,`collected_by`,`notes`,`created_at`) values 
(2,2,3,100.00,1,NULL,'paid',2,'user has paided for todays meetings','2025-07-11 12:20:36');

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
  CONSTRAINT `meeting_financials_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`),
  CONSTRAINT `meeting_financials_ibfk_2` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`),
  CONSTRAINT `meeting_financials_ibfk_3` FOREIGN KEY (`finalized_by`) REFERENCES `members` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `meeting_financials` */

insert  into `meeting_financials`(`id`,`meeting_id`,`chama_id`,`total_contributions_expected`,`total_contributions_collected`,`contributions_count_paid`,`contributions_count_pending`,`total_meeting_fees_expected`,`total_meeting_fees_collected`,`meeting_fees_count_paid`,`meeting_fees_count_pending`,`total_fines_expected`,`total_fines_collected`,`fines_count_paid`,`fines_count_pending`,`total_debts_outstanding`,`total_debts_paid`,`debts_count_outstanding`,`debts_count_paid`,`total_cash_collected`,`total_mobile_collected`,`grand_total_collected`,`members_present`,`members_late`,`members_absent`,`total_members`,`is_finalized`,`finalized_by`,`finalized_at`,`created_at`,`updated_at`) values 
(1,3,1,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,2,0,NULL,NULL,'2025-07-10 16:20:51','2025-07-10 16:20:51'),
(2,4,1,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,2,0,NULL,NULL,'2025-07-11 13:36:48','2025-07-11 13:36:48'),
(3,5,2,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0,0,0.00,0.00,0.00,0,0,0,5,0,NULL,NULL,'2025-07-11 13:48:42','2025-07-11 13:48:42');

/*Table structure for table `meetings` */

DROP TABLE IF EXISTS `meetings`;

CREATE TABLE `meetings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chama_id` int(11) NOT NULL,
  `meeting_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `venue` varchar(255) DEFAULT NULL,
  `agenda` text DEFAULT NULL,
  `status` enum('scheduled','completed','cancelled') DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_chama_meeting` (`chama_id`,`meeting_date`),
  CONSTRAINT `fk_meetings_chama` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`),
  CONSTRAINT `meetings_ibfk_1` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `meetings` */

insert  into `meetings`(`id`,`chama_id`,`meeting_date`,`start_time`,`end_time`,`venue`,`agenda`,`status`,`created_at`,`updated_at`) values 
(3,1,'2023-10-21','00:00:00','00:00:00','Conference Room A','Monthly strategy meeting','scheduled','2025-07-10 16:20:51','2025-07-10 16:20:51'),
(4,1,'2025-07-11','13:38:48','13:41:48','Conference Room A','Test meeting for attendance procedure validation','completed','2025-07-11 13:36:48','2025-07-11 13:56:36'),
(5,2,'2025-07-11','13:50:42','13:53:42','Conference Room A','Monthly Planning Meeting - Real-time Test','completed','2025-07-11 13:48:42','2025-07-11 13:50:47');

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
  KEY `meeting_id` (`meeting_id`),
  CONSTRAINT `member_debts_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`) ON DELETE CASCADE,
  CONSTRAINT `member_debts_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `member_debts` */

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
  PRIMARY KEY (`id`),
  UNIQUE KEY `phonenumber` (`phoneNumber`),
  UNIQUE KEY `phoneNumber_2` (`phoneNumber`),
  KEY `chama_id` (`chama_id`),
  CONSTRAINT `members_ibfk_1` FOREIGN KEY (`chama_id`) REFERENCES `chamas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `members` */

insert  into `members`(`id`,`chama_id`,`name`,`phoneNumber`,`password_hash`,`is_active`,`joined_date`,`created_at`,`updated_at`,`status`) values 
(2,1,'davidkimemiathuku','0769922984','$2b$10$eN3scLFxrIHNn8xhfr9RFeHfrYYIBpHYHYi.BFCKJ6g3cL.9WaoBG',1,'2025-07-10','2025-07-10 09:45:25','2025-07-10 09:45:25','active'),
(3,1,'GraceNgere','0796679887','$2b$10$kUjqbh.7NINi2MIF/.1R5ubvMp4wPTEP5GJUDidc/UqR8Zrc2Fiau',1,'2025-07-10','2025-07-10 10:17:14','2025-07-10 10:17:14','active'),
(4,2,'Alice Johnson','0712345678','$2y$10$example_hash_alice',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active'),
(5,2,'Bob Smith','0723456789','$2y$10$example_hash_bob',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active'),
(6,2,'Carol Davis','0734567890','$2y$10$example_hash_carol',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active'),
(7,2,'David Wilson','0745678901','$2y$10$example_hash_david',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active'),
(8,2,'Eve Brown','0756789012','$2y$10$example_hash_eve',1,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','active'),
(9,2,'Frank Miller','0767890123','$2y$10$example_hash_frank',0,'2025-07-11','2025-07-11 13:47:33','2025-07-11 13:47:33','inactive');

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
  KEY `meeting_id` (`meeting_id`),
  KEY `payment_types_id` (`payment_types_id`),
  KEY `paybill_id` (`paybill_id`),
  CONSTRAINT `payedfines_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `members` (`id`),
  CONSTRAINT `payedfines_ibfk_2` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`),
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
        INSERT INTO member_debts (member_id, meeting_id, debt_type, amount, original_due_date, description)
        SELECT NEW.member_id, NEW.meeting_id, 'meeting_fee', NEW.amount,
               DATE(m.meeting_date),
               CONCAT('Meeting fee of KES ', NEW.amount, ' for meeting on ', DATE(m.meeting_date))
        FROM meetings m WHERE m.id = NEW.meeting_id;
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
        
        -- Delete old schedules for this meeting
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

/* Event structure for event `run_attendance_checks` */

/*!50106 DROP EVENT IF EXISTS `run_attendance_checks`*/;

DELIMITER $$

/*!50106 CREATE DEFINER=`root`@`localhost` EVENT `run_attendance_checks` ON SCHEDULE EVERY 1 MINUTE STARTS '2025-07-11 13:56:36' ON COMPLETION NOT PRESERVE ENABLE DO CALL ProcessScheduledChecks() */$$
DELIMITER ;

/* Procedure structure for procedure `CheckMeetingEnd` */

/*!50003 DROP PROCEDURE IF EXISTS  `CheckMeetingEnd` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckMeetingEnd`(IN target_meeting_id INT)
proc_label: BEGIN
    -- ALL DECLARE STATEMENTS MUST BE FIRST
    DECLARE chama_id_var INT;
    DECLARE member_id_var INT;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor declaration AFTER all other declares
    DECLARE member_cursor CURSOR FOR
        SELECT id 
        FROM members 
        WHERE chama_id = chama_id_var 
        AND status = 'active';
    
    -- Handler declaration AFTER cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Get chama_id for the meeting
    SELECT chama_id INTO chama_id_var 
    FROM meetings 
    WHERE id = target_meeting_id;
    
    -- If chama_id not found, exit
    IF chama_id_var IS NULL THEN
        LEAVE proc_label;
    END IF;
    
    OPEN member_cursor;
    
    member_loop: LOOP
        FETCH member_cursor INTO member_id_var;
        IF done THEN
            LEAVE member_loop;
        END IF;
        
        -- Check if member is in attendance table but was marked absent at start
        IF EXISTS (
            SELECT 1 
            FROM attendance 
            WHERE meeting_id = target_meeting_id 
            AND member_id = member_id_var
        ) AND EXISTS (
            SELECT 1 
            FROM fines 
            WHERE meeting_id = target_meeting_id 
            AND member_id = member_id_var 
            AND fine_type = 'absent'
        ) THEN
            -- Member arrived late but was marked absent - change to late fine
            UPDATE fines 
            SET fine_type = 'late', 
                amount = 50.00, 
                updated_at = CURRENT_TIMESTAMP
            WHERE meeting_id = target_meeting_id 
            AND member_id = member_id_var;
        END IF;
        
    END LOOP member_loop;
    
    CLOSE member_cursor;
    
    -- Update meeting status to completed
    UPDATE meetings 
    SET status = 'completed' 
    WHERE id = target_meeting_id;
    
    -- Mark this end check as processed
    UPDATE attendance_schedules 
    SET is_processed = TRUE 
    WHERE meeting_id = target_meeting_id 
    AND check_type = 'end_check';
    
END */$$
DELIMITER ;

/* Procedure structure for procedure `CheckMeetingStart` */

/*!50003 DROP PROCEDURE IF EXISTS  `CheckMeetingStart` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckMeetingStart`(IN target_meeting_id INT)
proc_label: BEGIN
    -- ALL DECLARE STATEMENTS MUST BE FIRST
    DECLARE chama_id_var INT;
    DECLARE member_id_var INT;
    DECLARE done INT DEFAULT FALSE;
    
    -- Cursor declaration AFTER all other declares
    DECLARE member_cursor CURSOR FOR
        SELECT id 
        FROM members 
        WHERE chama_id = chama_id_var 
        AND status = 'active';
    
    -- Handler declaration AFTER cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Get chama_id for the meeting
    SELECT chama_id INTO chama_id_var 
    FROM meetings 
    WHERE id = target_meeting_id;
    
    -- If chama_id not found, exit
    IF chama_id_var IS NULL THEN
        LEAVE proc_label;
    END IF;
    
    OPEN member_cursor;
    
    member_loop: LOOP
        FETCH member_cursor INTO member_id_var;
        IF done THEN
            LEAVE member_loop;
        END IF;
        
        -- Check if member is NOT in attendance table at meeting start
        IF NOT EXISTS (
            SELECT 1 
            FROM attendance 
            WHERE meeting_id = target_meeting_id 
            AND member_id = member_id_var
        ) THEN
            -- Member is absent at meeting start - fine 100
            INSERT INTO fines (member_id, meeting_id, fine_type, amount)
            VALUES (member_id_var, target_meeting_id, 'absent', 100.00)
            ON DUPLICATE KEY UPDATE 
                fine_type = 'absent',
                amount = 100.00,
                updated_at = CURRENT_TIMESTAMP;
        END IF;
        
    END LOOP member_loop;
    
    CLOSE member_cursor;
    
    -- Mark this start check as processed
    UPDATE attendance_schedules 
    SET is_processed = TRUE 
    WHERE meeting_id = target_meeting_id 
    AND check_type = 'start_check';
    
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
        m.name,
        m.phoneNumber,
        CASE 
            WHEN a.member_id IS NOT NULL THEN 'Present'
            WHEN f.fine_type = 'late' THEN 'Late'
            WHEN f.fine_type = 'absent' THEN 'Absent'
            ELSE 'Unknown'
        END as attendance_status,
        COALESCE(f.amount, 0.00) as fine_amount,
        a.arrival_time,
        f.created_at as fine_date
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
    SELECT COUNT(*) > 0 INTO meeting_started
    FROM meetings 
    WHERE id = meeting_id_param 
    AND TIMESTAMP(meeting_date, start_time) <= NOW();
    
    -- Check if meeting has ended
    SELECT COUNT(*) > 0 INTO meeting_ended
    FROM meetings 
    WHERE id = meeting_id_param 
    AND TIMESTAMP(meeting_date, end_time) <= NOW();
    
    IF meeting_started THEN
        CALL CheckMeetingStart(meeting_id_param);
    END IF;
    
    IF meeting_ended THEN
        CALL CheckMeetingEnd(meeting_id_param);
    END IF;
    
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
    
    -- Cursor to get all pending checks that are due
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
        ELSEIF check_type_var = 'end_check' THEN
            CALL CheckMeetingEnd(meeting_id_var);
        END IF;
        
    END LOOP check_loop;
    
    CLOSE check_cursor;
    
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
    
    -- Only schedule if meeting is in the future
    IF meeting_datetime > NOW() THEN
        -- Schedule start check (at meeting start time)
        INSERT INTO attendance_schedules (meeting_id, check_time, check_type)
        VALUES (meeting_id_param, meeting_datetime, 'start_check');
        
        -- Schedule end check (at meeting end time)
        INSERT INTO attendance_schedules (meeting_id, check_time, check_type)
        VALUES (meeting_id_param, end_datetime, 'end_check');
    END IF;
    
END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
