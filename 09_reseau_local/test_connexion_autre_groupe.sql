-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : test_connexion_autre_groupe.sql
-- Partie  : 09 - Reseau local
-- Objectif: Tester la connexion locale, creer un DATABASE LINK
--           vers l'autre groupe et executer des requetes croisees
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- SECTION 1 : TESTS DE CONNEXION LOCALE
-- Verifier que l'environnement Oracle est bien configure
-- avant de tester la connexion distante.
-- ============================================================

-- Confirmer l'utilisateur connecte (doit afficher TECHSTORE)
SELECT USER FROM dual;

-- Verifier le service Oracle actif (doit afficher FREEPDB1)
SELECT SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service FROM dual;

-- Afficher le nom de la base de donnees
SELECT SYS_CONTEXT('USERENV', 'DB_NAME') AS base FROM dual;

-- Verifier que Oracle repond (date et heure serveur)
SELECT SYSDATE FROM dual;

-- ============================================================
-- SECTION 2 : VERIFICATION DES DONNEES LOCALES
-- S'assurer que nos tables sont bien accessibles avant
-- d'essayer de les comparer avec la base distante.
-- ============================================================

-- Lister toutes les tables du schema TECHSTORE
SELECT table_name FROM user_tables ORDER BY table_name;

-- Afficher le catalogue local (test simple)
SELECT code_produit, nom, prix_vente, stock
FROM produit
ORDER BY nom;

-- Compter les enregistrements par table (verite terrain)
SELECT 'CLIENT'      AS table_name, COUNT(*) AS nb FROM client      UNION ALL
SELECT 'PRODUIT',                   COUNT(*)        FROM produit     UNION ALL
SELECT 'COMMANDE',                  COUNT(*)        FROM commande    UNION ALL
SELECT 'FOURNISSEUR',               COUNT(*)        FROM fournisseur;

-- ============================================================
-- SECTION 3 : CREATION DU DATABASE LINK VERS L'AUTRE GROUPE
-- Un DATABASE LINK est un alias qui pointe vers une base distante.
-- Permet d'executer des SELECT sur la base de l'autre groupe
-- directement depuis notre session, avec la syntaxe table@lien.
-- IMPORTANT : Remplacer 192.168.1.30 par l'IP reelle de l'autre poste.
-- ============================================================
CREATE DATABASE LINK lien_groupe_b
CONNECT TO techstore IDENTIFIED BY "TechStore#2026"
USING '(DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=192.168.1.30)(PORT=1521))
    (CONNECT_DATA=(SERVICE_NAME=FREEPDB1))
)';
-- → HOST : IP de la machine de l'autre groupe (a remplacer)
-- → PORT : 1521 (standard Oracle)
-- → SERVICE_NAME : FREEPDB1 (meme service sur les deux postes)

-- ============================================================
-- SECTION 4 : REQUETES VIA LE DATABASE LINK
-- La syntaxe table@nom_du_lien permet d'acceder aux tables distantes.
-- Oracle etablit la connexion a la base distante de maniere transparente.
-- ============================================================

-- Tester que la connexion distante fonctionne
SELECT 'Connexion OK' AS statut FROM dual@lien_groupe_b;

-- Lire les produits de la base distante (autre groupe)
SELECT code_produit, nom, prix_vente, stock
FROM produit@lien_groupe_b
ORDER BY nom;

-- Lire les clients de la base distante
SELECT id_client, nom, prenom, ville
FROM client@lien_groupe_b
ORDER BY nom;

-- Comparer le nombre de produits entre nos deux bases
SELECT 'Notre base'        AS source, COUNT(*) AS nb_produits FROM produit
UNION ALL
SELECT 'Base autre groupe',            COUNT(*)               FROM produit@lien_groupe_b;

-- ============================================================
-- SECTION 5 : SUPPRESSION DU DATABASE LINK (nettoyage)
-- Supprimer le lien apres les tests pour eviter les connexions
-- residuelles vers la base distante.
-- ============================================================
DROP DATABASE LINK lien_groupe_b;

-- Verifier que le lien a bien ete supprime (resultat vide attendu)
SELECT db_link FROM user_db_links;
