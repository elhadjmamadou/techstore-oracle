-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 6_2_profils_utilisateurs.sql
-- Partie  : 06 - Administration et securite
-- Objectif: Creer un profil de securite et l'appliquer aux
--           utilisateurs du projet
-- Executer: Avec l'utilisateur TECHSTORE (DBA) sur FREEPDB1
-- ============================================================

-- ============================================================
-- ETAPE 1 : CREATION DU PROFIL DE SECURITE
-- Un profil definit les contraintes de mot de passe et de session.
-- PASSWORD_LIFE_TIME : le mot de passe expire apres 90 jours
-- FAILED_LOGIN_ATTEMPTS : le compte est bloque apres 3 echecs
-- PASSWORD_LOCK_TIME : le compte reste bloque 1 jour
-- IDLE_TIME : la session est deconnectee apres 30 min d'inactivite
-- ============================================================
CREATE PROFILE profil_securite LIMIT
   PASSWORD_LIFE_TIME     90,   -- Renouvellement obligatoire tous les 90 jours
   FAILED_LOGIN_ATTEMPTS   3,   -- 3 tentatives incorrectes = compte bloque
   PASSWORD_LOCK_TIME      1,   -- Blocage pendant 1 jour
   IDLE_TIME              30;   -- Deconnexion automatique apres 30 min d'inactivite

-- ============================================================
-- ETAPE 2 : APPLICATION DU PROFIL AUX UTILISATEURS
-- On applique le meme profil de securite a tous les utilisateurs
-- du projet pour garantir une politique coherente.
-- ============================================================
ALTER USER u_ventes    PROFILE profil_securite;
ALTER USER u_stock     PROFILE profil_securite;
ALTER USER u_admin     PROFILE profil_securite;
ALTER USER client_demo PROFILE profil_securite;

-- ============================================================
-- ETAPE 3 : VERIFICATION DU PROFIL
-- Verifier que le profil est bien cree avec les bons parametres.
-- ============================================================
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile = 'PROFIL_SECURITE'
ORDER BY resource_name;

-- Verifier que chaque utilisateur a bien le profil attribue
SELECT username, profile
FROM dba_users
WHERE username IN ('U_VENTES', 'U_STOCK', 'U_ADMIN', 'CLIENT_DEMO')
ORDER BY username;
