-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 3_1_donnees_test.sql
-- Partie  : 03 - Insertion des donnees
-- Objectif: Inserer les categories, fournisseurs, clients et produits
-- Executer: Avec TECHSTORE APRES 02_creation_objets/,
--           AVANT 08_procedures_declencheurs/ (triggers desactives ici)
-- ============================================================
-- NOTE STOCK : stock = stock_initial_entree - total_vendu_LIGNE_COMMANDE
-- P001: 30-3=27 | P002: 35-3=32 | P003: 50-6=44 | P004: 40-0=40
-- P006: 12-3=9  | P008: 18-2=16 | P009: 60-4=56 | P010: 30-3=27
-- P011: 60-4=56 | P012: 70-6=64 | P013: 100-4=96| P014: 120-5=115
-- P015: 28-3=25 | P016: 22-2=20 | P017: 32-4=28 | P018: 14-2=12
-- P019: 20-4=16 | P020: 45-3=42
-- ============================================================

-- ============================================================
-- SECTION 1 : CATEGORIES (5 categories)
-- Une categorie parente (C_ELEC) et 4 categories enfants.
-- La hierarchie est exprimee par code_categorie_parent.
-- ============================================================

-- Categorie racine : pas de parent (NULL)
INSERT INTO CATEGORIE VALUES ('C_ELEC',  'Electronique', 'Produits electroniques', NULL);
-- Sous-categories : chacune pointe vers C_ELEC comme parent
INSERT INTO CATEGORIE VALUES ('C_SMART', 'Smartphones',  'Telephones et accessoires mobiles',      'C_ELEC');
INSERT INTO CATEGORIE VALUES ('C_ORDI',  'Ordinateurs',  'Ordinateurs portables et fixes',         'C_ELEC');
INSERT INTO CATEGORIE VALUES ('C_ACC',   'Accessoires',  'Accessoires informatiques',              'C_ELEC');
INSERT INTO CATEGORIE VALUES ('C_RESEAU','Reseau',       'Equipements reseau et peripheriques',    'C_ELEC');

-- ============================================================
-- SECTION 2 : FOURNISSEURS (5 fournisseurs)
-- Les fournisseurs approvisionnent les produits du catalogue.
-- IDs manuels (pas de sequence) : 1 a 5.
-- ============================================================
INSERT INTO FOURNISSEUR VALUES (1, 'Global Tech Distribution', 'Mamadou Diallo',    '622111111', 'contact@globaltech.com',      'Kaloum, Conakry',  7);
INSERT INTO FOURNISSEUR VALUES (2, 'Electro Plus SARL',        'Aissatou Barry',    '622222222', 'contact@electroplus.com',     'Matoto, Conakry',  5);
INSERT INTO FOURNISSEUR VALUES (3, 'Digital Market Afrique',   'Ibrahima Camara',   '622333333', 'contact@digitalmarket.com',   'Dixinn, Conakry',  10);
INSERT INTO FOURNISSEUR VALUES (4, 'Access Pro',               'Fatoumata Conde',   '622444444', 'contact@accesspro.com',       'Ratoma, Conakry',  3);
INSERT INTO FOURNISSEUR VALUES (5, 'Network Solutions',        'Abdoulaye Bah',     '622555555', 'contact@networksolutions.com','Kipe, Conakry',    6);

-- ============================================================
-- SECTION 3 : CLIENTS (15 clients)
-- seq_client.NEXTVAL genere automatiquement : 1000, 1001, ..., 1014
-- Les dates d'inscription couvrent la periode Dec 2025 - Mar 2026.
-- ============================================================
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'M',   'Diallo',   'Mamadou',    'mamadou.diallo@email.com',    '620000001', 'Taouyah',       '001', 'Conakry', TO_DATE('05/12/2025','DD/MM/YYYY'), 120);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'MME', 'Barry',    'Aminata',    'aminata.barry@email.com',     '620000002', 'Matoto',        '002', 'Conakry', TO_DATE('10/12/2025','DD/MM/YYYY'), 250);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'M',   'Camara',   'Ibrahima',   'ibrahima.camara@email.com',   '620000003', 'Dixinn',        '003', 'Conakry', TO_DATE('15/12/2025','DD/MM/YYYY'), 90);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'MME', 'Bah',      'Mariama',    'mariama.bah@email.com',       '620000004', 'Kagbelen',      '004', 'Dubreka', TO_DATE('20/12/2025','DD/MM/YYYY'), 300);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'M',   'Conde',    'Alpha',      'alpha.conde@email.com',       '620000005', 'Ratoma',        '005', 'Conakry', TO_DATE('02/01/2026','DD/MM/YYYY'), 450);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'MME', 'Keita',    'Fatoumata',  'fatoumata.keita@email.com',   '620000006', 'Sangoyah',      '006', 'Conakry', TO_DATE('08/01/2026','DD/MM/YYYY'), 80);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'M',   'Sylla',    'Ousmane',    'ousmane.sylla@email.com',     '620000007', 'Hamdallaye',    '007', 'Conakry', TO_DATE('14/01/2026','DD/MM/YYYY'), 500);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'MME', 'Sow',      'Hadja',      'hadja.sow@email.com',         '620000008', 'Cosa',          '008', 'Conakry', TO_DATE('22/01/2026','DD/MM/YYYY'), 60);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'M',   'Toure',    'Mohamed',    'mohamed.toure@email.com',     '620000009', 'Bambeto',       '009', 'Conakry', TO_DATE('01/02/2026','DD/MM/YYYY'), 700);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'MME', 'Kaba',     'Nene',       'nene.kaba@email.com',         '620000010', 'Sonfonia',      '010', 'Conakry', TO_DATE('05/02/2026','DD/MM/YYYY'), 150);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'M',   'Traore',   'Aboubacar',  'aboubacar.traore@email.com',  '620000011', 'Coyah Centre',  '011', 'Coyah',   TO_DATE('12/02/2026','DD/MM/YYYY'), 0);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'MME', 'Balde',    'Maimouna',   'maimouna.balde@email.com',    '620000012', 'Lambanyi',      '012', 'Conakry', TO_DATE('18/02/2026','DD/MM/YYYY'), 320);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'M',   'Bangoura', 'Sekou',      'sekou.bangoura@email.com',    '620000013', 'Kaporo',        '013', 'Conakry', TO_DATE('25/02/2026','DD/MM/YYYY'), 410);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'MME', 'Soumah',   'Kadiatou',   'kadiatou.soumah@email.com',   '620000014', 'Maneah',        '014', 'Coyah',   TO_DATE('02/03/2026','DD/MM/YYYY'), 50);
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'M',   'Fofana',   'Lamine',     'lamine.fofana@email.com',     '620000015', 'Koloma',        '015', 'Conakry', TO_DATE('10/03/2026','DD/MM/YYYY'), 600);

