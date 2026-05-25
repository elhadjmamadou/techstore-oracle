-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 3_2_scripts_insertion.sql
-- Partie  : 03 - Insertion des donnees
-- Objectif: Inserer les commandes, lignes de commande, avis
--           et mouvements de stock historiques
-- ============================================================
-- ORDRE D'EXECUTION OBLIGATOIRE :
--   1. 02_creation_objets/ (tables, sequences, index, vues)
--   2. 03_insertion_donnees/ CE FICHIER  ← ici
--   3. 08_procedures_declencheurs/ (triggers et procedures)
-- ATTENTION : Ne jamais lancer ce script si les triggers TRG_STOCK
-- et TRG_HISTORIQUE sont deja actifs — ils bloqueraient les insertions
-- et doubleraient les entrees dans STOCK_HISTORIQUE.
-- ============================================================

-- ============================================================
-- SECTION 1 : COMMANDES (30 commandes sur 6 mois)
-- Periode : Decembre 2025 → Mai 2026
-- Statuts : LIVREE (18), CONFIRMEE (4), EN_ATTENTE (3),
--           EXPEDIEE (3), ANNULEE (2)
-- Commandes ANNULEE : montant_total = 0 et dates livraison = NULL
--   (contrainte ck_commande_annulee)
-- seq_commande.NEXTVAL genere : 50000, 50001, ..., 50029
-- ============================================================

INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1000, TO_DATE('05/12/2025','DD/MM/YYYY'), TO_DATE('10/12/2025','DD/MM/YYYY'), TO_DATE('09/12/2025','DD/MM/YYYY'), 1197.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1001, TO_DATE('12/12/2025','DD/MM/YYYY'), TO_DATE('18/12/2025','DD/MM/YYYY'), TO_DATE('18/12/2025','DD/MM/YYYY'), 1255.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1002, TO_DATE('20/12/2025','DD/MM/YYYY'), TO_DATE('27/12/2025','DD/MM/YYYY'), TO_DATE('26/12/2025','DD/MM/YYYY'),  890.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1003, TO_DATE('28/12/2025','DD/MM/YYYY'), TO_DATE('04/01/2026','DD/MM/YYYY'), NULL,                               1035.00,  'EXPEDIEE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1004, TO_DATE('05/01/2026','DD/MM/YYYY'), TO_DATE('10/01/2026','DD/MM/YYYY'), TO_DATE('10/01/2026','DD/MM/YYYY'),  395.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1005, TO_DATE('11/01/2026','DD/MM/YYYY'), TO_DATE('18/01/2026','DD/MM/YYYY'), TO_DATE('17/01/2026','DD/MM/YYYY'),  235.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1006, TO_DATE('19/01/2026','DD/MM/YYYY'), TO_DATE('25/01/2026','DD/MM/YYYY'), TO_DATE('25/01/2026','DD/MM/YYYY'), 1012.50,  'LIVREE');
-- Commande 50007 : ANNULEE → dates livraison NULL obligatoires, montant = 0
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1007, TO_DATE('25/01/2026','DD/MM/YYYY'), NULL,                               NULL,                                  0.00,  'ANNULEE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1008, TO_DATE('02/02/2026','DD/MM/YYYY'), TO_DATE('08/02/2026','DD/MM/YYYY'), TO_DATE('08/02/2026','DD/MM/YYYY'),  265.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1009, TO_DATE('08/02/2026','DD/MM/YYYY'), TO_DATE('15/02/2026','DD/MM/YYYY'), TO_DATE('14/02/2026','DD/MM/YYYY'),  790.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1010, TO_DATE('15/02/2026','DD/MM/YYYY'), TO_DATE('22/02/2026','DD/MM/YYYY'), NULL,                                855.00,  'EXPEDIEE');
-- Commande 50011 : montant = 210 (P018) + 12 (P014, ligne 51) = 222
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1011, TO_DATE('22/02/2026','DD/MM/YYYY'), TO_DATE('28/02/2026','DD/MM/YYYY'), TO_DATE('28/02/2026','DD/MM/YYYY'),  222.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1012, TO_DATE('01/03/2026','DD/MM/YYYY'), TO_DATE('07/03/2026','DD/MM/YYYY'), TO_DATE('07/03/2026','DD/MM/YYYY'), 1067.50,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1013, TO_DATE('07/03/2026','DD/MM/YYYY'), TO_DATE('14/03/2026','DD/MM/YYYY'), TO_DATE('13/03/2026','DD/MM/YYYY'), 1310.00,  'LIVREE');
-- Commande 50014 : montant = 190 (P016) + 40 (P013×2, ligne 52) = 230
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1014, TO_DATE('14/03/2026','DD/MM/YYYY'), TO_DATE('20/03/2026','DD/MM/YYYY'), TO_DATE('20/03/2026','DD/MM/YYYY'),  230.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1000, TO_DATE('20/03/2026','DD/MM/YYYY'), TO_DATE('27/03/2026','DD/MM/YYYY'), TO_DATE('26/03/2026','DD/MM/YYYY'),  245.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1001, TO_DATE('28/03/2026','DD/MM/YYYY'), TO_DATE('04/04/2026','DD/MM/YYYY'), NULL,                               1260.00,  'CONFIRMEE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1002, TO_DATE('03/04/2026','DD/MM/YYYY'), TO_DATE('10/04/2026','DD/MM/YYYY'), TO_DATE('09/04/2026','DD/MM/YYYY'), 1025.00,  'LIVREE');
-- Commande 50018 : ANNULEE → meme logique que 50007
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1003, TO_DATE('10/04/2026','DD/MM/YYYY'), NULL,                               NULL,                                  0.00,  'ANNULEE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1004, TO_DATE('16/04/2026','DD/MM/YYYY'), TO_DATE('23/04/2026','DD/MM/YYYY'), TO_DATE('22/04/2026','DD/MM/YYYY'),  306.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1005, TO_DATE('22/04/2026','DD/MM/YYYY'), TO_DATE('29/04/2026','DD/MM/YYYY'), NULL,                                380.00,  'EXPEDIEE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1006, TO_DATE('28/04/2026','DD/MM/YYYY'), TO_DATE('05/05/2026','DD/MM/YYYY'), TO_DATE('04/05/2026','DD/MM/YYYY'),  719.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1007, TO_DATE('02/05/2026','DD/MM/YYYY'), TO_DATE('09/05/2026','DD/MM/YYYY'), TO_DATE('09/05/2026','DD/MM/YYYY'), 1060.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1008, TO_DATE('05/05/2026','DD/MM/YYYY'), TO_DATE('12/05/2026','DD/MM/YYYY'), NULL,                                905.00,  'CONFIRMEE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1009, TO_DATE('08/05/2026','DD/MM/YYYY'), TO_DATE('15/05/2026','DD/MM/YYYY'), TO_DATE('14/05/2026','DD/MM/YYYY'),  254.00,  'LIVREE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1010, TO_DATE('10/05/2026','DD/MM/YYYY'), TO_DATE('17/05/2026','DD/MM/YYYY'), NULL,                               1140.00,  'EN_ATTENTE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1011, TO_DATE('12/05/2026','DD/MM/YYYY'), TO_DATE('19/05/2026','DD/MM/YYYY'), NULL,                                150.00,  'CONFIRMEE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1012, TO_DATE('14/05/2026','DD/MM/YYYY'), TO_DATE('21/05/2026','DD/MM/YYYY'), NULL,                               1320.00,  'EN_ATTENTE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1013, TO_DATE('16/05/2026','DD/MM/YYYY'), TO_DATE('23/05/2026','DD/MM/YYYY'), NULL,                                610.00,  'CONFIRMEE');
INSERT INTO COMMANDE VALUES (seq_commande.NEXTVAL, 1014, TO_DATE('18/05/2026','DD/MM/YYYY'), TO_DATE('25/05/2026','DD/MM/YYYY'), NULL,                                542.00,  'EN_ATTENTE');

-- ============================================================
-- SECTION 2 : LIGNES DE COMMANDE (50 lignes)
-- Format : (id_ligne, num_commande, code_produit, quantite,
--           prix_unitaire, remise_en_%)
-- Total ligne = quantite * prix_unitaire * (1 - remise/100)
-- IMPORTANT : aucune ligne pour les commandes ANNULEE (50007, 50018)
--   → le trigger TRG_STOCK bloquerait l'insertion (statut ANNULEE)
-- ============================================================

