SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE calculer_total_commande (
   p_num_commande IN NUMBER
)
AS
   v_total NUMBER(12,2);
BEGIN
   SELECT NVL(SUM(quantite * prix_unitaire * (1 - remise / 100)), 0)
   INTO v_total
   FROM LIGNE_COMMANDE
   WHERE num_commande = p_num_commande;

   UPDATE COMMANDE
   SET montant_total = v_total
   WHERE num_commande = p_num_commande;

   DBMS_OUTPUT.PUT_LINE('Total de la commande ' || p_num_commande || ' mis a jour : ' || v_total);
END;
/

CREATE OR REPLACE PROCEDURE appliquer_fidelite (
   p_id_client IN NUMBER,
   p_montant   IN NUMBER
)
AS
   v_points NUMBER(5);
BEGIN
   IF p_montant < 0 THEN
      RAISE_APPLICATION_ERROR(-20010, 'Le montant ne peut pas etre negatif.');
   END IF;

   v_points := FLOOR(p_montant / 10);

   UPDATE CLIENT
   SET points_fidelite = LEAST(10000, points_fidelite + v_points)
   WHERE id_client = p_id_client;

   DBMS_OUTPUT.PUT_LINE(v_points || ' point(s) ajoute(s) au client ' || p_id_client);
END;
/

CREATE OR REPLACE PROCEDURE reapprovisionner_stock (
   p_seuil IN NUMBER
)
AS
   v_resultat SYS_REFCURSOR;
BEGIN
   OPEN v_resultat FOR
      SELECT
         code_produit,
         nom,
         stock,
         seuil_alerte,
         statut
      FROM PRODUIT
      WHERE stock <= p_seuil
         OR stock <= seuil_alerte
      ORDER BY stock ASC;

   DBMS_SQL.RETURN_RESULT(v_resultat);
END;
/