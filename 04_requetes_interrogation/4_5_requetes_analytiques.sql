SELECT
   id_client,
   nom,
   prenom,
   montant_total_depense,
   RANK() OVER (ORDER BY montant_total_depense DESC) AS rang_rank,
   DENSE_RANK() OVER (ORDER BY montant_total_depense DESC) AS rang_dense_rank
FROM (
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
)
ORDER BY montant_total_depense DESC;

WITH ca_mensuel AS (
   SELECT
      TRUNC(date_commande, 'MM') AS mois,
      SUM(montant_total) AS chiffre_affaires
   FROM COMMANDE
   WHERE statut <> 'ANNULEE'
   GROUP BY TRUNC(date_commande, 'MM')
)
SELECT
   mois,
   chiffre_affaires,
   SUM(chiffre_affaires) OVER (
      ORDER BY mois
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
   ) AS ca_cumule_3_mois
FROM ca_mensuel
ORDER BY mois;

SELECT
   c.code_categorie,
   c.nom AS nom_categorie,
   SUM(lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100)) AS chiffre_affaires,
   ROUND(
      SUM(lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100))
      / SUM(SUM(lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100))) OVER ()
      * 100,
      2
   ) AS pourcentage_ca_total
FROM CATEGORIE c
JOIN PRODUIT p
   ON p.code_categorie = c.code_categorie
JOIN LIGNE_COMMANDE lc
   ON lc.code_produit = p.code_produit
JOIN COMMANDE cmd
   ON cmd.num_commande = lc.num_commande
WHERE cmd.statut <> 'ANNULEE'
GROUP BY c.code_categorie, c.nom
ORDER BY chiffre_affaires DESC;

SELECT
   code_produit,
   nom,
   code_categorie,
   prix_vente,
   ROUND(prix_moyen_categorie, 2) AS prix_moyen_categorie,
   ROUND(prix_vente - prix_moyen_categorie, 2) AS ecart_prix
FROM (
   SELECT
      p.code_produit,
      p.nom,
      p.code_categorie,
      p.prix_vente,
      AVG(p.prix_vente) OVER (
         PARTITION BY p.code_categorie
      ) AS prix_moyen_categorie
   FROM PRODUIT p
)
ORDER BY code_categorie, ecart_prix DESC;