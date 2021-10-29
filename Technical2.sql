--PART 1 - PROCEDURES
--Write a procedure that displays the number of countries in a given region (prompt for value) 
--whose highest elevations exceed a given value (prompt for value). 
--The procedure should accept two formal parameters, one for a region_id and the other for an elevation value for comparison. 
--Use DBMS_OUTPUT.PUT_LINE to display the results in a message. 
--Test your procedure using the value 5 for the region_id and 2000 for the highest elevation.


CREATE OR REPLACE PROCEDURE number_of_countries (
    p_region_id IN OUT countries.region_id%TYPE, 
    p_elevation IN OUT countries.highest_elevation%TYPE
    ) IS
    
    v_num_of_countries NUMBER(10);
BEGIN 
    SELECT COUNT(*) INTO v_num_of_countries
    FROM countries
    WHERE region_id = p_region_id
    AND highest_elevation > p_elevation;
    dbms_output.put_line('Region ' || p_region_id 
                        || ' has ' || v_num_of_countries 
                        || ' number of countries that exceed ' 
                        || p_elevation  || ' elevation');
END number_of_countries;
    
    
    
    
--invoking the procedure
DECLARE
    reg countries.region_id%TYPE;
    elev countries.highest_elevation%TYPE;
begin
    reg := &Region_ID;
    elev := &Highest_Elevation;
    number_of_countries(reg, elev);
end;






--PART 2 FUNCTIONS
--1
--Create a function called full_name. 
--Pass two parameters to the function, an employee’s last name and first name. 
--The function should return the full name in the format, 
--last name, comma, space, first name (for example: Smith, Joe).

CREATE OR REPLACE FUNCTION full_name (
    p_last_name employees.last_name%TYPE,
    p_first_name employees.first_name%TYPE
    ) RETURN VARCHAR2 IS
    fullName employees.first_name%TYPE;
BEGIN
    fullName := p_last_name || ', ' || p_first_name;
    
    RETURN fullName;
END full_name;




--Test your function from an anonymous block which uses a 
--local variable to store and display the returned value
declare
    fname employees.first_name%TYPE;
begin
    fname := full_name('Isnain', 'Zaina');
    dbms_output.put_line(fname);
end;
    
    
--2
--Modify your anonymous block from the previous step to
--remove the local variable declaration and
--call the function directly from within the DBMS_OUTPUT.PUT_LINE call.
--Test the block again.

begin
    dbms_output.put_line(full_name('Isnain', 'Zaina'));
end;



--3
--Now call the function from within a SELECT statement, not a PL/SQL block. 
--Your SELECT statement should display the first_name, last_name, 
--and full name (using the function) of all employees in department 50.

SELECT last_name, first_name, full_name(last_name, first_name)
FROM employees
WHERE employee_id = 100;








--PART 3 - PACKAGES
--A. Create a package specification and body called JOB_PKG, containing the following procedures:

-- Create a procedure called ADD_JOB to insert a new job into the JOBS table. 
-- the procedure has job id, job title, minimum salary and maximum salary as parameters. 
-- Ensure that the value of maximum salary is greater than minimum salary, 
-- raise an exception if this rule is violated  max > min
-- (create a private procedure for salary validation). see second solution
--NOTE: I MADE TWO SOLUTIONS FOR THIS QUESTION

--FIRST SOLUTION
CREATE OR REPLACE PACKAGE job_pkg IS 
    PROCEDURE add_job (
        p_job_id jobs.job_id%TYPE, 
        p_job_title jobs.job_title%TYPE, 
        p_min_sal  jobs.min_salary%TYPE, 
        p_max_sal jobs.max_salary%TYPE);
 
-- Create a procedure called UPD_JOB to update the job title.
-- Provide the job ID and a new title using two parameters.  
-- Include the necessary exception handling if no update occurs.
    PROCEDURE upd_job (
        p_job_id jobs.job_id%TYPE,
        p_new_job_title jobs.job_title%TYPE);  
END job_pkg;
/

CREATE OR REPLACE PACKAGE BODY job_pkg IS
    PROCEDURE add_job (
        p_job_id jobs.job_id%TYPE, 
        p_job_title jobs.job_title%TYPE, 
        p_min_sal jobs.min_salary%TYPE, 
        p_max_sal jobs.max_salary%TYPE
        ) IS
        e_sal_error EXCEPTION;
        BEGIN
            IF p_max_sal >  p_min_sal
             THEN
                INSERT INTO jobs
                VALUES (p_job_id, p_job_title, p_min_sal, p_max_sal);
                 dbms_output.put_line('added job!');
            ELSE 
                RAISE e_sal_error;
            END IF;
        EXCEPTION
            WHEN e_sal_error
            THEN
                dbms_output.put_line('min sal is greater than max sal');
    END add_job;
            
            
            
    PROCEDURE upd_job(
        p_job_id jobs.job_id%TYPE,
        p_new_job_title jobs.job_title%TYPE
        ) IS
        e_no_update EXCEPTION;
        BEGIN
            UPDATE jobs
            SET
                job_title = p_new_job_title
            WHERE
                job_id = p_job_id;
                
            IF SQL%NOTFOUND 
            THEN
                RAISE e_no_update;
            ELSIF EXISTS
                THEN dbms_output.put_line('ALREADY EXISTS');
            ELSE
                dbms_output.put_line('updated successfully');
            END IF;
            
        EXCEPTION
            WHEN e_no_update 
            THEN
                dbms_output.put_line('no update occured');            
    END upd_job;
END job_pkg;       
/


