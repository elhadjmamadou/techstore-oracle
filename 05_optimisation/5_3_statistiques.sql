-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 5_3_statistiques.sql
-- Partie  : 05 - Optimisation
-- Objectif: Collecter les statistiques Oracle pour que l'optimiseur
--           puisse choisir le meilleur plan d'execution
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- ETAPE 1 : COLLECTE DES STATISTIQUES SUR TOUTES LES TABLES
-- DBMS_STATS.GATHER_TABLE_STATS analyse chaque table :
--   - nombre de lignes
--   - distribution des valeurs par colonne
--   - densite des index
-- L'optimiseur Oracle utilise ces statistiques pour choisir
-- entre un full scan et un index range scan.
-- ============================================================
BEGIN
   -- Statistiques sur les tables de reference
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'CATEGORIE');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'FOURNISSEUR');
   -- Statistiques sur les tables principales
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'CLIENT');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'PRODUIT');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'COMMANDE');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'LIGNE_COMMANDE');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'AVIS');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'STOCK_HISTORIQUE');
END;
/

-- ============================================================
-- ETAPE 2 : VERIFICATION DES STATISTIQUES COLLECTEES
-- num_rows : nombre de lignes (doit etre coherent avec nos insertions)
-- blocks : nombre de blocs Oracle utilises
-- last_analyzed : date de la derniere collecte de statistiques
-- ============================================================
SELECT
   table_name,
   num_rows,
   blocks,
   last_analyzed
FROM user_tables
WHERE table_name IN (
   'CATEGORIE',
   'FOURNISSEUR',
   'CLIENT',
   'PRODUIT',
   'COMMANDE',
   'LIGNE_COMMANDE',
   'AVIS',
   'STOCK_HISTORIQUE'
)
ORDER BY table_name;

-- ============================================================
-- ETAPE 3 : STATISTIQUES DES COLONNES (nulls et selectivite)
-- num_nulls : nombre de valeurs NULL dans la colonne
-- num_distinct : nombre de valeurs distinctes
-- density : probabilite de trouver une valeur exacte (1/num_distinct)
-- Colonnes avec beaucoup de NULL → mauvais candidats pour un index.
-- ============================================================
SELECT
   table_name,
   column_name,
   num_nulls,
   num_distinct,
   density
FROM user_tab_col_statistics
WHERE table_name IN (
   'CATEGORIE',
   'FOURNISSEUR',
   'CLIENT',
   'PRODUIT',
   'COMMANDE',
   'LIGNE_COMMANDE',
   'AVIS',
   'STOCK_HISTORIQUE'
)
AND num_nulls > 0
ORDER BY table_name, num_nulls DESC;

-- ============================================================
-- ETAPE 4 : CANDIDATS AUX INDEX BITMAP (faible cardinalite)
-- Un index bitmap est efficace si le nombre de valeurs distinctes
-- est tres faible par rapport au nombre total de lignes.
-- On evalue la cardinalite de 4 colonnes potentielles.
-- ============================================================

-- Statut des commandes : 5 valeurs distinctes pour 30 lignes → bitmap ideal
SELECT
   'COMMANDE.STATUT' AS colonne_candidate,
   COUNT(DISTINCT statut) AS nombre_valeurs_distinctes,
   COUNT(*) AS nombre_lignes
FROM COMMANDE;

-- Statut des produits : 2 valeurs (ACTIF/INACTIF) → bitmap tres efficace
SELECT
   'PRODUIT.STATUT' AS colonne_candidate,
   COUNT(DISTINCT statut) AS nombre_valeurs_distinctes,
   COUNT(*) AS nombre_lignes
FROM PRODUIT;

-- Type de mouvement : 2 valeurs (ENTREE/SORTIE) → bitmap tres efficace
SELECT
   'STOCK_HISTORIQUE.TYPE_MOUVEMENT' AS colonne_candidate,
   COUNT(DISTINCT type_mouvement) AS nombre_valeurs_distinctes,
   COUNT(*) AS nombre_lignes
FROM STOCK_HISTORIQUE;

-- Note des avis : 5 valeurs (1 a 5) → bitmap adapte
SELECT
   'AVIS.NOTE' AS colonne_candidate,
   COUNT(DISTINCT note) AS nombre_valeurs_distinctes,
   COUNT(*) AS nombre_lignes
FROM AVIS;
