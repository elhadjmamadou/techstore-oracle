-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 05_verification_oracle.sql
-- Objectif: Vérifier la connexion et l'environnement Oracle
-- Exécuter: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- Connexion : techstore/techstore@//localhost:1521/FREEPDB1
-- ============================================================

-- Utilisateur connecté
SELECT USER AS utilisateur_connecte FROM dual;

-- Nom du service
SELECT SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service FROM dual;

-- Version Oracle
SELECT banner FROM v$version WHERE banner LIKE 'Oracle%';

-- PDB active
SELECT name, open_mode FROM v$pdbs;

-- Tables du schéma TECHSTORE
SELECT table_name FROM user_tables ORDER BY table_name;

-- Séquences
SELECT sequence_name, last_number FROM user_sequences ORDER BY sequence_name;

-- Index
SELECT index_name, index_type, status FROM user_indexes ORDER BY index_name;

-- Vues
SELECT view_name FROM user_views ORDER BY view_name;

-- Triggers
SELECT trigger_name, status FROM user_triggers ORDER BY trigger_name;

-- Synonymes
SELECT synonym_name, table_name FROM user_synonyms ORDER BY synonym_name;