-- Commande 50000 (client 1000) : iPhone + AirPods avec 5% de remise
INSERT INTO LIGNE_COMMANDE VALUES (1,  50000, 'P001', 1, 950, 0);    -- 950.00
INSERT INTO LIGNE_COMMANDE VALUES (2,  50000, 'P009', 1, 260, 5);    -- 247.00 (5% remise)
-- Commande 50001 (client 1001) : MacBook + Clavier
INSERT INTO LIGNE_COMMANDE VALUES (3,  50001, 'P005', 1, 1200, 0);   -- 1200.00
INSERT INTO LIGNE_COMMANDE VALUES (4,  50001, 'P011', 1, 55, 0);     -- 55.00
-- Commande 50002 (client 1002) : Samsung + 2 Chargeurs USB-C
INSERT INTO LIGNE_COMMANDE VALUES (5,  50002, 'P002', 1, 850, 0);    -- 850.00
INSERT INTO LIGNE_COMMANDE VALUES (6,  50002, 'P013', 2, 20, 0);     -- 40.00
-- Commande 50003 (client 1003) : Dell XPS avec 10% de remise
INSERT INTO LIGNE_COMMANDE VALUES (7,  50003, 'P006', 1, 1150, 10);  -- 1035.00
-- Commande 50004 (client 1004) : 2 Tecno + 1 Souris
INSERT INTO LIGNE_COMMANDE VALUES (8,  50004, 'P003', 2, 180, 0);    -- 360.00
INSERT INTO LIGNE_COMMANDE VALUES (9,  50004, 'P012', 1, 35, 0);     -- 35.00
-- Commande 50005 (client 1005) : Ecran Dell + Webcam
INSERT INTO LIGNE_COMMANDE VALUES (10, 50005, 'P019', 1, 170, 0);    -- 170.00
INSERT INTO LIGNE_COMMANDE VALUES (11, 50005, 'P020', 1, 65, 0);     -- 65.00
-- Commande 50006 (client 1006) : Lenovo ThinkPad 5% + SSD Samsung
INSERT INTO LIGNE_COMMANDE VALUES (12, 50006, 'P008', 1, 950, 5);    -- 902.50
INSERT INTO LIGNE_COMMANDE VALUES (13, 50006, 'P015', 1, 110, 0);    -- 110.00
-- Ligne 14 SUPPRIMEE : etait (14, 50007, 'P004', ...) → commande ANNULEE
-- Commande 50008 (client 1008) : Casque Sony + Routeur
INSERT INTO LIGNE_COMMANDE VALUES (15, 50008, 'P010', 1, 190, 0);    -- 190.00
INSERT INTO LIGNE_COMMANDE VALUES (16, 50008, 'P017', 1, 75, 0);     -- 75.00
-- Commande 50009 (client 1009) : HP Pavilion + 2 Souris
INSERT INTO LIGNE_COMMANDE VALUES (17, 50009, 'P007', 1, 720, 0);    -- 720.00
INSERT INTO LIGNE_COMMANDE VALUES (18, 50009, 'P012', 2, 35, 0);     -- 70.00
-- Commande 50010 (client 1010) : iPhone avec 10% de remise
INSERT INTO LIGNE_COMMANDE VALUES (19, 50010, 'P001', 1, 950, 10);   -- 855.00
-- Commande 50011 (client 1011) : Imprimante HP
INSERT INTO LIGNE_COMMANDE VALUES (20, 50011, 'P018', 1, 210, 0);    -- 210.00
-- Commande 50012 (client 1012) : Samsung 5% + AirPods
INSERT INTO LIGNE_COMMANDE VALUES (21, 50012, 'P002', 1, 850, 5);    -- 807.50
INSERT INTO LIGNE_COMMANDE VALUES (22, 50012, 'P009', 1, 260, 0);    -- 260.00
-- Commande 50013 (client 1013) : MacBook + SSD Samsung
INSERT INTO LIGNE_COMMANDE VALUES (23, 50013, 'P005', 1, 1200, 0);   -- 1200.00
INSERT INTO LIGNE_COMMANDE VALUES (24, 50013, 'P015', 1, 110, 0);    -- 110.00
-- Commande 50014 (client 1014) : 2 Disques durs
INSERT INTO LIGNE_COMMANDE VALUES (25, 50014, 'P016', 2, 95, 0);     -- 190.00
-- Commande 50015 (client 1000) : Tecno + Webcam
INSERT INTO LIGNE_COMMANDE VALUES (26, 50015, 'P003', 1, 180, 0);    -- 180.00
INSERT INTO LIGNE_COMMANDE VALUES (27, 50015, 'P020', 1, 65, 0);     -- 65.00
-- Commande 50016 (client 1001) : Dell XPS + 2 Claviers
INSERT INTO LIGNE_COMMANDE VALUES (28, 50016, 'P006', 1, 1150, 0);   -- 1150.00
INSERT INTO LIGNE_COMMANDE VALUES (29, 50016, 'P011', 2, 55, 0);     -- 110.00
-- Commande 50017 (client 1002) : Lenovo + Routeur
INSERT INTO LIGNE_COMMANDE VALUES (30, 50017, 'P008', 1, 950, 0);    -- 950.00
INSERT INTO LIGNE_COMMANDE VALUES (31, 50017, 'P017', 1, 75, 0);     -- 75.00
-- Ligne 32 SUPPRIMEE : etait (32, 50018, 'P004', ...) → commande ANNULEE
-- Commande 50019 (client 1004) : 2 Ecrans Dell avec 10% de remise
INSERT INTO LIGNE_COMMANDE VALUES (33, 50019, 'P019', 2, 170, 10);   -- 306.00
-- Commande 50020 (client 1005) : 2 Casques Sony
INSERT INTO LIGNE_COMMANDE VALUES (34, 50020, 'P010', 2, 190, 0);    -- 380.00
-- Commande 50021 (client 1006) : HP Pavilion 5% + Souris
INSERT INTO LIGNE_COMMANDE VALUES (35, 50021, 'P007', 1, 720, 5);    -- 684.00
INSERT INTO LIGNE_COMMANDE VALUES (36, 50021, 'P012', 1, 35, 0);     -- 35.00
-- Commande 50022 (client 1007) : iPhone + SSD Samsung
INSERT INTO LIGNE_COMMANDE VALUES (37, 50022, 'P001', 1, 950, 0);    -- 950.00
INSERT INTO LIGNE_COMMANDE VALUES (38, 50022, 'P015', 1, 110, 0);    -- 110.00
-- Commande 50023 (client 1008) : Samsung + Clavier
INSERT INTO LIGNE_COMMANDE VALUES (39, 50023, 'P002', 1, 850, 0);    -- 850.00
INSERT INTO LIGNE_COMMANDE VALUES (40, 50023, 'P011', 1, 55, 0);     -- 55.00
-- Commande 50024 (client 1009) : Imprimante HP 10% + Webcam
INSERT INTO LIGNE_COMMANDE VALUES (41, 50024, 'P018', 1, 210, 10);   -- 189.00
INSERT INTO LIGNE_COMMANDE VALUES (42, 50024, 'P020', 1, 65, 0);     -- 65.00
-- Commande 50025 (client 1010) : MacBook avec 5% de remise
INSERT INTO LIGNE_COMMANDE VALUES (43, 50025, 'P005', 1, 1200, 5);   -- 1140.00
-- Commande 50026 (client 1011) : 2 Routeurs TP-Link
INSERT INTO LIGNE_COMMANDE VALUES (44, 50026, 'P017', 2, 75, 0);     -- 150.00
-- Commande 50027 (client 1012) : Dell XPS + Ecran Dell
INSERT INTO LIGNE_COMMANDE VALUES (45, 50027, 'P006', 1, 1150, 0);   -- 1150.00
INSERT INTO LIGNE_COMMANDE VALUES (46, 50027, 'P019', 1, 170, 0);    -- 170.00
-- Commande 50028 (client 1013) : 3 Tecno + 2 Souris
INSERT INTO LIGNE_COMMANDE VALUES (47, 50028, 'P003', 3, 180, 0);    -- 540.00
INSERT INTO LIGNE_COMMANDE VALUES (48, 50028, 'P012', 2, 35, 0);     -- 70.00
-- Commande 50029 (client 1014) : 2 AirPods 5% + 4 Cables HDMI
INSERT INTO LIGNE_COMMANDE VALUES (49, 50029, 'P009', 2, 260, 5);    -- 494.00
INSERT INTO LIGNE_COMMANDE VALUES (50, 50029, 'P014', 4, 12, 0);     -- 48.00

