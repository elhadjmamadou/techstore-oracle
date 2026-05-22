SELECT ville, nom, prenom, email, telephone
FROM CLIENT
ORDER BY ville ASC, nom ASC, prenom ASC;

SELECT code_produit, nom, stock, seuil_alerte, statut
FROM PRODUIT
WHERE stock = 0
ORDER BY nom;

SELECT num_commande, id_client, date_commande, montant_total, statut
FROM COMMANDE
WHERE date_commande >= ADD_MONTHS(SYSDATE, -1)
ORDER BY date_commande DESC;

SELECT id_avis, id_client, code_produit, note, commentaire, date_avis
FROM AVIS
WHERE note = 5
ORDER BY date_avis DESC;