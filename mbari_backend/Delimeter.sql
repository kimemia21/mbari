-- First, drop existing procedures that have errors
DROP PROCEDURE IF EXISTS CheckMeetingStart;
DROP PROCEDURE IF EXISTS CheckMeetingEnd;
DROP PROCEDURE IF EXISTS ProcessScheduledChecks;
DROP PROCEDURE IF EXISTS ManualProcessMeeting;
DROP PROCEDURE IF EXISTS GetMeetingAttendanceSummary;
DROP PROCEDURE IF EXISTS CleanupOldSchedules;
DROP PROCEDURE IF EXISTS ScheduleAttendanceChecks;

-- Drop existing triggers
DROP TRIGGER IF EXISTS after_meeting_insert;
DROP TRIGGER IF EXISTS after_meeting_update;

-- =====================================================
-- CORRECTED PROCEDURES WITH PROPER DECLARE ORDER
-- =====================================================

DELIMITER //

-- Procedure to check attendance at meeting start (marks absent)
CREATE PROCEDURE CheckMeetingStart(IN target_meeting_id INT)
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
    
END //

-- Procedure to check attendance at meeting end (marks late for those who arrived)
CREATE PROCEDURE CheckMeetingEnd(IN target_meeting_id INT)
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
    
END //

-- Procedure to schedule attendance checks for a meeting
CREATE PROCEDURE ScheduleAttendanceChecks(IN meeting_id_param INT)
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
    
END //

-- Main procedure to process all pending attendance checks
CREATE PROCEDURE ProcessScheduledChecks()
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
    
END //

-- Procedure to manually process a specific meeting (for testing)
CREATE PROCEDURE ManualProcessMeeting(IN meeting_id_param INT)
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
    
END //

-- Procedure to get meeting attendance summary
CREATE PROCEDURE GetMeetingAttendanceSummary(IN meeting_id_param INT)
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
END //

-- Procedure to clean up old processed schedules
CREATE PROCEDURE CleanupOldSchedules()
BEGIN
    DELETE FROM attendance_schedules 
    WHERE is_processed = TRUE 
    AND created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
END //

-- Recreate triggers
CREATE TRIGGER after_meeting_insert
AFTER INSERT ON meetings
FOR EACH ROW
BEGIN
    CALL ScheduleAttendanceChecks(NEW.id);
END //

CREATE TRIGGER after_meeting_update
AFTER UPDATE ON meetings
FOR EACH ROW
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
END //

DELIMITER ;



DELIMITER //
CREATE EVENT IF NOT EXISTS process_attendance_checks
ON SCHEDULE EVERY 30 SECOND
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL ProcessScheduledChecks();
END //
DELIMITER ;

-- Test the procedures
SELECT 'All procedures created successfully!' as status;





/*
FLOW DIAGRAM:
=============

1. NEW MEETING CREATED
   ↓
2. TRIGGER: after_meeting_insert
   ↓
3. CALLS: ScheduleAttendanceChecks()
   ↓
4. CREATES: 2 entries in attendance_schedules
   - start_check (at meeting start time)
   - end_check (at meeting end time)
   ↓
5. EVENT: process_attendance_checks (runs every 30 seconds)
   ↓
6. CALLS: ProcessScheduledChecks()
   ↓
7. PROCESSES: Due attendance schedules
   ↓
8. FOR start_check: CheckMeetingStart()
   - Marks all active members as ABSENT (100.00 fine)
   ↓
9. MEMBERS ARRIVE: Records added to attendance table
   ↓
10. FOR end_check: CheckMeetingEnd()
    - Changes ABSENT to LATE (50.00 fine) for members who arrived
    - Leaves ABSENT (100.00 fine) for members who never arrived
    ↓
11. MEETING STATUS: Updated to 'completed'
*/







-- =====================================================
-- COMPLETE CHAMA MEETING & FINE PROCESSING FLOW
-- =====================================================