-- LIGNES AJOUTEES pour atteindre 50 lignes et coherence des montants_total :
-- Ligne 51 : P014 dans 50011 → +12 → total 50011 passe de 210 a 222
INSERT INTO LIGNE_COMMANDE VALUES (51, 50011, 'P014', 1, 12, 0);
-- Ligne 52 : P013 × 2 dans 50014 → +40 → total 50014 passe de 190 a 230
INSERT INTO LIGNE_COMMANDE VALUES (52, 50014, 'P013', 2, 20, 0);

-- ============================================================
-- SECTION 3 : AVIS (10 avis)
-- Chaque avis est verifie par le trigger TRG_AVIS :
-- le client doit avoir achete le produit (commande non annulee).
-- seq_avis.NEXTVAL genere : 1, 2, ..., 10
-- ============================================================

INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1000, 'P001', 5, 'Excellent produit, livraison rapide.',      TO_DATE('12/12/2025','DD/MM/YYYY'));
INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1001, 'P005', 5, 'Ordinateur tres performant.',               TO_DATE('20/12/2025','DD/MM/YYYY'));
INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1002, 'P002', 4, 'Bon smartphone avec une bonne autonomie.', TO_DATE('28/12/2025','DD/MM/YYYY'));
INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1004, 'P003', 4, 'Bon rapport qualite prix.',                TO_DATE('12/01/2026','DD/MM/YYYY'));
INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1005, 'P020', 5, 'Image nette et installation simple.',      TO_DATE('20/01/2026','DD/MM/YYYY'));
INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1006, 'P008', 5, 'Tres bon ordinateur professionnel.',       TO_DATE('28/01/2026','DD/MM/YYYY'));
INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1008, 'P010', 4, 'Casque confortable.',                      TO_DATE('10/02/2026','DD/MM/YYYY'));
INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1009, 'P007', 3, 'Produit correct.',                         TO_DATE('16/02/2026','DD/MM/YYYY'));
INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1012, 'P002', 5, 'Tres satisfait de mon achat.',             TO_DATE('10/03/2026','DD/MM/YYYY'));
INSERT INTO AVIS VALUES (seq_avis.NEXTVAL, 1014, 'P016', 4, 'Disque fiable et rapide.',                 TO_DATE('22/03/2026','DD/MM/YYYY'));

