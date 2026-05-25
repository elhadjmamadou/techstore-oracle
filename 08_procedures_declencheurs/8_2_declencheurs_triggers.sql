-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 8_2_declencheurs_triggers.sql
-- Partie  : 08 - Procedures et declencheurs
-- Objectif: Creer les 3 triggers metier du projet :
--   1. TRG_STOCK      : verifie le stock avant insertion
--   2. TRG_HISTORIQUE : met a jour le stock apres insertion
--   3. TRG_AVIS       : verifie l'achat avant un avis
-- Executer: Avec TECHSTORE, APRES les insertions de donnees (partie 03)
-- ============================================================

-- ============================================================
-- TRIGGER 1 : TRG_STOCK
-- Se declenche AVANT chaque INSERT dans LIGNE_COMMANDE.
-- Effectue deux verifications :
--   1. La commande n'est pas ANNULEE (on ne vend pas sur une annulation)
--   2. Le stock du produit est suffisant pour la quantite demandee
-- En cas d'echec, une erreur applicative bloque l'insertion.
-- ============================================================
CREATE OR REPLACE TRIGGER trg_stock
BEFORE INSERT ON LIGNE_COMMANDE   -- Avant toute nouvelle ligne de commande
FOR EACH ROW                       -- Declenche pour chaque ligne inseree
DECLARE
   v_stock      PRODUIT.stock%TYPE;        -- Type de la colonne stock
   v_statut_cmd COMMANDE.statut%TYPE;      -- Type de la colonne statut
BEGIN
   -- VERIFICATION 1 : la commande ne doit pas etre annulee
   SELECT statut
   INTO v_statut_cmd
   FROM COMMANDE
   WHERE num_commande = :NEW.num_commande;  -- :NEW = nouvelle ligne en cours d'insertion

   IF v_statut_cmd = 'ANNULEE' THEN
      -- Erreur personnalisee -20003 : bloquer l'insertion
      RAISE_APPLICATION_ERROR(-20003,
         'Insertion interdite : la commande ' || :NEW.num_commande || ' est ANNULEE.');
   END IF;

   -- VERIFICATION 2 : le stock doit couvrir la quantite demandee
   SELECT stock
   INTO v_stock
   FROM PRODUIT
   WHERE code_produit = :NEW.code_produit;

   IF v_stock < :NEW.quantite THEN
      -- Erreur -20001 : message explicatif avec les valeurs disponible/demandee
      RAISE_APPLICATION_ERROR(-20001,
         'Stock insuffisant pour le produit ' || :NEW.code_produit ||
         '. Disponible : ' || v_stock || ', demande : ' || :NEW.quantite);
   END IF;
END;
/

-- ============================================================
-- TRIGGER 2 : TRG_HISTORIQUE
-- Se declenche APRES chaque INSERT dans LIGNE_COMMANDE.
-- Effectue deux actions automatiquement :
--   1. Decremente le stock du produit (stock = stock - quantite)
--   2. Insere un mouvement SORTIE dans STOCK_HISTORIQUE
-- Utilise seq_stock_historique.NEXTVAL pour garantir l'unicite
-- des IDs meme en cas d'insertions simultanees (thread-safe).
-- ============================================================
CREATE OR REPLACE TRIGGER trg_historique
AFTER INSERT ON LIGNE_COMMANDE    -- Apres confirmation de l'insertion
FOR EACH ROW
DECLARE
   v_stock_apres NUMBER(10);  -- Stock restant apres la vente
BEGIN
   -- ACTION 1 : Decrémenter le stock du produit vendu
   UPDATE PRODUIT
   SET stock = stock - :NEW.quantite
   WHERE code_produit = :NEW.code_produit;

   -- Lire le nouveau stock pour l'enregistrer dans l'historique
   SELECT stock
   INTO v_stock_apres
   FROM PRODUIT
   WHERE code_produit = :NEW.code_produit;

   -- ACTION 2 : Tracer le mouvement de sortie dans STOCK_HISTORIQUE
   -- seq_stock_historique.NEXTVAL genere un ID unique et concurrent-safe
   INSERT INTO STOCK_HISTORIQUE (
      id_historique,
      code_produit,
      date_mouvement,
      type_mouvement,
      quantite,
      stock_apres_mouvement
   ) VALUES (
      seq_stock_historique.NEXTVAL,   -- ID genere par la sequence
      :NEW.code_produit,
      SYSDATE,
      'SORTIE',                       -- Toujours SORTIE ici (vente)
      :NEW.quantite,
      v_stock_apres                   -- Stock apres cette vente
   );
END;
/

-- ============================================================
-- TRIGGER 3 : TRG_AVIS
-- Se declenche AVANT chaque INSERT dans AVIS.
-- Verifie que le client a bien achete le produit dans une commande
-- non annulee avant d'autoriser son avis.
-- Interdit les faux avis ou les avis sur des produits non achetes.
-- ============================================================
CREATE OR REPLACE TRIGGER trg_avis
BEFORE INSERT ON AVIS
FOR EACH ROW
DECLARE
   v_nombre NUMBER;  -- Nombre de commandes valides contenant ce produit
BEGIN
   -- Compter les commandes non annulees de ce client contenant ce produit
   SELECT COUNT(*)
   INTO v_nombre
   FROM COMMANDE c
   JOIN LIGNE_COMMANDE lc
      ON lc.num_commande = c.num_commande
   WHERE c.id_client    = :NEW.id_client      -- Meme client
     AND lc.code_produit = :NEW.code_produit  -- Meme produit
     AND c.statut       <> 'ANNULEE';         -- Commande valide

   IF v_nombre = 0 THEN
      -- Erreur -20002 : le client n'a pas achete ce produit
      RAISE_APPLICATION_ERROR(-20002,
         'Avis refuse : le client ' || :NEW.id_client ||
         ' n a pas achete le produit ' || :NEW.code_produit || '.');
   END IF;
END;
/
