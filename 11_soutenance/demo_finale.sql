-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : demo_finale.sql
-- Partie  : 11 - Soutenance
-- Objectif: Script de demonstration complet pour la soutenance.
--           Montre toutes les parties du projet en une seule execution.
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- Note    : ROLLBACK final → les modifications de test sont annulees
-- ============================================================
SET SERVEROUTPUT ON;

-- ============================================================
-- DEMO 1 : VERIFICATION DE L'ENVIRONNEMENT
-- Confirme que l'utilisateur, le service et la base sont corrects.
-- ============================================================
SELECT '1 - Verification utilisateur connecte' AS section FROM dual;

SELECT USER AS utilisateur_connecte FROM dual;
SELECT SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service_name FROM dual;

-- ============================================================
-- DEMO 2 : LISTE DES TABLES DU PROJET
-- Montre que toutes les tables du schema TECHSTORE existent.
-- ============================================================
SELECT '2 - Verification des tables du projet' AS section FROM dual;

SELECT table_name
FROM user_tables
WHERE table_name IN (
   'CATEGORIE','FOURNISSEUR','CLIENT','PRODUIT',
   'COMMANDE','LIGNE_COMMANDE','AVIS','STOCK_HISTORIQUE'
)
ORDER BY table_name;

-- ============================================================
-- DEMO 3 : VOLUMES DE DONNEES
-- Doit afficher : 5/5/15/20/30/50/10/15 (conforme au sujet)
-- ============================================================
SELECT '3 - Nombre de lignes par table' AS section FROM dual;

SELECT 'CATEGORIE'       AS table_name, COUNT(*) AS total FROM CATEGORIE      UNION ALL
SELECT 'FOURNISSEUR',                   COUNT(*)          FROM FOURNISSEUR     UNION ALL
SELECT 'CLIENT',                        COUNT(*)          FROM CLIENT          UNION ALL
SELECT 'PRODUIT',                       COUNT(*)          FROM PRODUIT         UNION ALL
SELECT 'COMMANDE',                      COUNT(*)          FROM COMMANDE        UNION ALL
SELECT 'LIGNE_COMMANDE',                COUNT(*)          FROM LIGNE_COMMANDE  UNION ALL
SELECT 'AVIS',                          COUNT(*)          FROM AVIS            UNION ALL
SELECT 'STOCK_HISTORIQUE',              COUNT(*)          FROM STOCK_HISTORIQUE;

-- ============================================================
-- DEMO 4 : PRODUITS AVEC CATEGORIE (jointure)
-- Montre que les FK fonctionnent et que les produits sont
-- correctement associes a leurs categories.
-- ============================================================
SELECT '4 - Produits avec leur categorie' AS section FROM dual;

SELECT
   p.code_produit,
   p.nom AS produit,
   c.nom AS categorie,
   p.prix_vente,
   p.stock
FROM PRODUIT p
JOIN CATEGORIE c ON c.code_categorie = p.code_categorie
ORDER BY p.code_produit
FETCH FIRST 10 ROWS ONLY;   -- Limiter a 10 lignes pour la demo

-- ============================================================
-- DEMO 5 : DETAIL DES COMMANDES (jointure 4 tables)
-- Montre une requete de jointure complexe entre COMMANDE,
-- CLIENT, LIGNE_COMMANDE et PRODUIT.
-- ============================================================
SELECT '5 - Detail des commandes' AS section FROM dual;

SELECT
   cmd.num_commande,
   cl.nom,
   cl.prenom,
   p.nom AS produit,
   lc.quantite,
   lc.prix_unitaire,
   lc.remise
FROM COMMANDE cmd
JOIN CLIENT cl         ON cl.id_client = cmd.id_client
JOIN LIGNE_COMMANDE lc ON lc.num_commande = cmd.num_commande
JOIN PRODUIT p         ON p.code_produit = lc.code_produit
ORDER BY cmd.num_commande, lc.id_ligne
FETCH FIRST 10 ROWS ONLY;

-- ============================================================
-- DEMO 6 : CHIFFRE D'AFFAIRES PAR FOURNISSEUR
-- Montre l'utilisation de SUM() et GROUP BY sur 4 tables.
-- ============================================================
SELECT '6 - Chiffre d affaires par fournisseur' AS section FROM dual;

SELECT
   f.raison_sociale,
   SUM(lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100)) AS chiffre_affaires
FROM FOURNISSEUR f
JOIN PRODUIT p         ON p.id_fournisseur = f.id_fournisseur
JOIN LIGNE_COMMANDE lc ON lc.code_produit = p.code_produit
JOIN COMMANDE cmd      ON cmd.num_commande = lc.num_commande
WHERE cmd.statut <> 'ANNULEE'
GROUP BY f.raison_sociale
ORDER BY chiffre_affaires DESC;

