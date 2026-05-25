-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : tests_triggers.sql
-- Partie  : 08 - Procedures et declencheurs
-- Objectif: Tester les 3 triggers metier (cas normaux et erreurs)
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- Note    : ROLLBACK final pour ne pas modifier les donnees de test
-- ============================================================
SET SERVEROUTPUT ON;

-- ============================================================
-- TEST 1 : TRG_STOCK + TRG_HISTORIQUE (cas normal)
-- Inserer une ligne dans LIGNE_COMMANDE pour la commande 50026.
-- TRG_STOCK verifie : statut != ANNULEE + stock suffisant.
-- TRG_HISTORIQUE decremente le stock et insere dans STOCK_HISTORIQUE.
-- Produit P014 (Cable HDMI) : stock actuel = 115, demande = 1 → OK
-- ============================================================

-- Verifier le stock de P014 AVANT insertion
SELECT code_produit, nom, stock
FROM PRODUIT
WHERE code_produit = 'P014';

-- Inserer une ligne de commande (declenche TRG_STOCK puis TRG_HISTORIQUE)
INSERT INTO LIGNE_COMMANDE (
   id_ligne, num_commande, code_produit, quantite, prix_unitaire, remise
)
VALUES (9001, 50026, 'P014', 1, 12, 0);

-- Verifier le stock de P014 APRES insertion (doit avoir diminue de 1)
SELECT code_produit, nom, stock
FROM PRODUIT
WHERE code_produit = 'P014';

-- Verifier l'entree creee dans STOCK_HISTORIQUE par TRG_HISTORIQUE
SELECT id_historique, code_produit, type_mouvement, quantite, stock_apres_mouvement
FROM STOCK_HISTORIQUE
WHERE code_produit = 'P014'
ORDER BY id_historique DESC;

-- ============================================================
-- TEST 2 : TRG_AVIS (cas normal)
-- Le client 1011 a achete P018 dans la commande 50011.
-- L'avis doit etre accepte par TRG_AVIS.
-- ============================================================

-- Inserer un avis valide (client 1011 a achete P018)
INSERT INTO AVIS (id_avis, id_client, code_produit, note, commentaire, date_avis)
VALUES (seq_avis.NEXTVAL, 1011, 'P018', 5, 'Produit achete et avis valide.', SYSDATE);

-- Verifier que l'avis a bien ete insere
SELECT id_avis, id_client, code_produit, note, commentaire
FROM AVIS
WHERE id_client = 1011 AND code_produit = 'P018';

-- ============================================================
-- TEST 3 : TRG_STOCK (cas d'erreur — stock insuffisant)
-- Tenter d'inserer une ligne avec une quantite de 10 000.
-- Le stock de P014 est de 115 → doit declencher ORA-20001.
-- Le bloc EXCEPTION capture l'erreur et affiche le message.
-- ============================================================
BEGIN
   INSERT INTO LIGNE_COMMANDE (
      id_ligne, num_commande, code_produit, quantite, prix_unitaire, remise
   )
   VALUES (9002, 50026, 'P014', 10000, 12, 0);
EXCEPTION
   WHEN OTHERS THEN
      -- ORA-20001 attendu : Stock insuffisant pour P014
      DBMS_OUTPUT.PUT_LINE('Test stock insuffisant OK : ' || SQLERRM);
END;
/

-- ============================================================
-- TEST 4 : TRG_AVIS (cas d'erreur — achat non verifie)
-- Le client 1011 n'a PAS achete P001 (iPhone 15).
-- L'avis doit etre refuse avec ORA-20002.
-- ============================================================
BEGIN
   INSERT INTO AVIS (id_avis, id_client, code_produit, note, commentaire, date_avis)
   VALUES (seq_avis.NEXTVAL, 1011, 'P001', 4, 'Avis non autorise.', SYSDATE);
EXCEPTION
   WHEN OTHERS THEN
      -- ORA-20002 attendu : client n'a pas achete le produit
      DBMS_OUTPUT.PUT_LINE('Test avis refuse OK : ' || SQLERRM);
END;
/

-- Annuler toutes les modifications de ce test
-- (ne pas contaminer les donnees de reference)
ROLLBACK;
