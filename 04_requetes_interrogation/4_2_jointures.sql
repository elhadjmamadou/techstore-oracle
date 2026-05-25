-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 4_2_jointures.sql
-- Partie  : 04 - Requetes d'interrogation
-- Objectif: Requetes avec jointures entre plusieurs tables
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- REQUETE 1 : Detail complet des commandes
-- Jointure de 4 tables : COMMANDE, CLIENT, LIGNE_COMMANDE, PRODUIT.
-- Calcule le total de chaque ligne : quantite * prix * (1 - remise/100)
-- Permet d'afficher la facture complete de chaque commande.
-- ============================================================
SELECT
   cmd.num_commande,
   cmd.date_commande,
   c.id_client,
   c.nom        AS nom_client,
   c.prenom     AS prenom_client,
   p.code_produit,
   p.nom        AS nom_produit,
   lc.quantite,
   lc.prix_unitaire,
   lc.remise,
   -- Formule du total ligne : prix * quantite * (1 - remise/100)
   lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100) AS total_ligne
FROM COMMANDE cmd
JOIN CLIENT c
   ON c.id_client = cmd.id_client
JOIN LIGNE_COMMANDE lc
   ON lc.num_commande = cmd.num_commande
JOIN PRODUIT p
   ON p.code_produit = lc.code_produit
ORDER BY cmd.num_commande, lc.id_ligne;

-- ============================================================
-- REQUETE 2 : Chemin hierarchique des categories (CONNECT BY)
-- SYS_CONNECT_BY_PATH construit le chemin complet depuis la racine.
-- Exemple : "Electronique > Smartphones"
-- START WITH : demarre depuis les categories sans parent (racines)
-- CONNECT BY PRIOR : relie parent → enfant
-- ============================================================
WITH categorie_chemin AS (
   SELECT
      code_categorie,
      -- Chemin complet : "Electronique > Ordinateurs"
      LTRIM(SYS_CONNECT_BY_PATH(nom, ' > '), ' > ') AS chemin_categorie
   FROM CATEGORIE
   START WITH code_categorie_parent IS NULL   -- Partir des racines
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

-- ============================================================
-- REQUETE 3 : Clients qui n'ont jamais passe de commande
-- LEFT JOIN : garde les clients meme s'ils n'ont aucune commande.
-- WHERE cmd.num_commande IS NULL : filtre ceux sans commande.
-- ============================================================
SELECT
   c.id_client,
   c.nom,
   c.prenom,
   c.email,
   c.ville
FROM CLIENT c
LEFT JOIN COMMANDE cmd
   ON cmd.id_client = c.id_client
-- Un client sans commande n'a pas de num_commande associe
WHERE cmd.num_commande IS NULL
ORDER BY c.nom, c.prenom;

-- ============================================================
-- REQUETE 4 : Chiffre d'affaires par fournisseur
-- Jointure de 4 tables : FOURNISSEUR → PRODUIT → LIGNE_COMMANDE → COMMANDE
-- On exclut les commandes annulees du chiffre d'affaires.
-- ============================================================
SELECT
   f.id_fournisseur,
   f.raison_sociale,
   -- CA = somme des totaux de chaque ligne (avec remise)
   SUM(lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100)) AS chiffre_affaires
FROM FOURNISSEUR f
JOIN PRODUIT p
   ON p.id_fournisseur = f.id_fournisseur
JOIN LIGNE_COMMANDE lc
   ON lc.code_produit = p.code_produit
JOIN COMMANDE cmd
   ON cmd.num_commande = lc.num_commande
-- Exclure les ventes des commandes annulees
WHERE cmd.statut <> 'ANNULEE'
GROUP BY f.id_fournisseur, f.raison_sociale
ORDER BY chiffre_affaires DESC;
