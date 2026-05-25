-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 2_3_creation_index.sql
-- Partie  : 02 - Creation des objets
-- Objectif: Creer les index pour accelerer les requetes les
--           plus frequentes et indexer les cles etrangeres
-- Executer: Avec l'utilisateur TECHSTORE, APRES la creation des tables
-- ============================================================

-- ============================================================
-- INDEX 1 : B-TREE sur (nom, prenom) des clients
-- Accelere les recherches et tris de clients par nom/prenom.
-- Type B-tree (par defaut) : efficace pour les recherches par plage.
-- Exemple : SELECT * FROM CLIENT WHERE nom = 'Diallo' ORDER BY prenom;
-- ============================================================
CREATE INDEX idx_client_nom_prenom
ON CLIENT(nom, prenom);

-- ============================================================
-- INDEX 2 : UNIQUE sur email des clients
-- La contrainte UN_CLIENT_EMAIL a deja cree un index implicite.
-- On le renomme ici pour lui donner le nom attendu par le sujet.
-- Un index unique bloque toute insertion d'un email en double.
-- ============================================================
ALTER INDEX UN_CLIENT_EMAIL RENAME TO IDX_CLIENT_EMAIL;

-- ============================================================
-- INDEX 3 : COMPOSITE sur (id_client, date_commande)
-- Accelere les requetes qui filtrent les commandes d'un client
-- sur une periode donnee. Tres utile pour l'historique client.
-- Exemple : SELECT * FROM COMMANDE WHERE id_client=1000 AND date_commande > ...;
-- ============================================================
CREATE INDEX idx_commande_client_date
ON COMMANDE(id_client, date_commande);

-- ============================================================
-- INDEX 4 : BITMAP sur le statut des commandes
-- Adapte aux colonnes a faible cardinalite (peu de valeurs distinctes).
-- Le statut n'a que 5 valeurs : EN_ATTENTE, CONFIRMEE, EXPEDIEE, LIVREE, ANNULEE.
-- Efficace pour les COUNT(*) GROUP BY statut et les filtres WHERE statut=...
-- Note : disponible en Oracle 23c Free (base Enterprise Edition).
-- ============================================================
CREATE BITMAP INDEX idx_commande_statut
ON COMMANDE(statut);

-- ============================================================
-- INDEX 5 & 6 : sur les cles etrangeres de LIGNE_COMMANDE
-- Oracle ne cree PAS automatiquement d'index sur les colonnes FK.
-- Sans ces index, toute jointure sur LIGNE_COMMANDE force un full scan.
-- Ces deux index sont essentiels pour les performances des requetes
-- de detail commande et de CA par produit/fournisseur.
-- ============================================================

-- Index sur num_commande : accelere les jointures COMMANDE ↔ LIGNE_COMMANDE
CREATE INDEX idx_lc_num_commande
ON LIGNE_COMMANDE(num_commande);

-- Index sur code_produit : accelere les jointures PRODUIT ↔ LIGNE_COMMANDE
CREATE INDEX idx_lc_code_produit
ON LIGNE_COMMANDE(code_produit);