-- ============================================================
-- DEMO 7 : CLASSEMENT DES CLIENTS (fonctions analytiques)
-- RANK() et DENSE_RANK() classent les clients par montant depense.
-- Montre l'utilisation des fonctions analytiques OVER().
-- ============================================================
SELECT '7 - Classement des clients par montant depense' AS section FROM dual;

SELECT
   id_client, nom, prenom,
   montant_total_depense,
   RANK()       OVER (ORDER BY montant_total_depense DESC) AS rang_rank,
   DENSE_RANK() OVER (ORDER BY montant_total_depense DESC) AS rang_dense_rank
FROM (
   SELECT c.id_client, c.nom, c.prenom, SUM(cmd.montant_total) AS montant_total_depense
   FROM CLIENT c
   JOIN COMMANDE cmd ON cmd.id_client = c.id_client
   WHERE cmd.statut <> 'ANNULEE'
   GROUP BY c.id_client, c.nom, c.prenom
)
ORDER BY montant_total_depense DESC
FETCH FIRST 10 ROWS ONLY;

-- ============================================================
-- DEMO 8 : TEST PROCEDURE calculer_total_commande
-- Appelle la procedure et verifie que le montant est correct.
-- ============================================================
SELECT '8 - Test procedure calculer_total_commande' AS section FROM dual;

-- Afficher le montant actuel de la commande 50000
SELECT num_commande, montant_total FROM COMMANDE WHERE num_commande = 50000;

-- Appeler la procedure (affiche le resultat via DBMS_OUTPUT)
BEGIN
   calculer_total_commande(50000);
END;
/

-- Verifier que le montant est toujours correct apres recalcul
SELECT num_commande, montant_total FROM COMMANDE WHERE num_commande = 50000;

-- ============================================================
-- DEMO 9 : TEST PROCEDURE appliquer_fidelite
-- Ajoute des points de fidelite et verifie le plafond a 10 000.
-- ============================================================
SELECT '9 - Test procedure appliquer_fidelite' AS section FROM dual;

SELECT id_client, nom, prenom, points_fidelite FROM CLIENT WHERE id_client = 1000;

BEGIN
   appliquer_fidelite(1000, 950);  -- 950 EUR → 95 points
END;
/

SELECT id_client, nom, prenom, points_fidelite FROM CLIENT WHERE id_client = 1000;

-- ============================================================
-- DEMO 10 : TEST TRIGGER TRG_STOCK (stock insuffisant)
-- Inserer une quantite impossible → doit lever ORA-20001.
-- Le bloc EXCEPTION capture et affiche le message d'erreur.
-- ============================================================
SELECT '10 - Test trigger stock insuffisant' AS section FROM dual;

BEGIN
   INSERT INTO LIGNE_COMMANDE (id_ligne, num_commande, code_produit, quantite, prix_unitaire, remise)
   VALUES (9901, 50026, 'P014', 10000, 12, 0);
EXCEPTION
   WHEN OTHERS THEN
      -- ORA-20001 : message confirme que le trigger a bloque l'insertion
      DBMS_OUTPUT.PUT_LINE('Test stock insuffisant OK : ' || SQLERRM);
END;
/

-- ============================================================
-- DEMO 11 : TEST TRIGGER TRG_AUDIT_PRIX_PRODUIT
-- Modifier le prix d'un produit et verifier la trace d'audit.
-- ============================================================
SELECT '11 - Test audit modification prix' AS section FROM dual;

-- Modifier le prix de P001 (declenche TRG_AUDIT_PRIX_PRODUIT)
UPDATE PRODUIT SET prix_vente = prix_vente + 1 WHERE code_produit = 'P001';

-- Verifier que l'audit a capture la modification
SELECT id_audit, code_produit, ancien_prix_vente, nouveau_prix_vente, utilisateur, date_modification
FROM AUDIT_PRIX_PRODUIT
ORDER BY id_audit DESC
FETCH FIRST 5 ROWS ONLY;

-- ============================================================
-- DEMO 12 : VUES PRINCIPALES
-- Montrer les 3 vues principales du projet.
-- ============================================================
SELECT '12 - Vues principales' AS section FROM dual;

-- Vue 1 : produits dont le stock est inferieur au seuil d'alerte
SELECT * FROM vue_produits_stock_faible FETCH FIRST 5 ROWS ONLY;

-- Vue 2 : meilleurs clients (montant > 1000 EUR)
SELECT * FROM vue_top_clients FETCH FIRST 5 ROWS ONLY;

-- Vue 3 : chiffre d'affaires mensuel (stat mensuelle)
SELECT * FROM vue_stats_ventes_mensuelles ORDER BY mois;

-- ============================================================
-- ROLLBACK FINAL : annuler toutes les modifications de test
-- Cela inclut : UPDATE prix P001, appliquer_fidelite, UPDATE montant.
-- Les donnees de reference restent intactes apres la demo.
-- ============================================================
ROLLBACK;
