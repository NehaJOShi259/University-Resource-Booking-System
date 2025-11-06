-- ============================================
-- 🎓 UNIVERSITY RESOURCE BOOKING SYSTEM (SQL)
-- ============================================

-- Drop old database if exists
DROP DATABASE IF EXISTS UniversityBooking;
CREATE DATABASE UniversityBooking;
USE UniversityBooking;

-- ============================================
-- TABLES
-- ============================================

-- 1. Resources: rooms, halls, labs, etc.
CREATE TABLE Resources (
    resource_id INT AUTO_INCREMENT PRIMARY KEY,
    resource_name VARCHAR(100) NOT NULL,
    resource_type ENUM('Classroom', 'Lab', 'Auditorium', 'Seminar Hall') NOT NULL,
    capacity INT CHECK (capacity > 0),
    location VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);

-- 2. Users: faculty or admin
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    role ENUM('Faculty', 'Admin') DEFAULT 'Faculty',
    email VARCHAR(100) UNIQUE
);

-- 3. Bookings
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    resource_id INT,
    user_id INT,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected', 'Cancelled') DEFAULT 'Pending',
    approved_by VARCHAR(100),
    FOREIGN KEY (resource_id) REFERENCES Resources(resource_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ============================================
-- TRIGGER: Prevent overlapping bookings
-- ============================================

DELIMITER $$

CREATE TRIGGER trg_check_conflict
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    DECLARE conflict_count INT;
    SELECT COUNT(*) INTO conflict_count
    FROM Bookings
    WHERE resource_id = NEW.resource_id
      AND booking_date = NEW.booking_date
      AND status IN ('Approved', 'Pending')
      AND (
            (NEW.start_time BETWEEN start_time AND end_time)
         OR (NEW.end_time BETWEEN start_time AND end_time)
         OR (start_time BETWEEN NEW.start_time AND NEW.end_time)
         OR (end_time BETWEEN NEW.start_time AND NEW.end_time)
      );
    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Booking conflict detected for this resource.';
    END IF;
END $$

DELIMITER ;

-- ============================================
-- PROCEDURE: Approve Booking
-- ============================================

DELIMITER $$

CREATE PROCEDURE ApproveBooking(IN p_booking_id INT, IN p_admin VARCHAR(100))
BEGIN
    UPDATE Bookings
    SET status = 'Approved', approved_by = p_admin
    WHERE booking_id = p_booking_id AND status = 'Pending';
END $$

DELIMITER ;

-- ============================================
-- PROCEDURE: Reject Booking
-- ============================================

DELIMITER $$

CREATE PROCEDURE RejectBooking(IN p_booking_id INT, IN p_admin VARCHAR(100))
BEGIN
    UPDATE Bookings
    SET status = 'Rejected', approved_by = p_admin
    WHERE booking_id = p_booking_id AND status = 'Pending';
END $$

DELIMITER ;

-- ============================================
-- VIEW: Daily Schedule Overview
-- ============================================

CREATE VIEW vw_daily_schedule AS
SELECT 
    b.booking_id,
    r.resource_name,
    r.resource_type,
    b.booking_date,
    b.start_time,
    b.end_time,
    u.user_name AS booked_by,
    b.status,
    b.approved_by
FROM Bookings b
JOIN Resources r ON b.resource_id = r.resource_id
JOIN Users u ON b.user_id = u.user_id
ORDER BY b.booking_date, b.start_time;

-- ============================================
-- SAMPLE DATA
-- ============================================

INSERT INTO Resources (resource_name, resource_type, capacity, location) VALUES
('Room A101', 'Classroom', 50, 'Block A'),
('Computer Lab 2', 'Lab', 30, 'Block B'),
('Main Auditorium', 'Auditorium', 200, 'Central Wing');

INSERT INTO Users (user_name, role, email) VALUES
('Dr. Neha Sharma', 'Faculty', 'neha@univ.edu'),
('Admin Officer', 'Admin', 'admin@univ.edu');

-- ============================================
-- SAMPLE BOOKINGS
-- ============================================

INSERT INTO Bookings (resource_id, user_id, booking_date, start_time, end_time)
VALUES
(1, 1, '2025-11-10', '09:00:00', '10:00:00'),
(2, 1, '2025-11-10', '10:00:00', '11:00:00');

-- ============================================
-- TEST PROCEDURES
-- ============================================
CALL ApproveBooking(1, 'Admin Officer');
CALL RejectBooking(2, 'Admin Officer');

-- ============================================
-- TEST VIEW
-- ============================================
SELECT * FROM vw_daily_schedule;

-- ============================================
-- END OF PROJECT
-- ============================================
