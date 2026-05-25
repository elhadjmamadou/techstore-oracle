-- ============================================================
-- Projet  : TechStore Oracle
-- Fichier : 6_3_audit.sql
-- Partie  : 06 - Administration et securite
-- Objectif: Mettre en place trois mecanismes d'audit :
--   1. Audit Oracle unifie (connexions echouees)
--   2. Audit metier : modifications de prix produit
--   3. Audit metier : suppressions de commandes
-- Executer: Avec l'utilisateur TECHSTORE (DBA) sur FREEPDB1
-- ============================================================

-- ============================================================
-- MECANISME 1 : AUDIT ORACLE UNIFIE (connexions echouees)
-- Oracle 23c utilise l'audit unifie par defaut.
-- Cette commande enregistre toutes les tentatives de connexion
-- echouees dans la vue UNIFIED_AUDIT_TRAIL.
-- "WHENEVER NOT SUCCESSFUL" : uniquement les echecs (pas les succes).
-- Utile pour detecter les attaques par force brute.
-- ============================================================
AUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL;

-- ============================================================
-- MECANISME 2 : AUDIT METIER — MODIFICATIONS DE PRIX
-- Table qui stocke l'historique des modifications de prix.
-- GENERATED ALWAYS AS IDENTITY : l'ID est auto-incremente par Oracle
-- (equivalent moderne aux sequences pour les PK simples).
-- ============================================================
CREATE TABLE AUDIT_PRIX_PRODUIT (
   id_audit           NUMBER GENERATED ALWAYS AS IDENTITY,  -- ID auto
   code_produit       VARCHAR2(20),
   ancien_prix_vente  NUMBER(10,2),    -- Prix avant la modification
   nouveau_prix_vente NUMBER(10,2),    -- Prix apres la modification
   utilisateur        VARCHAR2(30),    -- Nom de l'utilisateur qui a modifie
   date_modification  DATE DEFAULT SYSDATE,

   CONSTRAINT pk_audit_prix_produit PRIMARY KEY (id_audit)
);

-- Trigger qui se declenche automatiquement avant chaque UPDATE de prix
-- WHEN (OLD.prix_vente <> NEW.prix_vente) : seulement si le prix change vraiment
CREATE OR REPLACE TRIGGER trg_audit_prix_produit
BEFORE UPDATE OF prix_vente ON PRODUIT
FOR EACH ROW
WHEN (OLD.prix_vente <> NEW.prix_vente)
BEGIN
   -- Enregistrer l'ancien et le nouveau prix avec l'utilisateur responsable
   INSERT INTO AUDIT_PRIX_PRODUIT (
      code_produit,
      ancien_prix_vente,
      nouveau_prix_vente,
      utilisateur,
      date_modification
   )
   VALUES (
      :OLD.code_produit,
      :OLD.prix_vente,        -- Valeur avant modification
      :NEW.prix_vente,        -- Valeur apres modification
      USER,                   -- Utilisateur Oracle connecte
      SYSDATE
   );
END;
/

-- ============================================================
-- MECANISME 3 : AUDIT METIER — SUPPRESSIONS DE COMMANDES
-- Table qui conserve une trace de toutes les commandes supprimees.
-- Indispensable pour la traçabilite comptable et legale.
-- ============================================================
CREATE TABLE AUDIT_SUPPRESSION_COMMANDE (
   id_audit         NUMBER GENERATED ALWAYS AS IDENTITY,
   num_commande     NUMBER(10),
   id_client        NUMBER(10),
   montant_total    NUMBER(12,2),
   statut           VARCHAR2(20),
   utilisateur      VARCHAR2(30),
   date_suppression DATE DEFAULT SYSDATE,

   CONSTRAINT pk_audit_suppression_commande PRIMARY KEY (id_audit)
);

-- Trigger BEFORE DELETE : capture les donnees avant qu'elles disparaissent
-- :OLD contient les valeurs de la ligne avant suppression
CREATE OR REPLACE TRIGGER trg_audit_suppression_commande
BEFORE DELETE ON COMMANDE
FOR EACH ROW
BEGIN
   INSERT INTO AUDIT_SUPPRESSION_COMMANDE (
      num_commande,
      id_client,
      montant_total,
      statut,
      utilisateur,
      date_suppression
   )
   VALUES (
      :OLD.num_commande,
      :OLD.id_client,
      :OLD.montant_total,
      :OLD.statut,
      USER,
      SYSDATE
   );
END;
/

-- Verification : les deux triggers doivent etre ENABLED
SELECT trigger_name, status
FROM user_triggers
WHERE trigger_name IN (
   'TRG_AUDIT_PRIX_PRODUIT',
   'TRG_AUDIT_SUPPRESSION_COMMANDE'
);
