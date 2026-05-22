CREATE OR REPLACE VIEW vue_produits_stock_faible AS
SELECT
   code_produit,
   nom,
   stock,
   seuil_alerte,
   statut
FROM PRODUIT
WHERE stock < seuil_alerte;

CREATE OR REPLACE VIEW vue_top_clients AS
SELECT
   c.id_client,
   c.nom,
   c.prenom,
   c.email,
   SUM(cmd.montant_total) AS montant_total_depense
FROM CLIENT c
JOIN COMMANDE cmd
   ON c.id_client = cmd.id_client
WHERE cmd.statut <> 'ANNULEE'
GROUP BY
   c.id_client,
   c.nom,
   c.prenom,
   c.email
HAVING SUM(cmd.montant_total) > 1000;

CREATE OR REPLACE VIEW vue_stats_ventes_mensuelles AS
SELECT
   TRUNC(date_commande, 'MM') AS mois,
   COUNT(*) AS nombre_commandes,
   SUM(montant_total) AS chiffre_affaires
FROM COMMANDE
WHERE statut <> 'ANNULEE'
GROUP BY TRUNC(date_commande, 'MM')
WITH READ ONLY;

CREATE OR REPLACE VIEW vue_commandes_recentes AS
SELECT
   num_commande,
   id_client,
   date_commande,
   date_livraison_prevue,
   date_livraison_reelle,
   montant_total,
   statut
FROM COMMANDE
WHERE date_commande >= SYSDATE - 30;