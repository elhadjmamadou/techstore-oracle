-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 2_1_creation_tables.sql
-- Partie  : 02 - Creation des objets
-- Objectif: Creer les 8 tables du schema TechStore avec leurs
--           contraintes (PK, FK, CHECK, UNIQUE, NOT NULL)
-- Executer: Avec l'utilisateur TECHSTORE sur FREEPDB1
-- Ordre   : A executer AVANT toute insertion de donnees
-- ============================================================

-- ============================================================
-- TABLE 1 : CATEGORIE
-- Stocke les categories de produits avec une hierarchie :
-- une categorie peut avoir une categorie parente (auto-reference).
-- Exemple : C_ELEC (parent) → C_SMART, C_ORDI (enfants)
-- ============================================================
CREATE TABLE CATEGORIE (
   code_categorie        VARCHAR2(20)  NOT NULL,
   nom                   VARCHAR2(100) NOT NULL,
   description           VARCHAR2(500),
   -- Cle etrangere vers la meme table : hierarchie de categories
   code_categorie_parent VARCHAR2(20),

   -- Cle primaire : identifiant unique de chaque categorie
   CONSTRAINT pk_categorie PRIMARY KEY (code_categorie),
   -- Auto-reference : une categorie enfant pointe vers sa categorie parente
   CONSTRAINT fk_categorie_parent FOREIGN KEY (code_categorie_parent)
      REFERENCES CATEGORIE(code_categorie)
);

-- ============================================================
-- TABLE 2 : FOURNISSEUR
-- Stocke les fournisseurs qui approvisionnent les produits.
-- Un fournisseur peut fournir plusieurs produits.
-- ============================================================
CREATE TABLE FOURNISSEUR (
   id_fournisseur  NUMBER(10)    NOT NULL,
   raison_sociale  VARCHAR2(150) NOT NULL,
   contact         VARCHAR2(100),
   telephone       VARCHAR2(30),
   email           VARCHAR2(150),
   adresse         VARCHAR2(300),
   -- Delai de livraison en jours, minimum 0
   delai_livraison NUMBER(3) DEFAULT 0 NOT NULL,

   CONSTRAINT pk_fournisseur PRIMARY KEY (id_fournisseur),
   -- Un email de fournisseur doit etre unique
   CONSTRAINT un_fournisseur_email UNIQUE (email),
   -- Le delai de livraison ne peut pas etre negatif
   CONSTRAINT ck_fournisseur_delai CHECK (delai_livraison >= 0)
);

-- ============================================================
-- TABLE 3 : CLIENT
-- Stocke les clients de la boutique.
-- Gere les points de fidelite (0 a 10 000 points maximum).
-- ============================================================
CREATE TABLE CLIENT (
   id_client        NUMBER(10)    NOT NULL,
   civilite         VARCHAR2(10),
   nom              VARCHAR2(100) NOT NULL,
   prenom           VARCHAR2(100) NOT NULL,
   email            VARCHAR2(150) NOT NULL,
   telephone        VARCHAR2(30),
   adresse          VARCHAR2(300),
   code_postal      VARCHAR2(20),
   ville            VARCHAR2(100),
   -- Date d'inscription par defaut = date du jour
   date_inscription DATE DEFAULT SYSDATE NOT NULL,
   -- Points de fidelite, initialement 0
   points_fidelite  NUMBER(5) DEFAULT 0 NOT NULL,

   CONSTRAINT pk_client PRIMARY KEY (id_client),
   -- Deux clients ne peuvent pas avoir le meme email
   CONSTRAINT un_client_email UNIQUE (email),
   -- La civilite doit etre l'une des trois valeurs autorisees
   CONSTRAINT ck_client_civilite CHECK (civilite IN ('M', 'MME', 'MLLE')),
   -- Les points de fidelite sont bornes entre 0 et 10 000
   CONSTRAINT ck_client_points CHECK (points_fidelite BETWEEN 0 AND 10000)
);

