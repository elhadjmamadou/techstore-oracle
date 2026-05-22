SET SERVEROUTPUT ON;

PROMPT ============================================================
PROMPT CREATION DE L'UTILISATEUR TECHSTORE
PROMPT ============================================================

BEGIN
   EXECUTE IMMEDIATE 'DROP USER techstore CASCADE';
   DBMS_OUTPUT.PUT_LINE('Utilisateur TECHSTORE supprime.');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -1918 THEN
         DBMS_OUTPUT.PUT_LINE('Utilisateur TECHSTORE inexistant, creation en cours...');
      ELSE
         RAISE;
      END IF;
END;
/

CREATE USER techstore
IDENTIFIED BY "TechStore#2026"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CREATE SESSION TO techstore;

GRANT CREATE TABLE TO techstore;
GRANT CREATE VIEW TO techstore;
GRANT CREATE SEQUENCE TO techstore;
GRANT CREATE SYNONYM TO techstore;
GRANT CREATE PUBLIC SYNONYM TO techstore;
GRANT CREATE PROCEDURE TO techstore;
GRANT CREATE TRIGGER TO techstore;
GRANT CREATE TYPE TO techstore;

GRANT CREATE USER TO techstore;
GRANT CREATE ROLE TO techstore;
GRANT CREATE PROFILE TO techstore;
GRANT CREATE TABLESPACE TO techstore;
GRANT ALTER USER TO techstore;
GRANT DROP USER TO techstore;
GRANT GRANT ANY PRIVILEGE TO techstore;
GRANT GRANT ANY ROLE TO techstore;

GRANT UNLIMITED TABLESPACE TO techstore;

GRANT DBA TO techstore;

PROMPT ============================================================
PROMPT VERIFICATION DE L'UTILISATEUR TECHSTORE
PROMPT ============================================================

SELECT username, account_status, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username = 'TECHSTORE';

SELECT granted_role
FROM dba_role_privs
WHERE grantee = 'TECHSTORE'
ORDER BY granted_role;

PROMPT ============================================================
PROMPT UTILISATEUR TECHSTORE CREE AVEC SUCCES
PROMPT Connexion :
PROMPT techstore / TechStore#2026
PROMPT Service :
PROMPT localhost:1521/FREEPDB1
PROMPT ============================================================