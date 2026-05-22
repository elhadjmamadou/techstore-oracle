SELECT
   cmd.num_commande,
   cmd.date_commande,
   c.id_client,
   c.nom AS nom_client,
   c.prenom AS prenom_client,
   p.code_produit,
   p.nom AS nom_produit,
   lc.quantite,
   lc.prix_unitaire,
   lc.remise,
   lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100) AS total_ligne
FROM COMMANDE cmd
JOIN CLIENT c
   ON c.id_client = cmd.id_client
JOIN LIGNE_COMMANDE lc
   ON lc.num_commande = cmd.num_commande
JOIN PRODUIT p
   ON p.code_produit = lc.code_produit
ORDER BY cmd.num_commande, lc.id_ligne;

WITH categorie_chemin AS (
   SELECT
      code_categorie,
      LTRIM(SYS_CONNECT_BY_PATH(nom, ' > '), ' > ') AS chemin_categorie
   FROM CATEGORIE
   START WITH code_categorie_parent IS NULL
   CONNECT BY PRIOR code_categorie = code_categorie_parent
)
SELECT
   p.code_produit,
   p.nom AS nom_produit,
   cc.chemin_categorie
FROM PRODUIT p
JOIN categorie_chemin cc
   ON cc.code_categorie = p.code_categorie
ORDER BY cc.chemin_categorie, p.nom;

SELECT
   c.id_client,
   c.nom,
   c.prenom,
   c.email,
   c.ville
FROM CLIENT c
LEFT JOIN COMMANDE cmd
   ON cmd.id_client = c.id_client
WHERE cmd.num_commande IS NULL
ORDER BY c.nom, c.prenom;

SELECT
   f.id_fournisseur,
   f.raison_sociale,
   SUM(lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100)) AS chiffre_affaires
FROM FOURNISSEUR f
JOIN PRODUIT p
   ON p.id_fournisseur = f.id_fournisseur
JOIN LIGNE_COMMANDE lc
   ON lc.code_produit = p.code_produit
JOIN COMMANDE cmd
   ON cmd.num_commande = lc.num_commande
WHERE cmd.statut <> 'ANNULEE'
GROUP BY f.id_fournisseur, f.raison_sociale
ORDER BY chiffre_affaires DESC;