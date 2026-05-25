-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 5_1_analyse_performances.sql
-- Partie  : 05 - Optimisation
-- Objectif: Analyser le plan d'execution d'une requete avant
--           et apres l'ajout d'un index d'optimisation
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- Note    : EXPLAIN PLAN est compatible DataGrip et SQL*Plus
-- ============================================================

-- ============================================================
-- ETAPE 1 : PLAN D'EXECUTION AVANT OPTIMISATION
-- EXPLAIN PLAN FOR : analyse la requete sans l'executer.
-- Stocke le plan dans la table interne PLAN_TABLE.
-- ============================================================
EXPLAIN PLAN FOR
SELECT
   c.id_client,
   c.nom,
   c.prenom,
   SUM(cmd.montant_total) AS montant_total_depense
FROM CLIENT c
JOIN COMMANDE cmd
   ON cmd.id_client = c.id_client
WHERE cmd.statut <> 'ANNULEE'
GROUP BY
   c.id_client,
   c.nom,
   c.prenom
ORDER BY montant_total_depense DESC
FETCH FIRST 10 ROWS ONLY;

-- Afficher le plan d'execution stocke
-- Operations possibles : TABLE ACCESS FULL, INDEX RANGE SCAN, HASH JOIN...
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Execution reelle de la requete (top 10 clients)
SELECT
   c.id_client,
   c.nom,
   c.prenom,
   SUM(cmd.montant_total) AS montant_total_depense
FROM CLIENT c
JOIN COMMANDE cmd
   ON cmd.id_client = c.id_client
WHERE cmd.statut <> 'ANNULEE'
GROUP BY
   c.id_client,
   c.nom,
   c.prenom
ORDER BY montant_total_depense DESC
FETCH FIRST 10 ROWS ONLY;

-- ============================================================
-- ETAPE 2 : AJOUT D'UN INDEX COMPOSE POUR OPTIMISER LA REQUETE
-- Cet index couvre les 3 colonnes utilisees par la requete :
--   - id_client  : condition de jointure avec CLIENT
--   - statut     : condition WHERE statut <> 'ANNULEE'
--   - montant_total : colonne agregee avec SUM()
-- Oracle peut ainsi lire uniquement l'index (INDEX RANGE SCAN)
-- au lieu de parcourir toute la table (TABLE ACCESS FULL).
-- ============================================================
CREATE INDEX idx_opt_commande_client_statut_montant
ON COMMANDE(id_client, statut, montant_total);

-- ============================================================
-- ETAPE 3 : PLAN D'EXECUTION APRES OPTIMISATION
-- Comparer ce plan avec le plan precedent.
-- On devrait observer : INDEX RANGE SCAN au lieu de TABLE ACCESS FULL.
-- ============================================================
EXPLAIN PLAN FOR
SELECT
   c.id_client,
   c.nom,
   c.prenom,
   SUM(cmd.montant_total) AS montant_total_depense
FROM CLIENT c
JOIN COMMANDE cmd
   ON cmd.id_client = c.id_client
WHERE cmd.statut <> 'ANNULEE'
GROUP BY
   c.id_client,
   c.nom,
   c.prenom
ORDER BY montant_total_depense DESC
FETCH FIRST 10 ROWS ONLY;

-- Afficher le nouveau plan
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Execution finale avec le nouvel index actif
SELECT
   c.id_client,
   c.nom,
   c.prenom,
   SUM(cmd.montant_total) AS montant_total_depense
FROM CLIENT c
JOIN COMMANDE cmd
   ON cmd.id_client = c.id_client
WHERE cmd.statut <> 'ANNULEE'
GROUP BY
   c.id_client,
   c.nom,
   c.prenom
ORDER BY montant_total_depense DESC
FETCH FIRST 10 ROWS ONLY;
