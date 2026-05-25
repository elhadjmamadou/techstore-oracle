-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 6_1_utilisateurs_roles.sql
-- Partie  : 06 - Administration et securite
-- Objectif: Creer les roles, attribuer les privileges et creer
--           les utilisateurs avec leurs roles correspondants
-- Executer: Avec l'utilisateur TECHSTORE (DBA) sur FREEPDB1
-- ============================================================

-- ============================================================
-- ETAPE 1 : CREATION DES 4 ROLES
-- Un role regroupe plusieurs privileges pour simplifier la gestion.
-- On assigne le role a l'utilisateur, pas chaque privilege un par un.
-- ============================================================
CREATE ROLE role_ventes;   -- Pour les commerciaux (consulter/creer des commandes)
CREATE ROLE role_stock;    -- Pour le gestionnaire de stock (voir et modifier le stock)
CREATE ROLE role_admin;    -- Pour l'administrateur (acces complet)
CREATE ROLE role_client;   -- Pour les clients (consulter les produits et leurs commandes)

-- ============================================================
-- ETAPE 2 : PRIVILEGES DU ROLE VENTES
-- Les commerciaux peuvent consulter les produits et gerer les commandes.
-- Ils ont acces a la sequence seq_commande pour creer des numeros.
-- ============================================================
GRANT SELECT ON PRODUIT TO role_ventes;                        -- Consulter le catalogue
GRANT SELECT, INSERT, UPDATE ON COMMANDE TO role_ventes;       -- Gerer les commandes
GRANT SELECT ON seq_commande TO role_ventes;                   -- Utiliser la sequence

-- ============================================================
-- ETAPE 3 : PRIVILEGES DU ROLE STOCK
-- Le gestionnaire de stock peut voir et modifier le stock des produits.
-- Il peut aussi enregistrer les mouvements dans l'historique.
-- ============================================================
GRANT SELECT, UPDATE ON PRODUIT TO role_stock;                 -- Voir et modifier le stock
GRANT INSERT, UPDATE ON STOCK_HISTORIQUE TO role_stock;        -- Enregistrer les mouvements

-- ============================================================
-- ETAPE 4 : PRIVILEGES DU ROLE ADMIN
-- L'administrateur a un acces complet en lecture et ecriture
-- sur toutes les tables du projet.
-- ============================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON CATEGORIE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON FOURNISSEUR TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON CLIENT TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON PRODUIT TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON COMMANDE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON LIGNE_COMMANDE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON AVIS TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON STOCK_HISTORIQUE TO role_admin;

-- Privileges supplementaires pour la gestion du schema
GRANT CREATE USER  TO role_admin;
GRANT CREATE TABLE TO role_admin;

-- ============================================================
-- ETAPE 5 : PRIVILEGES DU ROLE CLIENT
-- Un client connecte peut consulter le catalogue et passer commande.
-- La vue vue_mes_commandes est filtree par l'utilisateur connecte.
-- ============================================================
GRANT SELECT ON PRODUIT TO role_client;                        -- Voir les produits
GRANT INSERT ON COMMANDE TO role_client;                       -- Passer une commande
GRANT SELECT ON seq_commande TO role_client;                   -- Utiliser la sequence

-- ============================================================
-- ETAPE 6 : TABLE DE LIAISON UTILISATEUR / CLIENT
-- Permet d'associer un nom d'utilisateur Oracle (USER)
-- a un id_client dans la table CLIENT.
-- Utilisee par la vue vue_mes_commandes pour filtrer les commandes.
-- ============================================================
CREATE TABLE UTILISATEUR_CLIENT (
   nom_utilisateur VARCHAR2(30) NOT NULL,
   id_client       NUMBER(10) NOT NULL,

   CONSTRAINT pk_utilisateur_client PRIMARY KEY (nom_utilisateur),
   CONSTRAINT fk_utilisateur_client_client FOREIGN KEY (id_client)
      REFERENCES CLIENT(id_client)
);

-- Association de l'utilisateur demo au client 1000
INSERT INTO UTILISATEUR_CLIENT VALUES ('CLIENT_DEMO', 1000);

-- ============================================================
-- ETAPE 7 : VUE SECURISEE vue_mes_commandes
-- Cette vue est accessible uniquement par le role_client.
-- La condition WHERE uc.nom_utilisateur = USER garantit que
-- chaque utilisateur ne voit QUE ses propres commandes.
-- ============================================================
CREATE OR REPLACE VIEW vue_mes_commandes AS
SELECT
   c.num_commande,
   c.id_client,
   c.date_commande,
   c.date_livraison_prevue,
   c.date_livraison_reelle,
   c.montant_total,
   c.statut
FROM COMMANDE c
JOIN UTILISATEUR_CLIENT uc
   ON uc.id_client = c.id_client
-- USER est une fonction Oracle qui retourne le nom de l'utilisateur connecte
WHERE uc.nom_utilisateur = USER;

-- Accorder l'acces a la vue aux utilisateurs avec role_client
GRANT SELECT ON vue_mes_commandes TO role_client;

-- ============================================================
-- ETAPE 8 : CREATION DES 4 UTILISATEURS
-- Chaque utilisateur a un quota limite sur le tablespace users.
-- Mot de passe fort avec majuscule, chiffre et caractere special.
-- ============================================================
CREATE USER u_ventes IDENTIFIED BY "Ventes#2026"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 20M ON users;

CREATE USER u_stock IDENTIFIED BY "Stock#2026"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 20M ON users;

CREATE USER u_admin IDENTIFIED BY "Admin#2026"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 50M ON users;

CREATE USER client_demo IDENTIFIED BY "Client#2026"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 10M ON users;

-- ============================================================
-- ETAPE 9 : AUTORISER LA CONNEXION ET ATTRIBUER LES ROLES
-- Sans CREATE SESSION, un utilisateur ne peut pas se connecter.
-- Chaque utilisateur recoit son role metier correspondant.
-- ============================================================
GRANT CREATE SESSION TO u_ventes;
GRANT CREATE SESSION TO u_stock;
GRANT CREATE SESSION TO u_admin;
GRANT CREATE SESSION TO client_demo;

GRANT role_ventes TO u_ventes;      -- Commerciaux
GRANT role_stock  TO u_stock;       -- Gestionnaire de stock
GRANT role_admin  TO u_admin;       -- Administrateur
GRANT role_client TO client_demo;   -- Client demo (id_client = 1000)

COMMIT;
