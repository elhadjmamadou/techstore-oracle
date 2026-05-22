AUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL;

CREATE TABLE AUDIT_PRIX_PRODUIT (
   id_audit          NUMBER GENERATED ALWAYS AS IDENTITY,
   code_produit      VARCHAR2(20),
   ancien_prix_vente NUMBER(10,2),
   nouveau_prix_vente NUMBER(10,2),
   utilisateur       VARCHAR2(30),
   date_modification DATE DEFAULT SYSDATE,

   CONSTRAINT pk_audit_prix_produit PRIMARY KEY (id_audit)
);

CREATE OR REPLACE TRIGGER trg_audit_prix_produit
BEFORE UPDATE OF prix_vente ON PRODUIT
FOR EACH ROW
WHEN (OLD.prix_vente <> NEW.prix_vente)
BEGIN
   INSERT INTO AUDIT_PRIX_PRODUIT (
      code_produit,
      ancien_prix_vente,
      nouveau_prix_vente,
      utilisateur,
      date_modification
   )
   VALUES (
      :OLD.code_produit,
      :OLD.prix_vente,
      :NEW.prix_vente,
      USER,
      SYSDATE
   );
END;
/

CREATE TABLE AUDIT_SUPPRESSION_COMMANDE (
   id_audit        NUMBER GENERATED ALWAYS AS IDENTITY,
   num_commande    NUMBER(10),
   id_client       NUMBER(10),
   montant_total   NUMBER(12,2),
   statut          VARCHAR2(20),
   utilisateur     VARCHAR2(30),
   date_suppression DATE DEFAULT SYSDATE,

   CONSTRAINT pk_audit_suppression_commande PRIMARY KEY (id_audit)
);

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

SELECT trigger_name, status
FROM user_triggers
WHERE trigger_name IN (
   'TRG_AUDIT_PRIX_PRODUIT',
   'TRG_AUDIT_SUPPRESSION_COMMANDE'
);