SET SERVEROUTPUT ON;

SELECT '1 - Verification utilisateur connecte' AS section FROM dual;

SELECT USER AS utilisateur_connecte
FROM dual;

SELECT SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS service_name
FROM dual;

SELECT '2 - Verification des tables du projet' AS section FROM dual;

SELECT table_name
FROM user_tables
WHERE table_name IN (
   'CATEGORIE',
   'FOURNISSEUR',
   'CLIENT',
   'PRODUIT',
   'COMMANDE',
   'LIGNE_COMMANDE',
   'AVIS',
   'STOCK_HISTORIQUE'
)
ORDER BY table_name;

SELECT '3 - Nombre de lignes par table' AS section FROM dual;

SELECT 'CATEGORIE' AS table_name, COUNT(*) AS total FROM CATEGORIE
UNION ALL
SELECT 'FOURNISSEUR', COUNT(*) FROM FOURNISSEUR
UNION ALL
SELECT 'CLIENT', COUNT(*) FROM CLIENT
UNION ALL
SELECT 'PRODUIT', COUNT(*) FROM PRODUIT
UNION ALL
SELECT 'COMMANDE', COUNT(*) FROM COMMANDE
UNION ALL
SELECT 'LIGNE_COMMANDE', COUNT(*) FROM LIGNE_COMMANDE
UNION ALL
SELECT 'AVIS', COUNT(*) FROM AVIS
UNION ALL
SELECT 'STOCK_HISTORIQUE', COUNT(*) FROM STOCK_HISTORIQUE;

SELECT '4 - Produits avec leur categorie' AS section FROM dual;

SELECT
   p.code_produit,
   p.nom AS produit,
   c.nom AS categorie,
   p.prix_vente,
   p.stock
FROM PRODUIT p
JOIN CATEGORIE c
   ON c.code_categorie = p.code_categorie
ORDER BY p.code_produit
FETCH FIRST 10 ROWS ONLY;

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
JOIN CLIENT cl
   ON cl.id_client = cmd.id_client
JOIN LIGNE_COMMANDE lc
   ON lc.num_commande = cmd.num_commande
JOIN PRODUIT p
   ON p.code_produit = lc.code_produit
ORDER BY cmd.num_commande, lc.id_ligne
FETCH FIRST 10 ROWS ONLY;

SELECT '6 - Chiffre d affaires par fournisseur' AS section FROM dual;

SELECT
   f.raison_sociale,
   SUM(lc.quantite * lc.prix_unitaire * (1 - lc.remise / 100)) AS chiffre_affaires
FROM FOURNISSEUR f
JOIN PRODUIT p
   ON p.id_fournisseur = f.id_fournisseur
JOIN LIGNE_COMMANDE lc
   ON lc.code_produit = p.code_produit
JOIN COMMANDE cmd
   ON cmd.num_commande = lc.num_commande
WHERE cmd.statut <> 'ANNULEE'
GROUP BY f.raison_sociale
ORDER BY chiffre_affaires DESC;

SELECT '7 - Classement des clients par montant depense' AS section FROM dual;

SELECT
   id_client,
   nom,
   prenom,
   montant_total_depense,
   RANK() OVER (ORDER BY montant_total_depense DESC) AS rang_rank,
   DENSE_RANK() OVER (ORDER BY montant_total_depense DESC) AS rang_dense_rank
FROM (
   SELECT
      c.id_client,
      c.nom,
      c.prenom,
      SUM(cmd.montant_total) AS montant_total_depense
   FROM CLIENT c
   JOIN COMMANDE cmd
      ON cmd.id_client = c.id_client
   WHERE cmd.statut <> 'ANNULEE'
   GROUP BY c.id_client, c.nom, c.prenom
)
ORDER BY montant_total_depense DESC
FETCH FIRST 10 ROWS ONLY;

SELECT '8 - Test procedure calculer_total_commande' AS section FROM dual;

SELECT num_commande, montant_total
FROM COMMANDE
WHERE num_commande = 50000;

BEGIN
   calculer_total_commande(50000);
END;
/

SELECT num_commande, montant_total
FROM COMMANDE
WHERE num_commande = 50000;

SELECT '9 - Test procedure appliquer_fidelite' AS section FROM dual;

SELECT id_client, nom, prenom, points_fidelite
FROM CLIENT
WHERE id_client = 1000;

BEGIN
   appliquer_fidelite(1000, 950);
END;
/

SELECT id_client, nom, prenom, points_fidelite
FROM CLIENT
WHERE id_client = 1000;

SELECT '10 - Test trigger stock insuffisant' AS section FROM dual;

BEGIN
   INSERT INTO LIGNE_COMMANDE (
      id_ligne,
      num_commande,
      code_produit,
      quantite,
      prix_unitaire,
      remise
   )
   VALUES (
      9901,
      50026,
      'P014',
      10000,
      12,
      0
   );
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Test stock insuffisant OK : ' || SQLERRM);
END;
/

SELECT '11 - Test audit modification prix' AS section FROM dual;

UPDATE PRODUIT
SET prix_vente = prix_vente + 1
WHERE code_produit = 'P001';

SELECT id_audit, code_produit, ancien_prix_vente, nouveau_prix_vente, utilisateur, date_modification
FROM AUDIT_PRIX_PRODUIT
ORDER BY id_audit DESC
FETCH FIRST 5 ROWS ONLY;

SELECT '12 - Vues principales' AS section FROM dual;

SELECT *
FROM vue_produits_stock_faible
FETCH FIRST 5 ROWS ONLY;

SELECT *
FROM vue_top_clients
FETCH FIRST 5 ROWS ONLY;

SELECT *
FROM vue_stats_ventes_mensuelles
ORDER BY mois;

ROLLBACK;