-- =====================================================
-- STEP 1: CREATE MISSING TABLES
-- =====================================================

-- Create attendance table (if not exists)
CREATE TABLE IF NOT EXISTS attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    meeting_id INT NOT NULL,
    member_id INT NOT NULL,
    arrival_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (meeting_id) REFERENCES meetings(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    UNIQUE KEY unique_member_meeting (meeting_id, member_id)
);

-- Create attendance_schedules table (if not exists)
CREATE TABLE IF NOT EXISTS attendance_schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    meeting_id INT NOT NULL,
    check_time TIMESTAMP NOT NULL,
    check_type ENUM('start_check', 'end_check') NOT NULL,
    is_processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (meeting_id) REFERENCES meetings(id) ON DELETE CASCADE,
    INDEX idx_check_time (check_time),
    INDEX idx_processed (is_processed)
);

-- Create system_logs table for debugging (optional)
CREATE TABLE IF NOT EXISTS system_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- STEP 2: THE COMPLETE FLOW DIAGRAM
-- =====================================================

/*
FLOW DIAGRAM:
=============

1. NEW MEETING CREATED
   ↓
2. TRIGGER: after_meeting_insert
   ↓
3. CALLS: ScheduleAttendanceChecks()
   ↓
4. CREATES: 2 entries in attendance_schedules
   - start_check (at meeting start time)
   - end_check (at meeting end time)
   ↓
5. EVENT: process_attendance_checks (runs every 30 seconds)
   ↓
6. CALLS: ProcessScheduledChecks()
   ↓
7. PROCESSES: Due attendance schedules
   ↓
8. FOR start_check: CheckMeetingStart()
   - Marks all active members as ABSENT (100.00 fine)
   ↓
9. MEMBERS ARRIVE: Records added to attendance table
   ↓
10. FOR end_check: CheckMeetingEnd()
    - Changes ABSENT to LATE (50.00 fine) for members who arrived
    - Leaves ABSENT (100.00 fine) for members who never arrived
    ↓
11. MEETING STATUS: Updated to 'completed'
*/

-- =====================================================
-- STEP 3: COMPLETE PROCEDURE DEFINITIONS
-- =====================================================

-- Drop existing procedures
DROP PROCEDURE IF EXISTS CheckMeetingStart;
DROP PROCEDURE IF EXISTS CheckMeetingEnd;
DROP PROCEDURE IF EXISTS ProcessScheduledChecks;
DROP PROCEDURE IF EXISTS ScheduleAttendanceChecks;
DROP PROCEDURE IF EXISTS ManualProcessMeeting;
DROP PROCEDURE IF EXISTS GetMeetingAttendanceSummary;

DELIMITER //

-- 1. Schedule attendance checks when meeting is created
CREATE PROCEDURE ScheduleAttendanceChecks(IN meeting_id_param INT)
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
    
END //

-- 2. Process meeting start - Mark all as absent
CREATE PROCEDURE CheckMeetingStart(IN target_meeting_id INT)
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
    
END //

-- 3. Process meeting end - Convert absent to late for attendees
CREATE PROCEDURE CheckMeetingEnd(IN target_meeting_id INT)
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
    
END //

-- 4. Main processor - runs every 30 seconds
CREATE PROCEDURE ProcessScheduledChecks()
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
    
END //

-- 5. Manual processing for testing
CREATE PROCEDURE ManualProcessMeeting(IN meeting_id_param INT)
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
    
END //

-- 6. Get meeting summary
CREATE PROCEDURE GetMeetingAttendanceSummary(IN meeting_id_param INT)
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
END //

DELIMITER ;

-- =====================================================
-- STEP 4: CREATE TRIGGERS
-- =====================================================

-- Drop existing triggers
DROP TRIGGER IF EXISTS after_meeting_insert;
DROP TRIGGER IF EXISTS after_meeting_update;

DELIMITER //

