-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 4_5_requetes_analytiques.sql
-- Partie  : 04 - Requetes d'interrogation
-- Objectif: Fonctions analytiques (fenetrage) pour des analyses
--           avancees : classements, cumuls, comparaisons
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- REQUETE 1 : Classement des clients par montant total depense
-- RANK() : laisse des trous en cas d'egalite (1, 1, 3, 4...)
-- DENSE_RANK() : pas de trou (1, 1, 2, 3...)
-- OVER (ORDER BY ...) : applique le classement sur tout le jeu de donnees.
-- ============================================================
SELECT
   id_client,
   nom,
   prenom,
   montant_total_depense,
   RANK()       OVER (ORDER BY montant_total_depense DESC) AS rang_rank,
   DENSE_RANK() OVER (ORDER BY montant_total_depense DESC) AS rang_dense_rank
FROM (
   -- Sous-requete : calcul du montant total par client
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

-- ============================================================
-- REQUETE 2 : Chiffre d'affaires mensuel avec cumul glissant 3 mois
-- SUM() OVER (ORDER BY mois ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) :
--   fenetre glissante sur les 3 derniers mois (mois actuel + 2 precedents).
-- Utile pour lisser les variations saisonnieres.
-- ============================================================
WITH ca_mensuel AS (
   -- CA par mois (commandes non annulees)
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
   -- Cumul sur 3 mois glissants : mois actuel + 2 mois precedents
   SUM(chiffre_affaires) OVER (
      ORDER BY mois
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
   ) AS ca_cumule_3_mois
FROM ca_mensuel
ORDER BY mois;

-- ============================================================
-- REQUETE 3 : Part du CA total par categorie
-- SUM() OVER () sans PARTITION BY : calcule le total global.
-- Division du CA de chaque categorie par ce total → pourcentage.
-- ============================================================
SELECT
   c.code_categorie,
   c.nom AS nom_categorie,
   SUM(lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100)) AS chiffre_affaires,
   ROUND(
      -- Numerateur : CA de cette categorie
      SUM(lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100))
      -- Denominateur : CA total de toutes les categories
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

-- ============================================================
-- REQUETE 4 : Ecart de prix de chaque produit par rapport
--             a la moyenne de sa categorie
-- AVG() OVER (PARTITION BY code_categorie) :
--   calcule la moyenne uniquement dans chaque categorie (pas globale).
-- Permet de voir si un produit est positionne au-dessus ou en-dessous
-- du prix moyen de sa categorie.
-- ============================================================
SELECT
   code_produit,
   nom,
   code_categorie,
   prix_vente,
   ROUND(prix_moyen_categorie, 2) AS prix_moyen_categorie,
   -- Ecart positif = produit plus cher que la moyenne de sa categorie
   ROUND(prix_vente - prix_moyen_categorie, 2) AS ecart_prix
FROM (
   SELECT
      p.code_produit,
      p.nom,
      p.code_categorie,
      p.prix_vente,
      -- Moyenne des prix de vente dans la meme categorie
      AVG(p.prix_vente) OVER (
         PARTITION BY p.code_categorie
      ) AS prix_moyen_categorie
   FROM PRODUIT p
)
ORDER BY code_categorie, ecart_prix DESC;
