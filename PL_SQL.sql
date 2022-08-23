## Simple PL/SQL

declare
    i number;
BEGIN
    i:=1;
    LOOP
    dbms_output.put_line(i);
    i:=i+1;
    exit when i>5;
    END LOOP;
END;

################################################
############### PROCEDURES
################################################
##  CREATE [OR REPLACE] PROCEDURE procedure_name
##  [(parameter_name [IN|OUT|IN OUT] type [ , ...])]
##  {IS | AS}
##  BEGIN
##      <procedure body>
##  END procedure_name;

CREATE OR REPLACE PROCEDURE getTopperStudent
AS
topperName STUDENT.name%type;
BEGIN
SELECT name INTO topperName FROM STUDENT WHERE marks=(SELECT MAX(marks) FROM STUDENT)
dbms_output.put_line(topperName);
END;
## TWO WAY TO DO IT
BEGIN getTopperStudent END;
exec getTopperStudent;

-- created in the main memory
-- store and manipulated data
-- 
################################################
############### Implicit CURSOR
################################################
## %FOUND %NOTFOUND %ROWCOUNT

CREATE OR REPLACE PROCEDURE updateFees(newFee int)
AS
var_rows number;
BEGIN
UPDATE STUDENT SET fees=newFee;
IF SQL%FOUND THEN
    var_rows:=SQL%ROWCOUNT;
    dbms_output.put_line('THE FEES OF'||var_rows||'STUDENT WAS UPDATED');
ELSE
    dbms_output.put_line('SOME ISSUE IN UPDATING');
END IF;
END;


BEGIN updateFees(4500) END;



################################################
############### Explicit CURSOR
################################################

####EXAMPLE 1
DECLARE CURSOR C1
IS
SELECT deptName As Department, AVG(fee) AS Average_Fees 
    FROM STUDENT NATURAL JOIN DEPARTMENT GROUP BY deptName;
REC1 C1%ROWTYPE;
BEGIN
FOR REC1 IN C1 LOOP
    dbms_output.put_line(REC1.Department||''||REC1.Average_Fees);
END LOOP;
END;

####EXAMPLE 2
DECLARE CURSOR C1
IS
SELECT DISTINCT deptName FROM DEPARTMENT;
CURSOR C2(dept varchar)
IS
SELECT name,marks FROM STUDENT NATURAL JOIN DEPARTMENT WHERE deptName=dept;
REC1 C1%ROWTYPE;
REC2 C2%ROWTYPE;

BEGIN
FOR REC1 IN C1 LOOP
    dbms_output.put_line(REC1.deptName);
    FOR REC2 IN C2 LOOP
    dbms_output.put_line(REC2.Name||''||REC2.marks);
    END LOOP;
    dbms_output.put_line('');
END LOOP;
END;


################################################
############### PROCEDURE && CURSOR
################################################

CREATE OR REPLACE PROCEDURE listStudents(dept varchar)
IS
CURSOR C1 IS
SELECT rollNo,name,marks FROM STUDENT NATURAL JOIN DEPARTMENT 
    WHERE deptName=dept;
REC1 C1%ROWTYPE;
BEGIN
FOR REC1 IN C1 LOOP
    dbms_output.put_line(REC1.rollNo||''||REC1.name||''||REC1.marks);
END LOOP;
END;

BEGIN listStudents('production') END;



################################################
############### PL/SQL FUNCTIONS
################################################
-- same as PROCEDURE except that it always returns a value

-- CREATE [OR REPLACE] FUNCTION function_name
-- [(parameter_name [IN|OUT|IN OUT] type [ , ...])]
-- RETURN return_datatype {IS|AS}
-- BEGIN
-- <function body>
-- END function_name;

CREATE OR REPLACE FUNCTION totalFees(dept varchar)
RETURN int
IS
total int;
BEGIN
SELECT sum(fees) into total FROM STUDENT NATURAL JOIN DEPARTMENT WHERE deptName=dept;
RETURN total;
END;

SELECT totalFees('production') FROM DUAL;