CREATE TRIGGER after_meeting_insert
AFTER INSERT ON meetings
FOR EACH ROW
BEGIN
    CALL ScheduleAttendanceChecks(NEW.id);
END //

CREATE TRIGGER after_meeting_update
AFTER UPDATE ON meetings
FOR EACH ROW
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
END //

DELIMITER ;

-- =====================================================
-- STEP 5: CREATE THE AUTOMATIC EVENT
-- =====================================================

-- Drop existing event
DROP EVENT IF EXISTS process_attendance_checks;

DELIMITER //

CREATE EVENT process_attendance_checks
ON SCHEDULE EVERY 30 SECOND
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL ProcessScheduledChecks();
END //

DELIMITER ;

-- =====================================================
-- STEP 6: VERIFY SETUP
-- =====================================================

SELECT 'SETUP VERIFICATION' AS status;

-- Check if event scheduler is enabled
SHOW VARIABLES LIKE 'event_scheduler';

-- Check if event was created
SELECT event_name, status, interval_value, interval_field, last_executed, next_execution
FROM information_schema.events 
WHERE event_schema = DATABASE();

-- Check existing tables
SELECT 'EXISTING TABLES' AS info;
SHOW TABLES LIKE '%attendance%';
SHOW TABLES LIKE '%meeting%';
SHOW TABLES LIKE '%fine%';
SHOW TABLES LIKE '%member%';
SHOW TABLES LIKE '%chama%';

-- =====================================================
-- STEP 7: COMPLETE TESTING SCENARIO
-- =====================================================

-- Test with a meeting that starts in 1 minute
INSERT INTO meetings (
    chama_id, 
    meeting_date, 
    start_time, 
    end_time, 
    venue, 
    agenda, 
    status
) VALUES (
    1, -- Replace with actual chama_id
    CURDATE(),
    ADDTIME(CURTIME(), '00:01:00'), -- Starts in 1 minute
    ADDTIME(CURTIME(), '00:02:30'), -- Ends in 2.5 minutes
    'Test Conference Room',
    'Automated Fine Processing Test',
    'scheduled'
);

SET @test_meeting_id = LAST_INSERT_ID();

-- Show what was scheduled
SELECT 
    'SCHEDULED CHECKS FOR TEST MEETING' AS info,
    s.id,
    s.meeting_id,
    s.check_time,
    s.check_type,
    s.is_processed,
    TIMESTAMPDIFF(SECOND, NOW(), s.check_time) AS seconds_until_execution
FROM attendance_schedules s
WHERE s.meeting_id = @test_meeting_id
ORDER BY s.check_time;

-- =====================================================
-- STEP 8: MONITORING COMMANDS
-- =====================================================

-- Use these commands to monitor the system:

-- 1. Check pending schedules
SELECT 
    'PENDING SCHEDULES' AS info,
    COUNT(*) AS count,
    MIN(check_time) AS next_check
FROM attendance_schedules 
WHERE is_processed = FALSE;

-- 2. Check recent fines
SELECT 
    'RECENT FINES' AS info,
    f.id,
    f.meeting_id,
    m.name,
    f.fine_type,
    f.amount,
    f.created_at
FROM fines f
JOIN members m ON f.member_id = m.id
WHERE f.created_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
ORDER BY f.created_at DESC;

-- 3. Check system logs
SELECT 
    'SYSTEM LOGS' AS info,
    message,
    created_at
FROM system_logs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
ORDER BY created_at DESC;

-- 4. To simulate member arrival (run after meeting starts):
-- INSERT INTO attendance (meeting_id, member_id, arrival_time) 
-- VALUES (@test_meeting_id, 1, NOW()); -- Replace 1 with actual member_id

-- 5. Get meeting summary:
-- CALL GetMeetingAttendanceSummary(@test_meeting_id);

SELECT 'COMPLETE FLOW SETUP FINISHED' AS status;
SELECT 'Wait 1-2 minutes and check the monitoring commands above' AS instruction;