-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : verification_insertions.sql
-- Partie  : 03 - Insertion des donnees
-- Objectif: Verifier que toutes les donnees ont ete inserees
--           correctement et que les contraintes sont respectees
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================

-- ============================================================
-- VERIFICATION 1 : VOLUMES PAR TABLE
-- Resultats attendus :
--   CATEGORIE=5, FOURNISSEUR=5, CLIENT=15, PRODUIT=20,
--   COMMANDE=30, LIGNE_COMMANDE=50, AVIS=10, STOCK_HISTORIQUE=15
-- ============================================================
SELECT 'CATEGORIE'       AS table_name, COUNT(*) AS total FROM CATEGORIE      UNION ALL
SELECT 'FOURNISSEUR',                   COUNT(*)          FROM FOURNISSEUR     UNION ALL
SELECT 'CLIENT',                        COUNT(*)          FROM CLIENT          UNION ALL
SELECT 'PRODUIT',                       COUNT(*)          FROM PRODUIT         UNION ALL
SELECT 'COMMANDE',                      COUNT(*)          FROM COMMANDE        UNION ALL
SELECT 'LIGNE_COMMANDE',                COUNT(*)          FROM LIGNE_COMMANDE  UNION ALL
SELECT 'AVIS',                          COUNT(*)          FROM AVIS            UNION ALL
SELECT 'STOCK_HISTORIQUE',              COUNT(*)          FROM STOCK_HISTORIQUE;

-- ============================================================
-- VERIFICATION 2 : HIERARCHIE DES CATEGORIES
-- La categorie parente (C_ELEC) doit apparaitre avec NULL dans parent.
-- Les 4 sous-categories pointent vers C_ELEC.
-- ============================================================
SELECT code_categorie, nom, code_categorie_parent
FROM CATEGORIE
ORDER BY code_categorie_parent NULLS FIRST;

-- ============================================================
-- VERIFICATION 3 : EMAILS CLIENTS UNIQUES
-- Resultat attendu : aucune ligne (pas de doublon d'email).
-- Si une ligne apparait, la contrainte UN_CLIENT_EMAIL est violee.
-- ============================================================
SELECT email, COUNT(*) AS nb
FROM CLIENT
GROUP BY email
HAVING COUNT(*) > 1;

-- ============================================================
-- VERIFICATION 4 : PRIX DE VENTE > PRIX D'ACHAT
-- Resultat attendu : aucune ligne (contrainte ck_produit_prix).
-- Si une ligne apparait, la contrainte de prix est violee.
-- ============================================================
SELECT code_produit, nom, prix_achat, prix_vente
FROM PRODUIT
WHERE prix_vente <= prix_achat;

-- ============================================================
-- VERIFICATION 5 : STOCK >= 0
-- Resultat attendu : aucune ligne (contrainte ck_produit_stock).
-- ============================================================
SELECT code_produit, nom, stock
FROM PRODUIT
WHERE stock < 0;

-- ============================================================
-- VERIFICATION 6 : COMMANDES ANNULEES SANS DATE DE LIVRAISON
-- Les commandes ANNULEE doivent avoir les deux dates a NULL.
-- Resultat attendu : aucune ligne (contrainte ck_commande_annulee).
-- ============================================================
SELECT num_commande, statut, date_livraison_prevue, date_livraison_reelle
FROM COMMANDE
WHERE statut = 'ANNULEE'
AND (date_livraison_prevue IS NOT NULL OR date_livraison_reelle IS NOT NULL);

-- ============================================================
-- VERIFICATION 7 : NOTES AVIS ENTRE 1 ET 5
-- Resultat attendu : aucune ligne (contrainte ck_avis_note).
-- ============================================================
SELECT id_avis, note
FROM AVIS
WHERE note NOT BETWEEN 1 AND 5;

-- ============================================================
-- VERIFICATION 8 : INTEGRITE DES CLES ETRANGERES LIGNE_COMMANDE
-- Chaque ligne de commande doit pointer vers une commande et un produit
-- qui existent reellement. Resultat attendu : aucune ligne.
-- ============================================================
SELECT lc.id_ligne, lc.num_commande, lc.code_produit
FROM LIGNE_COMMANDE lc
WHERE NOT EXISTS (SELECT 1 FROM COMMANDE c WHERE c.num_commande = lc.num_commande)
   OR NOT EXISTS (SELECT 1 FROM PRODUIT p WHERE p.code_produit = lc.code_produit);

-- ============================================================
-- VERIFICATION 9 : ETAT DES SEQUENCES
-- Verifier que les sequences ont avance correctement.
-- SEQ_CLIENT : doit etre a 1015 (15 clients : 1000 a 1014)
-- SEQ_COMMANDE : doit etre a 50030 (30 commandes : 50000 a 50029)
-- SEQ_AVIS : doit etre a 11 (10 avis : 1 a 10)
-- ============================================================
SELECT sequence_name, last_number
FROM user_sequences
WHERE sequence_name IN ('SEQ_CLIENT', 'SEQ_COMMANDE', 'SEQ_AVIS')
ORDER BY sequence_name;

-- ============================================================
-- VERIFICATION 10 : RESUME DES COMMANDES PAR STATUT
-- Attendu : LIVREE=18, CONFIRMEE=4, EN_ATTENTE=3, EXPEDIEE=3, ANNULEE=2
-- ============================================================
SELECT statut, COUNT(*) AS nombre, SUM(montant_total) AS total
FROM COMMANDE
GROUP BY statut
ORDER BY statut;
