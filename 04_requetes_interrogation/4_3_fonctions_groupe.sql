-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 4_3_fonctions_groupe.sql
-- Partie  : 04 - Requetes d'interrogation
-- Objectif: Utiliser les fonctions d'agregation (GROUP BY, HAVING,
--           COUNT, SUM, AVG) pour des analyses statistiques
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- REQUETE 1 : Nombre et montant total des commandes par statut
-- Donne une vue d'ensemble de l'etat du portefeuille de commandes.
-- Utile pour suivre les commandes en attente ou les annulations.
-- ============================================================
SELECT
   statut,
   COUNT(*) AS nombre_commandes,
   SUM(montant_total) AS montant_total
FROM COMMANDE
GROUP BY statut
ORDER BY statut;

-- ============================================================
-- REQUETE 2 : Prix moyen des produits par categorie
-- JOIN entre CATEGORIE et PRODUIT pour avoir le nom de la categorie.
-- ROUND(..., 2) arrondit le resultat a 2 decimales.
-- ============================================================
SELECT
   c.code_categorie,
   c.nom AS nom_categorie,
   ROUND(AVG(p.prix_vente), 2) AS prix_moyen
FROM CATEGORIE c
JOIN PRODUIT p
   ON p.code_categorie = c.code_categorie
GROUP BY c.code_categorie, c.nom
ORDER BY c.nom;

-- ============================================================
-- REQUETE 3 : Clients ayant passe plus d'une commande
-- HAVING filtre les groupes apres agregation (≠ WHERE qui filtre les lignes).
-- Permet d'identifier les clients fideles et les acheteurs reguliers.
-- ============================================================
SELECT
   c.id_client,
   c.nom,
   c.prenom,
   COUNT(cmd.num_commande) AS nombre_commandes
FROM CLIENT c
JOIN COMMANDE cmd
   ON cmd.id_client = c.id_client
GROUP BY c.id_client, c.nom, c.prenom
-- Garder seulement les clients avec plus d'une commande
HAVING COUNT(cmd.num_commande) > 1
ORDER BY nombre_commandes DESC;

-- ============================================================
-- REQUETE 4 : Note moyenne et nombre d'avis par produit
-- LEFT JOIN : inclut les produits sans avis (note moyenne = NULL).
-- NULLS LAST : les produits sans avis apparaissent en dernier.
-- ============================================================
SELECT
   p.code_produit,
   p.nom AS nom_produit,
   ROUND(AVG(a.note), 2) AS note_moyenne,
   COUNT(a.id_avis) AS nombre_avis
FROM PRODUIT p
-- LEFT JOIN pour garder les produits sans avis
LEFT JOIN AVIS a
   ON a.code_produit = p.code_produit
GROUP BY p.code_produit, p.nom
-- Les produits sans avis (NULL) apparaissent apres les autres
ORDER BY note_moyenne DESC NULLS LAST, nombre_avis DESC;
