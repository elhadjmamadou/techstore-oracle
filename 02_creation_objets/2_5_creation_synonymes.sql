-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 2_5_creation_synonymes.sql
-- Partie  : 02 - Creation des objets
-- Objectif: Creer des alias (synonymes) pour simplifier l'acces
--           aux tables et vues du schema TECHSTORE
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- SYNONYME PRIVE : produits → TECHSTORE.PRODUIT
-- Permet d'ecrire SELECT * FROM produits
-- au lieu de SELECT * FROM TECHSTORE.PRODUIT
-- Visible uniquement par l'utilisateur TECHSTORE.
-- ============================================================
CREATE SYNONYM produits
FOR PRODUIT;

-- ============================================================
-- SYNONYME PUBLIC : commandes_recentes → TECHSTORE.vue_commandes_recentes
-- Accessible par TOUS les utilisateurs de la base (pas seulement TECHSTORE).
-- Utile pour les utilisateurs u_ventes, u_stock, etc. qui ont besoin
-- de consulter les commandes recentes sans connaitre le schema proprietaire.
-- Necessite le privilege CREATE PUBLIC SYNONYM.
-- ============================================================
CREATE PUBLIC SYNONYM commandes_recentes
FOR TECHSTORE.vue_commandes_recentes;
