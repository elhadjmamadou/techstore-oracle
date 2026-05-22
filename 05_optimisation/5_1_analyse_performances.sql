

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

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

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

CREATE INDEX idx_opt_commande_client_statut_montant
ON COMMANDE(id_client, statut, montant_total);

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

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

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

