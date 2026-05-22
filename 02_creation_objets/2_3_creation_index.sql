CREATE INDEX idx_client_nom_prenom
ON CLIENT(nom, prenom);

CREATE INDEX idx_commande_client_date
ON COMMANDE(id_client, date_commande);

CREATE BITMAP INDEX idx_commande_statut
ON COMMANDE(statut);