-- ============================================================
-- SECTION 4 : PRODUITS (20 produits)
-- Format : (code, categorie, fournisseur, nom, description,
--           prix_achat, prix_vente, stock, seuil_alerte, date, statut)
-- stock = stock_initial - quantite_vendue_dans_LIGNE_COMMANDE
-- La contrainte ck_produit_prix verifie que prix_vente > prix_achat.
-- ============================================================

-- Smartphones (C_SMART) fournis par fournisseur 1 et 2
INSERT INTO PRODUIT VALUES ('P001', 'C_SMART', 1, 'iPhone 15',          'Smartphone Apple 128 Go',          750,  950,  27, 5,  TO_DATE('01/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P002', 'C_SMART', 1, 'Samsung Galaxy S24', 'Smartphone Samsung 256 Go',        650,  850,  32, 5,  TO_DATE('01/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P003', 'C_SMART', 2, 'Tecno Camon 20',     'Smartphone Tecno',                 120,  180,  44, 10, TO_DATE('02/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P004', 'C_SMART', 2, 'Infinix Note 30',    'Smartphone Infinix',               100,  160,  40, 10, TO_DATE('02/12/2025','DD/MM/YYYY'), 'ACTIF');

-- Ordinateurs (C_ORDI) fournis par fournisseur 3
INSERT INTO PRODUIT VALUES ('P005', 'C_ORDI',  3, 'MacBook Air M2',     'Ordinateur portable Apple',        950,  1200, 12, 3,  TO_DATE('03/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P006', 'C_ORDI',  3, 'Dell XPS 13',        'Ordinateur portable Dell',         900,  1150, 9,  3,  TO_DATE('03/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P007', 'C_ORDI',  3, 'HP Pavilion 15',     'Ordinateur portable HP',           550,  720,  18, 4,  TO_DATE('04/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P008', 'C_ORDI',  3, 'Lenovo ThinkPad',    'Ordinateur professionnel Lenovo',  700,  950,  16, 4,  TO_DATE('04/12/2025','DD/MM/YYYY'), 'ACTIF');

-- Accessoires (C_ACC) fournis par fournisseur 4
INSERT INTO PRODUIT VALUES ('P009', 'C_ACC',   4, 'AirPods Pro',        'Ecouteurs sans fil Apple',         180,  260,  56, 10, TO_DATE('05/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P010', 'C_ACC',   4, 'Casque Sony WH',     'Casque Bluetooth Sony',            120,  190,  27, 5,  TO_DATE('05/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P011', 'C_ACC',   4, 'Clavier Logitech',   'Clavier sans fil Logitech',        30,   55,   56, 15, TO_DATE('06/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P012', 'C_ACC',   4, 'Souris Logitech',    'Souris sans fil Logitech',         20,   35,   64, 15, TO_DATE('06/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P013', 'C_ACC',   4, 'Chargeur USB-C',     'Chargeur rapide USB-C',            10,   20,   96, 20, TO_DATE('07/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P014', 'C_ACC',   4, 'Cable HDMI',         'Cable HDMI 2 metres',              5,    12,   115,20, TO_DATE('07/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P015', 'C_ACC',   4, 'SSD Samsung 1To',    'Disque SSD externe',               70,   110,  25, 6,  TO_DATE('08/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P016', 'C_ACC',   4, 'Disque dur 2To',     'Disque dur externe',               60,   95,   20, 5,  TO_DATE('08/12/2025','DD/MM/YYYY'), 'ACTIF');

-- Reseau (C_RESEAU) fourni par fournisseur 5
INSERT INTO PRODUIT VALUES ('P017', 'C_RESEAU',5, 'Routeur TP-Link',    'Routeur WiFi double bande',        45,   75,   28, 8,  TO_DATE('09/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P018', 'C_RESEAU',5, 'Imprimante HP',      'Imprimante multifonction HP',      120,  210,  12, 3,  TO_DATE('09/12/2025','DD/MM/YYYY'), 'ACTIF');

-- Ordinateurs suite + Accessoires
INSERT INTO PRODUIT VALUES ('P019', 'C_ORDI',  3, 'Ecran Dell 24',      'Ecran LED 24 pouces',              100,  170,  16, 4,  TO_DATE('10/12/2025','DD/MM/YYYY'), 'ACTIF');
INSERT INTO PRODUIT VALUES ('P020', 'C_ACC',   4, 'Webcam Logitech',    'Webcam HD Logitech',               35,   65,   42, 8,  TO_DATE('10/12/2025','DD/MM/YYYY'), 'ACTIF');

-- Validation definitive de toutes les insertions
COMMIT;