-- ============================================================
-- TABLE 4 : PRODUIT
-- Stocke les produits disponibles dans la boutique.
-- Chaque produit appartient a une categorie et est fourni par
-- un fournisseur. Le stock doit toujours etre >= 0.
-- ============================================================
CREATE TABLE PRODUIT (
   code_produit    VARCHAR2(20)   NOT NULL,
   code_categorie  VARCHAR2(20)   NOT NULL,
   id_fournisseur  NUMBER(10)     NOT NULL,
   nom             VARCHAR2(150)  NOT NULL,
   description     VARCHAR2(1000),
   prix_achat      NUMBER(10,2)   NOT NULL,
   prix_vente      NUMBER(10,2)   NOT NULL,
   -- Stock actuel : mis a jour par le trigger TRG_HISTORIQUE
   stock           NUMBER(10) DEFAULT 0 NOT NULL,
   -- Seuil d'alerte : si stock <= seuil, reapprovisionnement necessaire
   seuil_alerte    NUMBER(10) DEFAULT 0 NOT NULL,
   date_creation   DATE DEFAULT SYSDATE NOT NULL,
   -- Statut : ACTIF (disponible a la vente) ou INACTIF
   statut          VARCHAR2(10) DEFAULT 'ACTIF' NOT NULL,

   CONSTRAINT pk_produit PRIMARY KEY (code_produit),
   -- Un produit doit appartenir a une categorie existante
   CONSTRAINT fk_produit_categorie FOREIGN KEY (code_categorie)
      REFERENCES CATEGORIE(code_categorie),
   -- Un produit doit avoir un fournisseur existant
   CONSTRAINT fk_produit_fournisseur FOREIGN KEY (id_fournisseur)
      REFERENCES FOURNISSEUR(id_fournisseur),
   -- Regle metier : on vend toujours plus cher qu'on achete
   CONSTRAINT ck_produit_prix CHECK (prix_vente > prix_achat),
   -- Le stock ne peut jamais etre negatif
   CONSTRAINT ck_produit_stock CHECK (stock >= 0),
   CONSTRAINT ck_produit_seuil CHECK (seuil_alerte >= 0),
   -- Le statut doit etre l'une des deux valeurs autorisees
   CONSTRAINT ck_produit_statut CHECK (statut IN ('ACTIF', 'INACTIF'))
);

-- ============================================================
-- TABLE 5 : COMMANDE
-- Enregistre les commandes passees par les clients.
-- Une commande ANNULEE ne peut pas avoir de date de livraison.
-- Le montant total est calcule par la procedure calculer_total_commande.
-- ============================================================
CREATE TABLE COMMANDE (
   num_commande          NUMBER(10)   NOT NULL,
   id_client             NUMBER(10)   NOT NULL,
   date_commande         DATE DEFAULT SYSDATE NOT NULL,
   date_livraison_prevue DATE,
   date_livraison_reelle DATE,
   -- Montant total de la commande (mis a jour par procedure)
   montant_total         NUMBER(12,2) DEFAULT 0 NOT NULL,
   statut                VARCHAR2(20) DEFAULT 'EN_ATTENTE' NOT NULL,

   CONSTRAINT pk_commande PRIMARY KEY (num_commande),
   -- La commande appartient a un client existant
   CONSTRAINT fk_commande_client FOREIGN KEY (id_client)
      REFERENCES CLIENT(id_client),
   -- Le montant total ne peut pas etre negatif
   CONSTRAINT ck_commande_montant CHECK (montant_total >= 0),
   -- Statuts valides pour une commande
   CONSTRAINT ck_commande_statut CHECK (
      statut IN ('EN_ATTENTE', 'CONFIRMEE', 'EXPEDIEE', 'LIVREE', 'ANNULEE')
   ),
   -- Regle metier : une commande ANNULEE n'a pas de date de livraison
   CONSTRAINT ck_commande_annulee CHECK (
      statut <> 'ANNULEE'
      OR (date_livraison_prevue IS NULL AND date_livraison_reelle IS NULL)
   )
);

