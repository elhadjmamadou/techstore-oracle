-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : tests_securite.sql
-- Objectif: Vérifier les rôles, profils, utilisateurs et audit
-- Exécuter: Avec TECHSTORE (DBA) sur FREEPDB1
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- SECTION 1 : VÉRIFICATION DES RÔLES
-- ============================================================

SELECT role FROM dba_roles
WHERE role IN ('ROLE_VENTES', 'ROLE_STOCK', 'ROLE_ADMIN', 'ROLE_CLIENT')
ORDER BY role;

-- Privilèges accordés à chaque rôle
SELECT grantee, privilege, table_name
FROM dba_tab_privs
WHERE grantee IN ('ROLE_VENTES', 'ROLE_STOCK', 'ROLE_ADMIN', 'ROLE_CLIENT')
ORDER BY grantee, table_name;

-- ============================================================
-- SECTION 2 : VÉRIFICATION DES UTILISATEURS
-- ============================================================

SELECT username, account_status, profile, default_tablespace
FROM dba_users
WHERE username IN ('U_VENTES', 'U_STOCK', 'U_ADMIN', 'CLIENT_DEMO')
ORDER BY username;

-- Rôles attribués aux utilisateurs
SELECT grantee, granted_role
FROM dba_role_privs
WHERE grantee IN ('U_VENTES', 'U_STOCK', 'U_ADMIN', 'CLIENT_DEMO')
ORDER BY grantee;

-- ============================================================
-- SECTION 3 : VÉRIFICATION DU PROFIL DE SÉCURITÉ
-- ============================================================

SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile = 'PROFIL_SECURITE'
ORDER BY resource_name;

-- ============================================================
-- SECTION 4 : VÉRIFICATION DES TRIGGERS D'AUDIT
-- ============================================================

SELECT trigger_name, trigger_type, triggering_event, status
FROM user_triggers
WHERE trigger_name IN (
   'TRG_AUDIT_PRIX_PRODUIT',
   'TRG_AUDIT_SUPPRESSION_COMMANDE'
)
ORDER BY trigger_name;

-- ============================================================
-- SECTION 5 : TEST AUDIT MODIFICATION PRIX
-- ============================================================

-- Prix avant
SELECT code_produit, nom, prix_vente FROM PRODUIT WHERE code_produit = 'P001';

-- Modification du prix
UPDATE PRODUIT SET prix_vente = prix_vente + 1 WHERE code_produit = 'P001';

-- Vérification de l'audit
SELECT id_audit, code_produit, ancien_prix_vente, nouveau_prix_vente, utilisateur, date_modification
FROM AUDIT_PRIX_PRODUIT
ORDER BY id_audit DESC
FETCH FIRST 3 ROWS ONLY;

ROLLBACK;

-- ============================================================
-- SECTION 6 : TEST AUDIT SUPPRESSION COMMANDE
-- ============================================================

-- Commande avant suppression
SELECT num_commande, id_client, montant_total, statut
FROM COMMANDE WHERE num_commande = 50029;

-- Suppression
DELETE FROM COMMANDE WHERE num_commande = 50029;

-- Vérification de l'audit
SELECT id_audit, num_commande, id_client, montant_total, statut, utilisateur
FROM AUDIT_SUPPRESSION_COMMANDE
ORDER BY id_audit DESC
FETCH FIRST 3 ROWS ONLY;

ROLLBACK;

-- ============================================================
-- SECTION 7 : TEST VUE vue_mes_commandes (ROLE_CLIENT)
-- ============================================================

-- La vue filtre les commandes par utilisateur connecté
SELECT * FROM vue_mes_commandes;

-- ============================================================
-- SECTION 8 : VÉRIFICATION AUDIT CONNEXION
-- ============================================================

SELECT audit_option, success, failure
FROM dba_stmt_audit_opts
WHERE audit_option = 'CREATE SESSION';
