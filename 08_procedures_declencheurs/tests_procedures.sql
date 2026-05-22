SET SERVEROUTPUT ON;

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

BEGIN
   reapprovisionner_stock(10);
END;
/