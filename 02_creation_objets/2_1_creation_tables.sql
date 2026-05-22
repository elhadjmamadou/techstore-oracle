CREATE TABLE CATEGORIE (
   code_categorie        VARCHAR2(20)  NOT NULL,
   nom                   VARCHAR2(100) NOT NULL,
   description           VARCHAR2(500),
   code_categorie_parent VARCHAR2(20),

   CONSTRAINT pk_categorie PRIMARY KEY (code_categorie),
   CONSTRAINT fk_categorie_parent FOREIGN KEY (code_categorie_parent)
      REFERENCES CATEGORIE(code_categorie)
);

CREATE TABLE FOURNISSEUR (
   id_fournisseur  NUMBER(10)    NOT NULL,
   raison_sociale  VARCHAR2(150) NOT NULL,
   contact         VARCHAR2(100),
   telephone       VARCHAR2(30),
   email           VARCHAR2(150),
   adresse         VARCHAR2(300),
   delai_livraison NUMBER(3) DEFAULT 0 NOT NULL,

   CONSTRAINT pk_fournisseur PRIMARY KEY (id_fournisseur),
   CONSTRAINT un_fournisseur_email UNIQUE (email),
   CONSTRAINT ck_fournisseur_delai CHECK (delai_livraison >= 0)
);

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
   date_inscription DATE DEFAULT SYSDATE NOT NULL,
   points_fidelite  NUMBER(5) DEFAULT 0 NOT NULL,

   CONSTRAINT pk_client PRIMARY KEY (id_client),
   CONSTRAINT un_client_email UNIQUE (email),
   CONSTRAINT ck_client_civilite CHECK (civilite IN ('M', 'MME', 'MLLE')),
   CONSTRAINT ck_client_points CHECK (points_fidelite BETWEEN 0 AND 10000)
);

CREATE TABLE PRODUIT (
   code_produit    VARCHAR2(20)   NOT NULL,
   code_categorie VARCHAR2(20)   NOT NULL,
   id_fournisseur NUMBER(10)     NOT NULL,
   nom             VARCHAR2(150)  NOT NULL,
   description     VARCHAR2(1000),
   prix_achat      NUMBER(10,2)   NOT NULL,
   prix_vente      NUMBER(10,2)   NOT NULL,
   stock           NUMBER(10) DEFAULT 0 NOT NULL,
   seuil_alerte    NUMBER(10) DEFAULT 0 NOT NULL,
   date_creation   DATE DEFAULT SYSDATE NOT NULL,
   statut          VARCHAR2(10) DEFAULT 'ACTIF' NOT NULL,

   CONSTRAINT pk_produit PRIMARY KEY (code_produit),
   CONSTRAINT fk_produit_categorie FOREIGN KEY (code_categorie)
      REFERENCES CATEGORIE(code_categorie),
   CONSTRAINT fk_produit_fournisseur FOREIGN KEY (id_fournisseur)
      REFERENCES FOURNISSEUR(id_fournisseur),
   CONSTRAINT ck_produit_prix CHECK (prix_vente > prix_achat),
   CONSTRAINT ck_produit_stock CHECK (stock >= 0),
   CONSTRAINT ck_produit_seuil CHECK (seuil_alerte >= 0),
   CONSTRAINT ck_produit_statut CHECK (statut IN ('ACTIF', 'INACTIF'))
);

CREATE TABLE COMMANDE (
   num_commande          NUMBER(10)   NOT NULL,
   id_client             NUMBER(10)   NOT NULL,
   date_commande         DATE DEFAULT SYSDATE NOT NULL,
   date_livraison_prevue DATE,
   date_livraison_reelle DATE,
   montant_total         NUMBER(12,2) DEFAULT 0 NOT NULL,
   statut                VARCHAR2(20) DEFAULT 'EN_ATTENTE' NOT NULL,

   CONSTRAINT pk_commande PRIMARY KEY (num_commande),
   CONSTRAINT fk_commande_client FOREIGN KEY (id_client)
      REFERENCES CLIENT(id_client),
   CONSTRAINT ck_commande_montant CHECK (montant_total >= 0),
   CONSTRAINT ck_commande_statut CHECK (
      statut IN ('EN_ATTENTE', 'CONFIRMEE', 'EXPEDIEE', 'LIVREE', 'ANNULEE')
   ),
   CONSTRAINT ck_commande_annulee CHECK (
      statut <> 'ANNULEE'
      OR (date_livraison_prevue IS NULL AND date_livraison_reelle IS NULL)
   )
);

CREATE TABLE LIGNE_COMMANDE (
   id_ligne      NUMBER(10)   NOT NULL,
   num_commande  NUMBER(10)   NOT NULL,
   code_produit  VARCHAR2(20) NOT NULL,
   quantite      NUMBER(10)   NOT NULL,
   prix_unitaire NUMBER(10,2) NOT NULL,
   remise        NUMBER(5,2) DEFAULT 0 NOT NULL,

   CONSTRAINT pk_ligne_commande PRIMARY KEY (id_ligne),
   CONSTRAINT fk_ligne_commande_cmd FOREIGN KEY (num_commande)
      REFERENCES COMMANDE(num_commande),
   CONSTRAINT fk_ligne_commande_prod FOREIGN KEY (code_produit)
      REFERENCES PRODUIT(code_produit),
   CONSTRAINT ck_ligne_quantite CHECK (quantite > 0),
   CONSTRAINT ck_ligne_prix CHECK (prix_unitaire >= 0),
   CONSTRAINT ck_ligne_remise CHECK (remise BETWEEN 0 AND 100)
);

CREATE TABLE AVIS (
   id_avis      NUMBER(10)   NOT NULL,
   id_client    NUMBER(10)   NOT NULL,
   code_produit VARCHAR2(20) NOT NULL,
   note         NUMBER(1)    NOT NULL,
   commentaire  VARCHAR2(1000),
   date_avis    DATE DEFAULT SYSDATE NOT NULL,

   CONSTRAINT pk_avis PRIMARY KEY (id_avis),
   CONSTRAINT fk_avis_client FOREIGN KEY (id_client)
      REFERENCES CLIENT(id_client),
   CONSTRAINT fk_avis_produit FOREIGN KEY (code_produit)
      REFERENCES PRODUIT(code_produit),
   CONSTRAINT ck_avis_note CHECK (note BETWEEN 1 AND 5)
);

CREATE TABLE STOCK_HISTORIQUE (
   id_historique         NUMBER(10)   NOT NULL,
   code_produit          VARCHAR2(20) NOT NULL,
   date_mouvement        DATE DEFAULT SYSDATE NOT NULL,
   type_mouvement        VARCHAR2(10) NOT NULL,
   quantite              NUMBER(10)   NOT NULL,
   stock_apres_mouvement NUMBER(10)   NOT NULL,

   CONSTRAINT pk_stock_historique PRIMARY KEY (id_historique),
   CONSTRAINT fk_stock_historique_prod FOREIGN KEY (code_produit)
      REFERENCES PRODUIT(code_produit),
   CONSTRAINT ck_stock_type CHECK (type_mouvement IN ('ENTREE', 'SORTIE')),
   CONSTRAINT ck_stock_quantite CHECK (quantite > 0),
   CONSTRAINT ck_stock_apres CHECK (stock_apres_mouvement >= 0)
);