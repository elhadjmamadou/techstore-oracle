-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : test_connexion_autre_groupe.sql
-- Partie  : 09 - Réseau local
-- Objectif: Tester la connexion locale et distante via DB Link
-- ============================================================

-- ============================================================
-- SECTION 1 : TESTS DE CONNEXION LOCALE
-- ============================================================

-- Vérifier l'utilisateur connecté
SELECT USER FROM dual;

-- Vérifier le service Oracle actif
SELECT SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service FROM dual;

-- Vérifier le nom de la base
SELECT SYS_CONTEXT('USERENV', 'DB_NAME') AS base FROM dual;

-- Vérifier la date Oracle
SELECT SYSDATE FROM dual;

-- ============================================================
-- SECTION 2 : VÉRIFICATION DES DONNÉES LOCALES
-- ============================================================

-- Lister les tables disponibles
SELECT table_name FROM user_tables ORDER BY table_name;

-- Afficher les produits (table locale)
SELECT code_produit, nom, prix_vente, stock
FROM produit
ORDER BY nom;

-- Compter les enregistrements par table
SELECT 'CLIENT'      AS table_name, COUNT(*) AS nb FROM client      UNION ALL
SELECT 'PRODUIT',                   COUNT(*)        FROM produit     UNION ALL
SELECT 'COMMANDE',                  COUNT(*)        FROM commande    UNION ALL
SELECT 'FOURNISSEUR',               COUNT(*)        FROM fournisseur;

-- ============================================================
-- SECTION 3 : CRÉATION DU DATABASE LINK VERS L'AUTRE GROUPE
-- ============================================================

-- IMPORTANT : Remplacer 192.168.1.30 par l'IP réelle du poste de l'autre groupe

CREATE DATABASE LINK lien_groupe_b
CONNECT TO techstore IDENTIFIED BY "TechStore#2026"
USING '(DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=192.168.1.30)(PORT=1521))
    (CONNECT_DATA=(SERVICE_NAME=FREEPDB1))
)';

-- ============================================================
-- SECTION 4 : REQUÊTES VIA LE DATABASE LINK
-- ============================================================

-- Tester la connexion vers l'autre groupe
SELECT 'Connexion OK' AS statut FROM dual@lien_groupe_b;

-- Afficher les produits de l'autre groupe
SELECT code_produit, nom, prix_vente, stock
FROM produit@lien_groupe_b
ORDER BY nom;

-- Afficher les clients de l'autre groupe
SELECT id_client, nom, prenom, ville
FROM client@lien_groupe_b
ORDER BY nom;

-- Comparer le nombre de produits entre les deux bases
SELECT 'Notre base'        AS source, COUNT(*) AS nb_produits FROM produit
UNION ALL
SELECT 'Base autre groupe',            COUNT(*)               FROM produit@lien_groupe_b;

-- ============================================================
-- SECTION 5 : SUPPRESSION DU DATABASE LINK
-- ============================================================

DROP DATABASE LINK lien_groupe_b;

-- Vérifier la suppression
SELECT db_link FROM user_db_links;