-- ============================================================
-- SECTION 4 : STOCK_HISTORIQUE (15 mouvements)
-- 10 ENTREE : stocks initiaux des produits P001 a P010
-- 5 SORTIE  : premieres sorties documentees pour illustration
-- seq_stock_historique.NEXTVAL genere les IDs 1 a 15.
-- Le trigger TRG_HISTORIQUE prendra le relais des insertions
-- suivantes (a partir de l'ID 16) lors des ventes futures.
-- ============================================================

-- 10 entrees initiales (reception de stock fournisseur)
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P001', TO_DATE('01/12/2025','DD/MM/YYYY'), 'ENTREE', 30, 30);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P002', TO_DATE('01/12/2025','DD/MM/YYYY'), 'ENTREE', 35, 35);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P003', TO_DATE('02/12/2025','DD/MM/YYYY'), 'ENTREE', 50, 50);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P004', TO_DATE('02/12/2025','DD/MM/YYYY'), 'ENTREE', 40, 40);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P005', TO_DATE('03/12/2025','DD/MM/YYYY'), 'ENTREE', 15, 15);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P006', TO_DATE('03/12/2025','DD/MM/YYYY'), 'ENTREE', 12, 12);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P007', TO_DATE('04/12/2025','DD/MM/YYYY'), 'ENTREE', 20, 20);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P008', TO_DATE('04/12/2025','DD/MM/YYYY'), 'ENTREE', 18, 18);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P009', TO_DATE('05/12/2025','DD/MM/YYYY'), 'ENTREE', 60, 60);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P010', TO_DATE('05/12/2025','DD/MM/YYYY'), 'ENTREE', 30, 30);

-- 5 sorties documentees (premières ventes enregistrees manuellement)
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P001', TO_DATE('05/12/2025','DD/MM/YYYY'), 'SORTIE', 1, 29);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P005', TO_DATE('12/12/2025','DD/MM/YYYY'), 'SORTIE', 1, 14);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P002', TO_DATE('20/12/2025','DD/MM/YYYY'), 'SORTIE', 1, 34);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P003', TO_DATE('05/01/2026','DD/MM/YYYY'), 'SORTIE', 2, 48);
INSERT INTO STOCK_HISTORIQUE VALUES (seq_stock_historique.NEXTVAL, 'P009', TO_DATE('01/03/2026','DD/MM/YYYY'), 'SORTIE', 2, 58);

-- Validation definitive de toutes les insertions
COMMIT;
