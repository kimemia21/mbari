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

-- Test the procedures
SELECT 'All procedures created successfully!' as status;


