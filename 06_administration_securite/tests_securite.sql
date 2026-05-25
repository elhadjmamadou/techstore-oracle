-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : tests_securite.sql
-- Partie  : 06 - Administration et securite
-- Objectif: Verifier les roles, profils, utilisateurs et audit
-- Executer: Avec TECHSTORE (DBA) sur FREEPDB1
-- ============================================================
SET SERVEROUTPUT ON;

-- ============================================================
-- SECTION 1 : VERIFICATION DES ROLES
-- Verifier que les 4 roles ont ete correctement crees.
-- ============================================================
SELECT role FROM dba_roles
WHERE role IN ('ROLE_VENTES', 'ROLE_STOCK', 'ROLE_ADMIN', 'ROLE_CLIENT')
ORDER BY role;

-- Lister les privileges accordes a chaque role
-- Permet de verifier que les bons acces ont ete attribues
SELECT grantee, privilege, table_name
FROM dba_tab_privs
WHERE grantee IN ('ROLE_VENTES', 'ROLE_STOCK', 'ROLE_ADMIN', 'ROLE_CLIENT')
ORDER BY grantee, table_name;

-- ============================================================
-- SECTION 2 : VERIFICATION DES UTILISATEURS
-- Chaque utilisateur doit etre OPEN et avoir le bon profil.
-- ============================================================
SELECT username, account_status, profile, default_tablespace
FROM dba_users
WHERE username IN ('U_VENTES', 'U_STOCK', 'U_ADMIN', 'CLIENT_DEMO')
ORDER BY username;

-- Verifier que chaque utilisateur a bien son role metier
SELECT grantee, granted_role
FROM dba_role_privs
WHERE grantee IN ('U_VENTES', 'U_STOCK', 'U_ADMIN', 'CLIENT_DEMO')
ORDER BY grantee;

-- ============================================================
-- SECTION 3 : VERIFICATION DU PROFIL DE SECURITE
-- Verifier les parametres : 90 jours, 3 tentatives, 30 min idle
-- ============================================================
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile = 'PROFIL_SECURITE'
ORDER BY resource_name;

-- ============================================================
-- SECTION 4 : VERIFICATION DES TRIGGERS D'AUDIT
-- Les deux triggers doivent etre en statut ENABLED.
-- ============================================================
SELECT trigger_name, trigger_type, triggering_event, status
FROM user_triggers
WHERE trigger_name IN (
   'TRG_AUDIT_PRIX_PRODUIT',
   'TRG_AUDIT_SUPPRESSION_COMMANDE'
)
ORDER BY trigger_name;

-- ============================================================
-- SECTION 5 : TEST AUDIT MODIFICATION DE PRIX
-- Modifier le prix de P001 et verifier que l'audit est trace.
-- Resultat attendu : une entree dans AUDIT_PRIX_PRODUIT avec
-- l'ancien prix, le nouveau prix et l'utilisateur TECHSTORE.
-- ============================================================

-- Prix actuel avant modification
SELECT code_produit, nom, prix_vente FROM PRODUIT WHERE code_produit = 'P001';

-- Modification qui declenche TRG_AUDIT_PRIX_PRODUIT
UPDATE PRODUIT SET prix_vente = prix_vente + 1 WHERE code_produit = 'P001';

-- Verifier la trace d'audit
SELECT id_audit, code_produit, ancien_prix_vente, nouveau_prix_vente, utilisateur, date_modification
FROM AUDIT_PRIX_PRODUIT
ORDER BY id_audit DESC
FETCH FIRST 3 ROWS ONLY;

-- Annuler la modification de prix (test uniquement)
ROLLBACK;

-- ============================================================
-- SECTION 6 : TEST AUDIT SUPPRESSION DE COMMANDE
-- Supprimer la commande 50007 (ANNULEE, sans enfant dans LIGNE_COMMANDE)
-- et verifier que TRG_AUDIT_SUPPRESSION_COMMANDE a bien trace la suppression.
-- NOTE : on utilise 50007 (ANNULEE, 0 ligne enfant) et non 50029 qui a
--        2 lignes dans LIGNE_COMMANDE → ORA-02292 si on tente de supprimer 50029.
-- ============================================================

-- Commande avant suppression
SELECT num_commande, id_client, montant_total, statut
FROM COMMANDE WHERE num_commande = 50007;

-- Suppression (declenche TRG_AUDIT_SUPPRESSION_COMMANDE)
DELETE FROM COMMANDE WHERE num_commande = 50007;

-- Verifier la trace d'audit (doit contenir la commande supprimee)
SELECT id_audit, num_commande, id_client, montant_total, statut, utilisateur
FROM AUDIT_SUPPRESSION_COMMANDE
ORDER BY id_audit DESC
FETCH FIRST 3 ROWS ONLY;

-- Annuler la suppression (test uniquement)
ROLLBACK;

-- ============================================================
-- SECTION 7 : TEST VUE vue_mes_commandes (ROLE_CLIENT)
-- La vue filtre automatiquement les commandes par utilisateur connecte.
-- Si execute en tant que TECHSTORE, retourne vide (pas dans UTILISATEUR_CLIENT).
-- Si execute en tant que CLIENT_DEMO, retourne les commandes du client 1000.
-- ============================================================
SELECT * FROM vue_mes_commandes;

-- ============================================================
-- SECTION 8 : VERIFICATION AUDIT CONNEXION (Oracle unifie)
-- Verifier que l'audit des connexions echouees est active.
-- ============================================================
SELECT audit_option, success, failure
FROM dba_stmt_audit_opts
WHERE audit_option = 'CREATE SESSION';
