-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 2_4_creation_vues.sql
-- Partie  : 02 - Creation des objets
-- Objectif: Creer les vues qui simplifient l'acces aux donnees
--           et encapsulent des requetes complexes
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- VUE 1 : VUE_PRODUITS_STOCK_FAIBLE
-- Liste les produits dont le stock est inferieur au seuil d'alerte.
-- Utilisee pour identifier les produits a reapprovisionner.
-- La procedure reapprovisionner_stock utilise une logique similaire.
-- ============================================================
CREATE OR REPLACE VIEW vue_produits_stock_faible AS
SELECT
   code_produit,
   nom,
   stock,
   seuil_alerte,
   statut
FROM PRODUIT
-- Condition : stock strictement inferieur au seuil (alerte critique)
WHERE stock < seuil_alerte;

-- ============================================================
-- VUE 2 : VUE_TOP_CLIENTS
-- Classe les clients par montant total depense (commandes non annulees).
-- Seuls les clients ayant depense plus de 1000 EUR apparaissent.
-- Utile pour les campagnes de fidelisation et les analyses marketing.
-- ============================================================
CREATE OR REPLACE VIEW vue_top_clients AS
SELECT
   c.id_client,
   c.nom,
   c.prenom,
   c.email,
   -- Somme du montant total de toutes les commandes valides du client
   SUM(cmd.montant_total) AS montant_total_depense
FROM CLIENT c
JOIN COMMANDE cmd
   ON c.id_client = cmd.id_client
-- Exclure les commandes annulees du calcul du CA
WHERE cmd.statut <> 'ANNULEE'
GROUP BY
   c.id_client,
   c.nom,
   c.prenom,
   c.email
-- Seuil : seuls les gros acheteurs (> 1000 EUR) sont affiches
HAVING SUM(cmd.montant_total) > 1000;

-- ============================================================
-- VUE 3 : VUE_STATS_VENTES_MENSUELLES (READ ONLY)
-- Aggrege le chiffre d'affaires mois par mois.
-- WITH READ ONLY : cette vue ne peut pas etre modifiee via DML.
-- Utilisee pour les analyses temporelles et les graphiques.
-- ============================================================
CREATE OR REPLACE VIEW vue_stats_ventes_mensuelles AS
SELECT
   -- TRUNC(..., 'MM') tronque la date au 1er jour du mois
   TRUNC(date_commande, 'MM') AS mois,
   COUNT(*) AS nombre_commandes,
   SUM(montant_total) AS chiffre_affaires
FROM COMMANDE
-- Exclure les commandes annulees du chiffre d'affaires
WHERE statut <> 'ANNULEE'
GROUP BY TRUNC(date_commande, 'MM')
WITH READ ONLY; -- Interdire toute modification via cette vue

-- ============================================================
-- VUE 4 : VUE_COMMANDES_RECENTES (bonus)
-- Affiche les commandes des 30 derniers jours.
-- Utile pour le tableau de bord quotidien ou hebdomadaire.
-- ============================================================
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
-- SYSDATE - 30 : il y a 30 jours (fenetre glissante)
WHERE date_commande >= SYSDATE - 30;
