# University-Resource-Booking-System

## Overview
This project is a pure SQL-based system to manage room and resource bookings in a university.  
It allows faculty to request bookings for classrooms, labs, and auditoriums, while administrators can approve or reject requests.  
The system automatically detects time conflicts and maintains a clear schedule using triggers, procedures, and views.

## Features
- Resource management: store details of rooms, labs, and halls.
- User management: store faculty and admin information.
- Booking system: faculty can book resources for specific times.
- Conflict detection: prevents double-booking using SQL triggers.
- Approval process: admins can approve or reject booking requests.
- Daily schedule view: shows all approved and pending bookings.

## SQL Concepts Used
- Triggers for conflict detection
- Stored procedures for approval and rejection
- Views for generating daily schedule
- Constraints and foreign keys for data consistency
- Normalized database design (1NF, 2NF, 3NF)

## Database Tables
1. **Resources** – stores room and lab details  
2. **Users** – stores information about faculty and admins  
3. **Bookings** – stores booking requests with status and time slots  

## How It Works
1. A user (faculty) requests to book a room or lab.  
2. A trigger checks for overlapping bookings. If a conflict exists, the booking is rejected automatically.  
3. An admin reviews pending requests and approves or rejects them using stored procedures.  
4. A daily schedule view shows all bookings and their statuses.

## How to Run
1. Install and open MySQL.
2. Copy and run the file named `university_resource_booking.sql` in your MySQL terminal:
   ```bash
   mysql -u root -p < university_resource_booking.sql
````

3. To check the daily schedule:

   ```sql
   SELECT * FROM vw_daily_schedule;
   ```
4. To approve or reject bookings:

   ```sql
   CALL ApproveBooking(1, 'Admin Officer');
   CALL RejectBooking(2, 'Admin Officer');
   ```

## Example Output

| Booking ID | Resource Name  | Date       | Start | End   | Status   | Approved By   |
| ---------- | -------------- | ---------- | ----- | ----- | -------- | ------------- |
| 1          | Room A101      | 2025-11-10 | 09:00 | 10:00 | Approved | Admin Officer |
| 2          | Computer Lab 2 | 2025-11-10 | 10:00 | 11:00 | Rejected | Admin Officer |

## Technologies Used

* Database: MySQL
* Language: SQL
* Topics: Triggers, Views, Stored Procedures, Normalization

## Project Description

This project shows how SQL can be used to manage real-world scheduling problems without any external code.
It demonstrates good database design, use of advanced SQL features, and an understanding of normalization and data integrity.
