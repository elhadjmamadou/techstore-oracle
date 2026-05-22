CREATE INDEX idx_client_nom_prenom
ON CLIENT(nom, prenom);

-- Index unique email déjà créé automatiquement par la contrainte UN_CLIENT_EMAIL
-- CREATE UNIQUE INDEX idx_client_email ON CLIENT(email);

CREATE INDEX idx_commande_client_date
ON COMMANDE(id_client, date_commande);

CREATE BITMAP INDEX idx_commande_statut
ON COMMANDE(statut);