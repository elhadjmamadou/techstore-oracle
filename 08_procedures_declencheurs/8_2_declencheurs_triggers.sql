CREATE OR REPLACE TRIGGER trg_stock
BEFORE INSERT ON LIGNE_COMMANDE
FOR EACH ROW
DECLARE
   v_stock PRODUIT.stock%TYPE;
BEGIN
   SELECT stock
   INTO v_stock
   FROM PRODUIT
   WHERE code_produit = :NEW.code_produit;

   IF v_stock < :NEW.quantite THEN
      RAISE_APPLICATION_ERROR(-20001, 'Stock insuffisant pour ce produit.');
   END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_historique
AFTER INSERT ON LIGNE_COMMANDE
FOR EACH ROW
DECLARE
   v_stock_apres NUMBER(10);
BEGIN
   UPDATE PRODUIT
   SET stock = stock - :NEW.quantite
   WHERE code_produit = :NEW.code_produit;

   SELECT stock
   INTO v_stock_apres
   FROM PRODUIT
   WHERE code_produit = :NEW.code_produit;

   INSERT INTO STOCK_HISTORIQUE (
      id_historique,
      code_produit,
      date_mouvement,
      type_mouvement,
      quantite,
      stock_apres_mouvement
   )
   SELECT
      NVL(MAX(id_historique), 0) + 1,
      :NEW.code_produit,
      SYSDATE,
      'SORTIE',
      :NEW.quantite,
      v_stock_apres
   FROM STOCK_HISTORIQUE;
END;
/

CREATE OR REPLACE TRIGGER trg_avis
BEFORE INSERT ON AVIS
FOR EACH ROW
DECLARE
   v_nombre NUMBER;
BEGIN
   SELECT COUNT(*)
   INTO v_nombre
   FROM COMMANDE c
   JOIN LIGNE_COMMANDE lc
      ON lc.num_commande = c.num_commande
   WHERE c.id_client = :NEW.id_client
      AND lc.code_produit = :NEW.code_produit
      AND c.statut <> 'ANNULEE';

   IF v_nombre = 0 THEN
      RAISE_APPLICATION_ERROR(-20002, 'Avis refuse : le client n a pas achete ce produit.');
   END IF;
END;
/