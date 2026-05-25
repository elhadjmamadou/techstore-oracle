-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 06_creation_utilisateur_techstore.sql
-- Partie  : 00 - Environnement
-- Objectif: Creer le schema principal TECHSTORE dans FREEPDB1
-- Executer: En tant que SYSTEM ou SYS (DBA) sur FREEPDB1
-- Commande: sqlplus system/mdp@//localhost:1521/FREEPDB1
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- ETAPE 1 : SUPPRESSION DE L'UTILISATEUR S'IL EXISTE DEJA
-- CASCADE supprime aussi toutes ses tables, vues et sequences.
-- Le bloc EXCEPTION evite une erreur si l'utilisateur n'existe pas.
-- ============================================================
BEGIN
   EXECUTE IMMEDIATE 'DROP USER techstore CASCADE';
   DBMS_OUTPUT.PUT_LINE('Utilisateur TECHSTORE supprime.');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -1918 THEN
         -- Code -1918 = utilisateur inexistant : ce n'est pas une erreur bloquante
         DBMS_OUTPUT.PUT_LINE('Utilisateur TECHSTORE inexistant, creation en cours...');
      ELSE
         RAISE; -- Toute autre erreur est remontee
      END IF;
END;
/

-- ============================================================
-- ETAPE 2 : CREATION DE L'UTILISATEUR TECHSTORE
-- DEFAULT TABLESPACE users : espace de stockage par defaut
-- QUOTA UNLIMITED : pas de limite de taille pour ce schema
-- ============================================================
CREATE USER techstore
IDENTIFIED BY "TechStore#2026"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

-- ============================================================
-- ETAPE 3 : PRIVILEGES DE CONNEXION ET DE CREATION D'OBJETS
-- Ces privileges permettent a TECHSTORE de se connecter
-- et de creer ses propres tables, vues, sequences, etc.
-- ============================================================
GRANT CREATE SESSION TO techstore;     -- Autoriser la connexion

GRANT CREATE TABLE     TO techstore;   -- Creer des tables
GRANT CREATE VIEW      TO techstore;   -- Creer des vues
GRANT CREATE SEQUENCE  TO techstore;   -- Creer des sequences
GRANT CREATE SYNONYM   TO techstore;   -- Creer des synonymes prives
GRANT CREATE PUBLIC SYNONYM TO techstore; -- Creer des synonymes publics
GRANT CREATE PROCEDURE TO techstore;   -- Creer des procedures et fonctions
GRANT CREATE TRIGGER   TO techstore;   -- Creer des triggers
GRANT CREATE TYPE      TO techstore;   -- Creer des types personnalises

-- ============================================================
-- ETAPE 4 : PRIVILEGES D'ADMINISTRATION
-- Ces privileges permettent a TECHSTORE de creer des utilisateurs,
-- roles et profils pour la partie securite du projet (partie 6).
-- ============================================================
GRANT CREATE USER       TO techstore;
GRANT CREATE ROLE       TO techstore;
GRANT CREATE PROFILE    TO techstore;
GRANT CREATE TABLESPACE TO techstore;
GRANT ALTER USER        TO techstore;
GRANT DROP USER         TO techstore;
GRANT GRANT ANY PRIVILEGE TO techstore;
GRANT GRANT ANY ROLE    TO techstore;

-- Espace illimite dans tous les tablespaces
GRANT UNLIMITED TABLESPACE TO techstore;

-- Rolle DBA : acces complet pour simplifier l'administration du projet
GRANT DBA TO techstore;

-- ============================================================
-- ETAPE 5 : VERIFICATION DE LA CREATION
-- Verifier que l'utilisateur est OPEN et bien configure
-- ============================================================
SELECT username, account_status, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username = 'TECHSTORE';

-- Lister les roles accordes a TECHSTORE
SELECT granted_role
FROM dba_role_privs
WHERE grantee = 'TECHSTORE'
ORDER BY granted_role;
