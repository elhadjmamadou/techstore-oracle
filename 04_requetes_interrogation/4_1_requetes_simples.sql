-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 4_1_requetes_simples.sql
-- Partie  : 04 - Requetes d'interrogation
-- Objectif: Requetes de base : filtres, tris, conditions simples
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- REQUETE 1 : Liste des clients regroupes par ville
-- Permet de voir la repartition geographique de la clientele.
-- Tri par ville puis par nom dans chaque ville.
-- ============================================================
SELECT ville, nom, prenom, email, telephone
FROM CLIENT
ORDER BY ville ASC, nom ASC, prenom ASC;

-- ============================================================
-- REQUETE 2 : Produits en rupture de stock (stock = 0)
-- Identifie les produits completement epuises.
-- Dans notre jeu de donnees, aucun produit n'est a 0 :
-- le trigger TRG_STOCK bloque les ventes si stock insuffisant.
-- ============================================================
SELECT code_produit, nom, stock, seuil_alerte, statut
FROM PRODUIT
WHERE stock = 0
ORDER BY nom;

-- ============================================================
-- REQUETE 3 : Commandes passees dans le dernier mois
-- ADD_MONTHS(SYSDATE, -1) calcule la date il y a 1 mois.
-- Utile pour le tableau de bord des ventes recentes.
-- ============================================================
SELECT num_commande, id_client, date_commande, montant_total, statut
FROM COMMANDE
WHERE date_commande >= ADD_MONTHS(SYSDATE, -1)
ORDER BY date_commande DESC;

-- ============================================================
-- REQUETE 4 : Avis avec note maximale (5 etoiles)
-- Permet d'identifier les produits les mieux notes par les clients.
-- Utile pour la mise en avant des produits populaires.
-- ============================================================
SELECT id_avis, id_client, code_produit, note, commentaire, date_avis
FROM AVIS
WHERE note = 5
ORDER BY date_avis DESC;
