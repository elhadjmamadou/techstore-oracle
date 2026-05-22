-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : verification_insertions.sql
-- Objectif: Vérifier que toutes les données ont été insérées
-- ============================================================

-- Comptage par table
SELECT 'CATEGORIE'       AS table_name, COUNT(*) AS total FROM CATEGORIE      UNION ALL
SELECT 'FOURNISSEUR',                   COUNT(*)          FROM FOURNISSEUR     UNION ALL
SELECT 'CLIENT',                        COUNT(*)          FROM CLIENT          UNION ALL
SELECT 'PRODUIT',                       COUNT(*)          FROM PRODUIT         UNION ALL
SELECT 'COMMANDE',                      COUNT(*)          FROM COMMANDE        UNION ALL
SELECT 'LIGNE_COMMANDE',                COUNT(*)          FROM LIGNE_COMMANDE  UNION ALL
SELECT 'AVIS',                          COUNT(*)          FROM AVIS            UNION ALL
SELECT 'STOCK_HISTORIQUE',              COUNT(*)          FROM STOCK_HISTORIQUE;

-- Vérification hiérarchie catégories
SELECT code_categorie, nom, code_categorie_parent
FROM CATEGORIE
ORDER BY code_categorie_parent NULLS FIRST;

-- Vérification email unique clients
SELECT email, COUNT(*) AS nb
FROM CLIENT
GROUP BY email
HAVING COUNT(*) > 1;

-- Vérification prix_vente > prix_achat
SELECT code_produit, nom, prix_achat, prix_vente
FROM PRODUIT
WHERE prix_vente <= prix_achat;

-- Vérification stock >= 0
SELECT code_produit, nom, stock
FROM PRODUIT
WHERE stock < 0;

-- Vérification commandes annulées sans date de livraison
SELECT num_commande, statut, date_livraison_prevue, date_livraison_reelle
FROM COMMANDE
WHERE statut = 'ANNULEE'
AND (date_livraison_prevue IS NOT NULL OR date_livraison_reelle IS NOT NULL);

-- Vérification notes avis entre 1 et 5
SELECT id_avis, note
FROM AVIS
WHERE note NOT BETWEEN 1 AND 5;

-- Vérification FK lignes de commande
SELECT lc.id_ligne, lc.num_commande, lc.code_produit
FROM LIGNE_COMMANDE lc
WHERE NOT EXISTS (SELECT 1 FROM COMMANDE c WHERE c.num_commande = lc.num_commande)
   OR NOT EXISTS (SELECT 1 FROM PRODUIT p WHERE p.code_produit = lc.code_produit);

-- Vérification séquences
SELECT sequence_name, last_number
FROM user_sequences
WHERE sequence_name IN ('SEQ_CLIENT', 'SEQ_COMMANDE', 'SEQ_AVIS');

-- Résumé des commandes par statut
SELECT statut, COUNT(*) AS nombre, SUM(montant_total) AS total
FROM COMMANDE
GROUP BY statut
ORDER BY statut;
