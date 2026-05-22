SELECT
   statut,
   COUNT(*) AS nombre_commandes,
   SUM(montant_total) AS montant_total
FROM COMMANDE
GROUP BY statut
ORDER BY statut;

SELECT
   c.code_categorie,
   c.nom AS nom_categorie,
   ROUND(AVG(p.prix_vente), 2) AS prix_moyen
FROM CATEGORIE c
JOIN PRODUIT p
   ON p.code_categorie = c.code_categorie
GROUP BY c.code_categorie, c.nom
ORDER BY c.nom;

SELECT
   c.id_client,
   c.nom,
   c.prenom,
   COUNT(cmd.num_commande) AS nombre_commandes
FROM CLIENT c
JOIN COMMANDE cmd
   ON cmd.id_client = c.id_client
GROUP BY c.id_client, c.nom, c.prenom
HAVING COUNT(cmd.num_commande) > 1
ORDER BY nombre_commandes DESC;

SELECT
   p.code_produit,
   p.nom AS nom_produit,
   ROUND(AVG(a.note), 2) AS note_moyenne,
   COUNT(a.id_avis) AS nombre_avis
FROM PRODUIT p
LEFT JOIN AVIS a
   ON a.code_produit = p.code_produit
GROUP BY p.code_produit, p.nom
ORDER BY note_moyenne DESC NULLS LAST, nombre_avis DESC;