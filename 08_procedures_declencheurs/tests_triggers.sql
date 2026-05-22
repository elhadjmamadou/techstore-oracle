SET SERVEROUTPUT ON;

SELECT code_produit, nom, stock
FROM PRODUIT
WHERE code_produit = 'P014';

INSERT INTO LIGNE_COMMANDE (
   id_ligne,
   num_commande,
   code_produit,
   quantite,
   prix_unitaire,
   remise
)
VALUES (
   9001,
   50026,
   'P014',
   1,
   12,
   0
);

SELECT code_produit, nom, stock
FROM PRODUIT
WHERE code_produit = 'P014';

SELECT id_historique, code_produit, type_mouvement, quantite, stock_apres_mouvement
FROM STOCK_HISTORIQUE
WHERE code_produit = 'P014'
ORDER BY id_historique DESC;

INSERT INTO AVIS (
   id_avis,
   id_client,
   code_produit,
   note,
   commentaire,
   date_avis
)
VALUES (
   seq_avis.NEXTVAL,
   1011,
   'P018',
   5,
   'Produit achete et avis valide.',
   SYSDATE
);

SELECT id_avis, id_client, code_produit, note, commentaire
FROM AVIS
WHERE id_client = 1011
AND code_produit = 'P018';

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
      9002,
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

BEGIN
   INSERT INTO AVIS (
      id_avis,
      id_client,
      code_produit,
      note,
      commentaire,
      date_avis
   )
   VALUES (
      seq_avis.NEXTVAL,
      1011,
      'P001',
      4,
      'Avis non autorise.',
      SYSDATE
   );
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Test avis refuse OK : ' || SQLERRM);
END;
/

ROLLBACK;