-- ============================================================
-- TABLE 6 : LIGNE_COMMANDE
-- Chaque ligne represente un produit dans une commande,
-- avec la quantite commandee, le prix unitaire et la remise.
-- L'insertion dans cette table declenche les triggers TRG_STOCK
-- et TRG_HISTORIQUE.
-- ============================================================
CREATE TABLE LIGNE_COMMANDE (
   id_ligne      NUMBER(10)   NOT NULL,
   num_commande  NUMBER(10)   NOT NULL,
   code_produit  VARCHAR2(20) NOT NULL,
   -- La quantite commandee doit etre strictement positive
   quantite      NUMBER(10)   NOT NULL,
   prix_unitaire NUMBER(10,2) NOT NULL,
   -- Remise en pourcentage (0 = pas de remise, 100 = gratuit)
   remise        NUMBER(5,2) DEFAULT 0 NOT NULL,

   CONSTRAINT pk_ligne_commande PRIMARY KEY (id_ligne),
   -- La ligne appartient a une commande existante
   CONSTRAINT fk_ligne_commande_cmd FOREIGN KEY (num_commande)
      REFERENCES COMMANDE(num_commande),
   -- Le produit commande doit exister dans le catalogue
   CONSTRAINT fk_ligne_commande_prod FOREIGN KEY (code_produit)
      REFERENCES PRODUIT(code_produit),
   -- On ne peut pas commander 0 article
   CONSTRAINT ck_ligne_quantite CHECK (quantite > 0),
   CONSTRAINT ck_ligne_prix CHECK (prix_unitaire >= 0),
   -- La remise est exprimee en pourcentage : entre 0 et 100
   CONSTRAINT ck_ligne_remise CHECK (remise BETWEEN 0 AND 100)
);

-- ============================================================
-- TABLE 7 : AVIS
-- Stocke les avis laisses par les clients sur les produits.
-- Le trigger TRG_AVIS verifie que le client a bien achete le
-- produit avant d'autoriser l'insertion d'un avis.
-- ============================================================
CREATE TABLE AVIS (
   id_avis      NUMBER(10)   NOT NULL,
   id_client    NUMBER(10)   NOT NULL,
   code_produit VARCHAR2(20) NOT NULL,
   -- Note de 1 (mauvais) a 5 (excellent)
   note         NUMBER(1)    NOT NULL,
   commentaire  VARCHAR2(1000),
   date_avis    DATE DEFAULT SYSDATE NOT NULL,

   CONSTRAINT pk_avis PRIMARY KEY (id_avis),
   CONSTRAINT fk_avis_client FOREIGN KEY (id_client)
      REFERENCES CLIENT(id_client),
   CONSTRAINT fk_avis_produit FOREIGN KEY (code_produit)
      REFERENCES PRODUIT(code_produit),
   -- La note doit etre comprise entre 1 et 5 etoiles
   CONSTRAINT ck_avis_note CHECK (note BETWEEN 1 AND 5)
);

-- ============================================================
-- TABLE 8 : STOCK_HISTORIQUE
-- Trace tous les mouvements de stock (entrees et sorties).
-- Les sorties sont creees automatiquement par le trigger TRG_HISTORIQUE
-- apres chaque insertion dans LIGNE_COMMANDE.
-- Les entrees sont inseres manuellement lors du reapprovisionnement.
-- ============================================================
CREATE TABLE STOCK_HISTORIQUE (
   id_historique         NUMBER(10)   NOT NULL,
   code_produit          VARCHAR2(20) NOT NULL,
   date_mouvement        DATE DEFAULT SYSDATE NOT NULL,
   -- Type de mouvement : ENTREE (achat fournisseur) ou SORTIE (vente)
   type_mouvement        VARCHAR2(10) NOT NULL,
   quantite              NUMBER(10)   NOT NULL,
   -- Stock restant apres le mouvement (pour audit et tracabilite)
   stock_apres_mouvement NUMBER(10)   NOT NULL,

   CONSTRAINT pk_stock_historique PRIMARY KEY (id_historique),
   CONSTRAINT fk_stock_historique_prod FOREIGN KEY (code_produit)
      REFERENCES PRODUIT(code_produit),
   -- Seuls deux types de mouvements sont autorises
   CONSTRAINT ck_stock_type CHECK (type_mouvement IN ('ENTREE', 'SORTIE')),
   CONSTRAINT ck_stock_quantite CHECK (quantite > 0),
   -- Le stock apres mouvement ne peut pas etre negatif
   CONSTRAINT ck_stock_apres CHECK (stock_apres_mouvement >= 0)
);
