BEGIN
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'CATEGORIE');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'FOURNISSEUR');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'CLIENT');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'PRODUIT');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'COMMANDE');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'LIGNE_COMMANDE');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'AVIS');
   DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TECHSTORE', tabname => 'STOCK_HISTORIQUE');
END;
/

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

SELECT
   'COMMANDE.STATUT' AS colonne_candidate,
   COUNT(DISTINCT statut) AS nombre_valeurs_distinctes,
   COUNT(*) AS nombre_lignes
FROM COMMANDE;

SELECT
   'PRODUIT.STATUT' AS colonne_candidate,
   COUNT(DISTINCT statut) AS nombre_valeurs_distinctes,
   COUNT(*) AS nombre_lignes
FROM PRODUIT;

SELECT
   'STOCK_HISTORIQUE.TYPE_MOUVEMENT' AS colonne_candidate,
   COUNT(DISTINCT type_mouvement) AS nombre_valeurs_distinctes,
   COUNT(*) AS nombre_lignes
FROM STOCK_HISTORIQUE;

SELECT
   'AVIS.NOTE' AS colonne_candidate,
   COUNT(DISTINCT note) AS nombre_valeurs_distinctes,
   COUNT(*) AS nombre_lignes
FROM AVIS;