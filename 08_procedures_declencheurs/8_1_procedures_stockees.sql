-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 8_1_procedures_stockees.sql
-- Partie  : 08 - Procedures et declencheurs
-- Objectif: Creer les 3 procedures stockees du projet :
--   1. calculer_total_commande : recalcule le montant_total
--   2. appliquer_fidelite      : gere les points de fidelite
--   3. reapprovisionner_stock  : liste les produits a reapprovisionner
-- Executer: Avec TECHSTORE, APRES la creation des tables (partie 02)
-- ============================================================
SET SERVEROUTPUT ON;

-- ============================================================
-- PROCEDURE 1 : CALCULER_TOTAL_COMMANDE
-- Recalcule le montant_total d'une commande en additionnant
-- toutes ses lignes avec remise : SUM(qte * prix * (1 - remise/100))
-- Utile si une ligne est modifiee apres la creation de la commande.
-- Parametre : p_num_commande → numero de la commande a recalculer
-- ============================================================
CREATE OR REPLACE PROCEDURE calculer_total_commande (
   p_num_commande IN NUMBER
)
AS
   v_total NUMBER(12,2);  -- Variable locale pour stocker le resultat
BEGIN
   -- Calcul du total avec remise pour chaque ligne de la commande
   -- NVL(..., 0) : retourne 0 si la commande n'a aucune ligne
   SELECT NVL(SUM(quantite * prix_unitaire * (1 - remise / 100)), 0)
   INTO v_total
   FROM LIGNE_COMMANDE
   WHERE num_commande = p_num_commande;

   -- Mise a jour du champ montant_total dans la table COMMANDE
   UPDATE COMMANDE
   SET montant_total = v_total
   WHERE num_commande = p_num_commande;

   -- Confirmation dans la console (SQL*Plus / DataGrip)
   DBMS_OUTPUT.PUT_LINE('Total de la commande ' || p_num_commande ||
                        ' mis a jour : ' || v_total || ' EUR');
END;
/

-- ============================================================
-- PROCEDURE 2 : APPLIQUER_FIDELITE
-- Ajoute des points de fidelite au compte d'un client.
-- Regle : 1 point par tranche de 10 EUR depenses.
-- Plafond : 10 000 points maximum (contrainte ck_client_points).
-- Securite : rejette les montants negatifs.
-- Parametres : p_id_client, p_montant (montant de la commande)
-- ============================================================
CREATE OR REPLACE PROCEDURE appliquer_fidelite (
   p_id_client IN NUMBER,
   p_montant   IN NUMBER
)
AS
   -- NUMBER sans precision pour eviter ORA-06502 sur grands montants
   -- (ex : montant de 1 000 000 → FLOOR/10 = 100 000 → depasse NUMBER(5))
   v_points NUMBER;
BEGIN
   -- Validation : un montant negatif n'a pas de sens pour des points
   IF p_montant < 0 THEN
      RAISE_APPLICATION_ERROR(-20010, 'Le montant ne peut pas etre negatif.');
   END IF;

   -- Calcul des points : 1 point / 10 EUR, plafonné a 10 000
   -- FLOOR : arrondi a l'entier inferieur (pas de demi-points)
   -- LEAST  : si le calcul depasse 10 000, on prend 10 000
   v_points := LEAST(10000, FLOOR(p_montant / 10));

   -- Ajout des points au total existant, avec plafond global a 10 000
   UPDATE CLIENT
   SET points_fidelite = LEAST(10000, points_fidelite + v_points)
   WHERE id_client = p_id_client;

   DBMS_OUTPUT.PUT_LINE(v_points || ' point(s) ajoute(s) au client ' || p_id_client);
END;
/

-- ============================================================
-- PROCEDURE 3 : REAPPROVISIONNER_STOCK
-- Retourne la liste des produits dont le stock est inferieur
-- ou egal a leur seuil d'alerte propre (stock <= seuil_alerte).
-- Utilise un curseur reference (SYS_REFCURSOR) + DBMS_SQL.RETURN_RESULT
-- pour retourner un jeu de resultats affichable dans DataGrip.
-- Aucun parametre : le seuil est propre a chaque produit.
-- ============================================================
CREATE OR REPLACE PROCEDURE reapprovisionner_stock
AS
   v_resultat SYS_REFCURSOR;  -- Curseur reference pour retourner plusieurs lignes
BEGIN
   -- Ouvrir le curseur sur les produits en alerte de stock
   OPEN v_resultat FOR
      SELECT
         code_produit,
         nom,
         stock,
         seuil_alerte,
         -- Quantite manquante pour atteindre le seuil
         seuil_alerte - stock AS manque,
         statut
      FROM PRODUIT
      -- Condition : stock actuel inferieur ou egal au seuil d'alerte
      WHERE stock <= seuil_alerte
      -- Trier par urgence : plus le manque est grand, plus c'est urgent
      ORDER BY (seuil_alerte - stock) DESC, stock ASC;

   -- Retourner le resultat au client (DataGrip, SQL*Plus, application)
   DBMS_SQL.RETURN_RESULT(v_resultat);
END;
/
