-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 4_4_sous_requetes.sql
-- Partie  : 04 - Requetes d'interrogation
-- Objectif: Utiliser les sous-requetes pour des analyses avancees
--           (scalaires, correlees, IN, NOT IN, MEDIAN)
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- REQUETE 1 : Produits dont la quantite vendue est superieure
--             a la moyenne de toutes les ventes par produit
-- Sous-requete imbriquee en deux niveaux :
--   Niveau 2 : total vendu par produit (SUM + GROUP BY)
--   Niveau 1 : moyenne de ces totaux (AVG)
-- HAVING compare le total de chaque produit a cette moyenne.
-- ============================================================
SELECT
   p.code_produit,
   p.nom,
   SUM(lc.quantite) AS quantite_totale_vendue
FROM PRODUIT p
JOIN LIGNE_COMMANDE lc
   ON lc.code_produit = p.code_produit
GROUP BY p.code_produit, p.nom
-- Comparer le total vendu de chaque produit a la moyenne generale
HAVING SUM(lc.quantite) > (
   SELECT AVG(total_quantite)
   FROM (
      -- Sous-requete : total vendu par produit
      SELECT SUM(quantite) AS total_quantite
      FROM LIGNE_COMMANDE
      GROUP BY code_produit
   )
)
ORDER BY quantite_totale_vendue DESC;

-- ============================================================
-- REQUETE 2 : Clients dont le montant total depense est
--             superieur a la moyenne des depenses par client
-- Meme logique que la requete 1 mais sur les montants clients.
-- On exclut les commandes annulees.
-- ============================================================
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
-- Comparer les depenses de chaque client a la moyenne generale
HAVING SUM(cmd.montant_total) > (
   SELECT AVG(total_client)
   FROM (
      -- Sous-requete : total depense par client (commandes valides)
      SELECT SUM(montant_total) AS total_client
      FROM COMMANDE
      WHERE statut <> 'ANNULEE'
      GROUP BY id_client
   )
)
ORDER BY montant_total_depense DESC;

-- ============================================================
-- REQUETE 3 : Produits qui n'ont jamais ete vendus
-- NOT IN : exclut les produits presents dans LIGNE_COMMANDE.
-- Permet d'identifier les produits sans aucune vente.
-- ============================================================
SELECT
   p.code_produit,
   p.nom,
   p.prix_vente,
   p.stock
FROM PRODUIT p
-- Produits absents de toutes les lignes de commande
WHERE p.code_produit NOT IN (
   SELECT lc.code_produit
   FROM LIGNE_COMMANDE lc
)
ORDER BY p.nom;

-- ============================================================
-- REQUETE 4 : Commandes dont le montant est superieur
--             a la mediane de tous les montants de commande
-- MEDIAN() : valeur centrale d'une distribution (moins sensible
--            aux valeurs extremes que la moyenne).
-- ============================================================
SELECT
   num_commande,
   id_client,
   date_commande,
   montant_total,
   statut
FROM COMMANDE
-- MEDIAN calcule la valeur mediane des montants de toutes les commandes
WHERE montant_total > (
   SELECT MEDIAN(montant_total)
   FROM COMMANDE
)
ORDER BY montant_total DESC;
