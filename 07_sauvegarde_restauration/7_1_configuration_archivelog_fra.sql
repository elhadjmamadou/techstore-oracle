-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 7_1_configuration_archivelog_fra.sql
-- Objectif: Activer le mode ARCHIVELOG et configurer la FRA
-- ============================================================
-- ⚠️  IMPORTANT : Ce script DOIT être exécuté en tant que SYSDBA.
--     Il ne peut PAS être exécuté avec l'utilisateur TECHSTORE.
--
-- Commande pour se connecter en SYSDBA via Docker :
--   docker exec -it oracle-free sqlplus 'sys/ChangeMoiFort123!@//localhost:1521/FREE as sysdba'
--
-- OU directement dans le conteneur :
--   docker exec -it oracle-free bash
--   sqlplus / as sysdba
-- ============================================================

-- 1. Vérifier le mode actuel (NOARCHIVELOG ou ARCHIVELOG)
ARCHIVE LOG LIST;

-- 2. Arrêter la base proprement
SHUTDOWN IMMEDIATE;

-- 3. Démarrer en mode MOUNT (sans ouvrir les données)
STARTUP MOUNT;

-- 4. Activer le mode ARCHIVELOG
ALTER DATABASE ARCHIVELOG;

-- 5. Ouvrir la base
ALTER DATABASE OPEN;

-- 6. Ouvrir toutes les PDB (Oracle 23c Free = FREEPDB1)
ALTER PLUGGABLE DATABASE ALL OPEN;

-- 7. Sauvegarder l'état pour redémarrage automatique
ALTER PLUGGABLE DATABASE ALL SAVE STATE;

-- 8. Configurer la Flash Recovery Area (FRA)
--    Taille : 10 Go | Rétention : 7 jours (configurée dans RMAN)
ALTER SYSTEM SET db_recovery_file_dest_size = 10G SCOPE=BOTH;
ALTER SYSTEM SET db_recovery_file_dest = '/opt/oracle/oradata/recovery_area' SCOPE=BOTH;

-- 9. Vérification finale
ARCHIVE LOG LIST;
SHOW PARAMETER db_recovery_file_dest;

-- Vérifier que les PDB sont ouvertes
SELECT name, open_mode FROM v$pdbs;