--SECOND SOLUTION
--this solution uses a private function to validate salary
CREATE OR REPLACE PACKAGE BODY job_pkg IS

    FUNCTION sal_valid (
        p_min_sal jobs.min_salary%TYPE, 
        p_max_sal jobs.max_salary%TYPE,
        is_valid BOOLEAN
        ) RETURN BOOLEAN IS
        e_sal_error EXCEPTION;
        BEGIN
            IF p_max_sal > p_min_sal
                THEN
                    RETURN is_valid = TRUE;
            ELSE
                RAISE e_sal_error;
            END IF;
        EXCEPTION
        WHEN e_sal_error
        THEN
            dbms_output.put_line('INVALID min sal is greater than max sal');
    END sal_valid;
        
    PROCEDURE add_job (
        p_job_id jobs.job_id%TYPE, 
        p_job_title jobs.job_title%TYPE, 
        p_min_sal jobs.min_salary%TYPE, 
        p_max_sal jobs.max_salary%TYPE
        ) IS
        e_sal_error EXCEPTION;
        BEGIN
            IF p_max_sal >  p_min_sal
             THEN
                INSERT INTO jobs
                VALUES (p_job_id, p_job_title, p_min_sal, p_max_sal);
                 dbms_output.put_line('added job!');
            ELSE 
                RAISE e_sal_error;
            END IF;
        EXCEPTION
            WHEN e_sal_error
            THEN
                dbms_output.put_line('min sal is greater than max sal');
    END add_job;
            
            
            
    PROCEDURE upd_job(
        p_job_id jobs.job_id%TYPE,
        p_new_job_title jobs.job_title%TYPE
        ) IS
        e_no_update EXCEPTION;
        BEGIN
            UPDATE jobs
            SET
                job_title = p_new_job_title
            WHERE
                job_id = p_job_id;
                
            IF SQL%NOTFOUND 
            THEN
                RAISE e_no_update;
            ELSIF EXISTS
                THEN dbms_output.put_line('ALREADY EXISTS');
            ELSE
                dbms_output.put_line('updated successfully');
            END IF;
            
        EXCEPTION
            WHEN e_no_update 
            THEN
                dbms_output.put_line('no update occured');            
    END upd_job;
END job_pkg;       





--B. Create an anonymous block.
-- Invoke your ADD_JOB package procedure by passing the values IT_SYSAN and SYSTEMS ANALYST as parameters.
-- Values for minimum and maximum salary are 10000 and 5000 respectively.

EXECUTE job_pkg.add_job('IT_SYSAN', 'SYSTEM ANALYST', 10000, 5000);

-- Invoke your ADD_JOB package procedure by passing the values IT_DBADM and DATABASE ADMINISTRATOR as parameters.
-- Values for minimum and maximum salary are 5000 and 10000 respectively.

EXECUTE job_pkg.add_job('IT_DBADM','DATABASE ADMINISTRATOR', 5000, 10000);

--Invoke your UPD_JOB package procedure by passing the values IT_DBADM and DATABASE ADMINISTRATOR as parameters.
EXECUTE job_pkg.upd_job('IT_DBADM','DATABASE ADMINISTRATOR');










--PART 4 - TRIGGERS
-- A. The rows in the JOBS table store a minimum and maximum salary 
--    allowed for different JOB_ID values.
--    You are asked to write code to ensure that employees’ salaries 
--    fall in the range allowed or their job type, for insert and update operations.

-- Create a procedure called CHECK_SALARY as follows:
-- The subprogram accepts two parameters, one for an employee’s job ID
--     string and the other for the salary. (2 pts)
-- The procedure uses the job ID to determine the minimum and 
--       maximum salary for the specified job. (2 pts)

CREATE OR REPLACE PROCEDURE check_salary (
    p_job_id  employees.job_id%TYPE,
    p_salary  employees.salary%TYPE
    ) IS
    e_app_error EXCEPTION;
        v_min_sal employees.salary%TYPE;
        v_max_sal employees.salary%TYPE;
    BEGIN
        SELECT
             min_salary, max_salary
        INTO
            v_min_sal, v_max_sal
        FROM
            jobs
        WHERE
            job_id = p_job_id;
            
        IF p_salary BETWEEN v_min_sal AND v_max_sal
            THEN 
                dbms_output.put_line('SALARY FALL WITHIN RANGE');
        ELSE
            RAISE_APPLICATION_ERROR(-20404, 'Invalid salary ' ||p_salary ||
                                '. Salaries for job ' || p_job_id ||
                                ' must be between ' || v_min_sal ||
                                ' and ' || v_max_sal);
        END IF;
END check_salary;





-- B. Create a trigger called CHECK_SALARY_TRG on the EMPLOYEES table
--      that fires before an INSERT or UPDATE operation on each row: (5 pts)

-- The trigger must call the CHECK_SALARY procedure to carry out the business logic.
-- The trigger should pass the new job ID and salary to the procedure parameters.

CREATE OR REPLACE TRIGGER check_salary_trg 
    BEFORE INSERT OR UPDATE OF salary, job_id
    ON employees FOR EACH ROW
    DECLARE
        v_min_sal employees.salary%TYPE;
        v_max_sal employees.salary%TYPE;
    BEGIN
        check_salary(:NEW.job_id, :NEW.salary);
END;



--C. Create an anonymous block to insert a new record in employees table
-- with employee id as 777, job id as IT_DBADM, salary as 20000.

BEGIN
    INSERT INTO employees (employee_id, job_id, salary)
    VALUES (777, 'IT_DBADM', 20000);
END;