################################################
############### TRIGGERS
################################################
-- Routines,which are automatically executed when
-- some events occur.

-- DML DELETE, INSERT, UPDATE
-- DDL CREATE, ALTER, DROP
-- DB OPERATIONS   SERVERERROR, LOGON, LOGOFF, STARTUP, SHUTDOWN

-- CREATE [OR REPLACE] TRIGGER trigger_name
-- BEFORE/AFTER INSERT/UPDATE/DELETE
-- ON table_name [FOR EACH ROW]
-- DECLARE
--     VARIABLE DECLARATIONS
-- BEGIN
--     TRIGGER CODE
-- EXCEPTION WHEN ...
--     EXCEPTION HANDLING
-- END;

-- * BEFORE
CREATE OR REPLACE TRIGGER checkEmail
BEFORE INSERT ON student
FOR EACH ROW
DECLARE
    rowcount int;
BEGIN
    SELECT COUNT(*) INTO rowcount FROM STUDENT WHERE email= :n.email;
    IF rowcount<>0 THEN
        raise_application_error(-20001,'Email already Registered');
    END IF;
END;

INSERT INTO STUDENT VALUES(34,'January',78,5,'19-jun-2015',5600,'email@mail.com');
-- Email already Registered



-- * AFTER
CREATE OR REPLACE TRIGGER cleanStudents
AFTER DELETE ON department
FOR EACH ROW
DECLARE
    dept int;
BEGIN
    dept:= :OLD.deptNo;
    DELETE FROM STUDENT WHERE deptNo=dept;
END;

DELETE FROM DEPARTMENT WHERE deptNo=6;
SELECT * FROM STUDENT NATURAL JOIN DEPARTMENT;




################################################
############### PACKAGE
################################################
-- SPECIFICATION: DECLARACIONES
-- DEFINITION (BODY): VARIOS METODOS

CREATE PACKAGE student_marks
AS
PROCEDURE find_marks(s_id STUDENT.rollNo%type);
END student_marks;

EXEC student_marks;



CREATE OR REPLACE PACKAGE BODY student_marks
AS
PROCEDURE find_marks(s_id STUDENT.rollNo%TYPE);
IS
smarks STUDENT.marks%TYPE;
BEGIN
    SELECT marks INTO smarks FROM STUDENT WHERE rollNo=s_id;
    dbms_output.put_line('Marks obtein: '|| smarks);
END find_marks;
END student_marks;

BEGIN student_marks.find_marks(12); END;




################################################
############### EXCEPTIONS
################################################

-- An error condition during a program execution
-- System Defined Exceptions
-- User Defined Exceptions

-- System Defined Exceptions
DECLARE
dept DEPARTMENT.deptNo%TYPE;
name DEPARTMENT.deptName%TYPE;
BEGIN
dept:= :valueUser;
SELECT deptName INTO name FROM DEPARTMENT WHERE deptNo=dept;
    dbms_output.put_line('NAME: '|| name);
EXCEPTION
WHEN no_data_found THEN
    dbms_output.put_line('NO SUCH DEPARTMENT!');
WHEN others THEN
    dbms_output.put_line('ERROR!');
END;


-- User Defined Exceptions
DECLARE
    dept DEPARTMENT.deptNo%TYPE;
    name DEPARTMENT.deptName%TYPE;
    ex_invalid_deptNo EXCEPTION;
BEGIN
    dept:= :valueUser;
    IF dept <=0 THEN
        RAISE ex_invalid_deptNo;
    ELSE
        SELECT deptName INTO name
        FROM DEPARTMENT
        WHERE deptNo=dept;
        dbms_output.put_line('DEPARTMENT: '||name);
    END IF;
EXCEPTION
    WHEN ex_invalid_deptNo THEN
        dbms_output.put_line('DEPARTMENT NUMBER MUST BE GREATER THAN ZERO');
    WHEN no_data_found THEN
        dbms_output.put_line('NO SUCH DEPARTMENT');
    WHEN others THEN
        dbms_output.put_line('ERROR');
END;



