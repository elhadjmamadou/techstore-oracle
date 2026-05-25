-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : tests_procedures.sql
-- Partie  : 08 - Procedures et declencheurs
-- Objectif: Tester les 3 procedures stockees du projet
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- ============================================================
SET SERVEROUTPUT ON;

-- ============================================================
-- TEST 1 : calculer_total_commande
-- Verifier que la procedure recalcule correctement le montant
-- de la commande 50000 a partir de ses lignes.
-- Resultat attendu : 1197.00 EUR (950 + 260 * 0.95)
-- ============================================================

-- Afficher le montant AVANT
SELECT num_commande, montant_total
FROM COMMANDE
WHERE num_commande = 50000;

-- Appeler la procedure
BEGIN
   calculer_total_commande(50000);
END;
/

-- Afficher le montant APRES (doit rester 1197.00 si coherent)
SELECT num_commande, montant_total
FROM COMMANDE
WHERE num_commande = 50000;

-- ============================================================
-- TEST 2 : appliquer_fidelite
-- Verifier que les points sont correctement ajoutes.
-- Avec 950 EUR : 950 / 10 = 95 points
-- Client 1000 a 120 points → apres : 120 + 95 = 215 points
-- ============================================================

-- Afficher les points AVANT
SELECT id_client, nom, prenom, points_fidelite
FROM CLIENT
WHERE id_client = 1000;

-- Appeler la procedure avec 950 EUR
BEGIN
   appliquer_fidelite(1000, 950);
END;
/

-- Afficher les points APRES (doit etre 215 si 120 avant)
SELECT id_client, nom, prenom, points_fidelite
FROM CLIENT
WHERE id_client = 1000;

-- ============================================================
-- TEST 3 : reapprovisionner_stock
-- Lister les produits dont le stock est <= seuil_alerte.
-- Aucun parametre : le seuil est propre a chaque produit.
-- Resultat : liste des produits avec la quantite manquante.
-- ============================================================
BEGIN
   reapprovisionner_stock;
END;
/
