-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 5_2_partitionnement.sql
-- Partie  : 05 - Optimisation
-- Objectif: Creer une version partitionnee de la table COMMANDE
--           pour illustrer le partitionnement par plage (RANGE)
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================
-- Justification du partitionnement :
-- La table COMMANDE est interrogee quasi-systematiquement avec
-- un filtre sur date_commande (analyses mensuelles, CA par periode).
-- Le partitionnement par plage trimestrielle :
--   1. Limite les blocs parcourus a la partition concernee (partition pruning)
--   2. Facilite l'archivage (DROP PARTITION d'un trimestre perime)
--   3. Ameliore les statistiques par partition
-- ============================================================
-- NOTE : la version precedente utilisait CREATE TABLE ... AS SELECT *
-- qui copie les donnees mais PAS les contraintes (PK, CHECK, FK).
-- Cette version declare les contraintes explicitement, puis insere.
-- ============================================================

-- ============================================================
-- ETAPE 1 : CREATION DE LA TABLE PARTITIONNEE
-- Structure identique a COMMANDE avec ses contraintes declarees.
-- La clause PARTITION BY RANGE divise la table selon date_commande.
-- ============================================================
CREATE TABLE COMMANDE_PARTITIONNEE
(
   num_commande          NUMBER(10)    NOT NULL,
   id_client             NUMBER(10)    NOT NULL,
   date_commande         DATE          NOT NULL,
   date_livraison_prevue DATE,
   date_livraison_reelle DATE,
   montant_total         NUMBER(12,2)  DEFAULT 0 NOT NULL,
   statut                VARCHAR2(20)  DEFAULT 'EN_ATTENTE' NOT NULL,

   -- Cle primaire declaree explicitement (non copie par CTAS)
   CONSTRAINT pk_commande_part    PRIMARY KEY (num_commande),
   -- Le montant ne peut pas etre negatif
   CONSTRAINT ck_cp_montant       CHECK (montant_total >= 0),
   -- Statuts valides (meme liste que COMMANDE)
   CONSTRAINT ck_cp_statut        CHECK (statut IN ('EN_ATTENTE','CONFIRMEE','EXPEDIEE','LIVREE','ANNULEE')),
   -- Une commande ANNULEE n'a pas de date de livraison
   CONSTRAINT ck_cp_annulee       CHECK (
      statut <> 'ANNULEE'
      OR (date_livraison_prevue IS NULL AND date_livraison_reelle IS NULL)
   )
   -- NOTE : FK vers CLIENT non ajoutee (limitation Oracle sur tables partitionnees)
)
-- Partitionnement par plage sur la date de commande
PARTITION BY RANGE (date_commande)
(
   -- T4 2025 : commandes de decembre 2025
   PARTITION cmd_2025_t4 VALUES LESS THAN (DATE '2026-01-01'),
   -- T1 2026 : janvier, fevrier, mars 2026
   PARTITION cmd_2026_t1 VALUES LESS THAN (DATE '2026-04-01'),
   -- T2 2026 : avril, mai, juin 2026
   PARTITION cmd_2026_t2 VALUES LESS THAN (DATE '2026-07-01'),
   -- T3 2026 : juillet, aout, septembre 2026
   PARTITION cmd_2026_t3 VALUES LESS THAN (DATE '2026-10-01'),
   -- T4 2026 : octobre, novembre, decembre 2026
   PARTITION cmd_2026_t4 VALUES LESS THAN (DATE '2027-01-01'),
   -- Partition fourre-tout pour les dates au-dela de 2026
   PARTITION cmd_autres  VALUES LESS THAN (MAXVALUE)
);

-- ============================================================
-- ETAPE 2 : CHARGEMENT DES DONNEES DEPUIS LA TABLE ORIGINALE
-- INSERT ... SELECT copie toutes les donnees de COMMANDE.
-- Oracle repartit automatiquement chaque ligne dans la bonne partition
-- selon la valeur de date_commande.
-- ============================================================
INSERT INTO COMMANDE_PARTITIONNEE
SELECT * FROM COMMANDE;

COMMIT;

-- ============================================================
-- ETAPE 3 : VERIFICATION DES PARTITIONS
-- Affiche le nom de chaque partition et sa valeur haute (high_value).
-- ============================================================
SELECT table_name, partition_name, high_value, num_rows
FROM user_tab_partitions
WHERE table_name = 'COMMANDE_PARTITIONNEE'
ORDER BY partition_position;

-- ============================================================
-- ETAPE 4 : REQUETES AVEC PARTITION PRUNING
-- Avec la clause PARTITION(nom_partition), Oracle ne lit que
-- la partition specifiee → beaucoup plus rapide sur grandes tables.
-- ============================================================

-- Compter les commandes par trimestre (partition pruning)
SELECT 'T4-2025' AS trimestre, COUNT(*) AS nombre_commandes
FROM COMMANDE_PARTITIONNEE PARTITION (cmd_2025_t4)
UNION ALL
SELECT 'T1-2026', COUNT(*)
FROM COMMANDE_PARTITIONNEE PARTITION (cmd_2026_t1)
UNION ALL
SELECT 'T2-2026', COUNT(*)
FROM COMMANDE_PARTITIONNEE PARTITION (cmd_2026_t2);
