SELECT
   p.code_produit,
   p.nom,
   SUM(lc.quantite) AS quantite_totale_vendue
FROM PRODUIT p
JOIN LIGNE_COMMANDE lc
   ON lc.code_produit = p.code_produit
GROUP BY p.code_produit, p.nom
HAVING SUM(lc.quantite) > (
   SELECT AVG(total_quantite)
   FROM (
      SELECT SUM(quantite) AS total_quantite
      FROM LIGNE_COMMANDE
      GROUP BY code_produit
   )
)
ORDER BY quantite_totale_vendue DESC;

SELECT
   c.id_client,
   c.nom,
   c.prenom,
   SUM(cmd.montant_total) AS montant_total_depense
FROM CLIENT c
JOIN COMMANDE cmd
   ON cmd.id_client = c.id_client
WHERE cmd.statut <> 'ANNULEE'
GROUP BY c.id_client, c.nom, c.prenom
HAVING SUM(cmd.montant_total) > (
   SELECT AVG(total_client)
   FROM (
      SELECT SUM(montant_total) AS total_client
      FROM COMMANDE
      WHERE statut <> 'ANNULEE'
      GROUP BY id_client
   )
)
ORDER BY montant_total_depense DESC;

SELECT
   p.code_produit,
   p.nom,
   p.prix_vente,
   p.stock
FROM PRODUIT p
WHERE p.code_produit NOT IN (
   SELECT lc.code_produit
   FROM LIGNE_COMMANDE lc
)
ORDER BY p.nom;

SELECT
   num_commande,
   id_client,
   date_commande,
   montant_total,
   statut
FROM COMMANDE
WHERE montant_total > (
   SELECT MEDIAN(montant_total)
   FROM COMMANDE
)
ORDER BY montant_total DESC;