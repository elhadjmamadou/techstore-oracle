-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 2_2_creation_sequences.sql
-- Partie  : 02 - Creation des objets
-- Objectif: Creer les sequences qui generent les cles primaires
--           automatiquement (evite les doublons et les conflits)
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- SEQUENCE 1 : SEQ_CLIENT
-- Genere les identifiants des clients.
-- Demarre a 1000 pour les distinguer facilement des IDs techniques.
-- CACHE 20 : Oracle pre-alloue 20 valeurs en memoire → plus rapide.
-- ============================================================
CREATE SEQUENCE seq_client
START WITH 1000     -- Premier id_client = 1000
INCREMENT BY 1      -- +1 a chaque appel
CACHE 20            -- 20 valeurs pre-allouees en memoire
NOCYCLE;            -- Pas de remise a zero apres le maximum

-- ============================================================
-- SEQUENCE 2 : SEQ_COMMANDE
-- Genere les numeros de commande.
-- Demarre a 50000 : plage facilement identifiable en production.
-- NOCACHE : chaque valeur est validee immediatement (audit propre).
-- ============================================================
CREATE SEQUENCE seq_commande
START WITH 50000    -- Premier num_commande = 50000
INCREMENT BY 1
NOCACHE             -- Pas de pre-allocation (securite des numeros)
NOCYCLE;

-- ============================================================
-- SEQUENCE 3 : SEQ_AVIS
-- Genere les identifiants des avis clients.
-- CYCLE actif : repart de 1 apres 99999 (avis nombreux attendus).
-- Cas particulier : la seule sequence cyclique du projet.
-- ============================================================
CREATE SEQUENCE seq_avis
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 99999
NOCACHE
CYCLE;              -- Repart de MINVALUE apres MAXVALUE

-- ============================================================
-- SEQUENCE 4 : SEQ_STOCK_HISTORIQUE
-- Genere les identifiants des mouvements de stock.
-- Utilisee dans deux contextes :
--   1. Insertions manuelles dans 3_2_scripts_insertion.sql (IDs 1 a 15)
--   2. Trigger TRG_HISTORIQUE lors de chaque vente (IDs 16, 17, ...)
-- Garantit l'unicite meme en cas d'acces concurrent
-- (remplace l'ancienne methode NVL(MAX(id),0)+1 qui n'etait pas thread-safe).
-- ============================================================
CREATE SEQUENCE seq_stock_historique
START WITH 1        -- Commence a 1 pour les 15 mouvements initiaux
INCREMENT BY 1
NOCACHE             -- Pas de pre-allocation : chaque ID est definitif
NOCYCLE;
