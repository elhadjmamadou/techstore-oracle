# Rapport de vérification complète — TechStore Oracle

**Date de vérification :** 2026-05-25  
**Réalisée par :** Claude Code (analyse statique + tests base live Oracle 23c Free)  
**Base testée :** TECHSTORE@//localhost:1521/FREEPDB1 — conteneur Docker `oracle-free`

---

## 1. Résumé global

| Aspect | Statut |
|---|---|
| Données insérées (volumes) | ✅ 100% corrects (5/5/15/20/30/50/10/15) |
| Cohérence stocks PRODUIT | ✅ Vérifiés (init − vendu = stock actuel) |
| Montants COMMANDE | ✅ Tous recalculés et vérifiés |
| Contraintes CHECK / FK | ✅ Toutes respectées |
| Triggers (5) | ✅ Tous ENABLED et fonctionnels |
| Procédures (3) | ✅ Toutes compilées et testées |
| Vues (5) | ✅ Toutes créées |
| Index (7 + 7 PK/UK) | ✅ Tous VALID |
| Partitionnement | ✅ 6 partitions, contraintes déclarées |
| Mode ARCHIVELOG | ✅ Activé |
| FRA configurée | ✅ 10 Go sur /opt/oracle/oradata/recovery_area |
| Sécurité (rôles, utilisateurs, profil) | ✅ Opérationnel |
| Audit (connexion + triggers métier) | ✅ Opérationnel |
| **Bugs corrigés dans cette session** | **6 corrections appliquées** |

**Conclusion : le projet est prêt pour la soutenance.**  
Les 6 corrections identifiées lors de cette vérification ont toutes été appliquées.

---

## 2. Tableau section par section

| # | Dossier | Fichiers vérifiés | Statut | Problème trouvé | Correction |
|---|---|---|---|---|---|
| 00 | `00_environnement` | `01_docker_compose.md` | ✅ CORRIGÉ | Conteneur `oracle-db` (incorrect), service `ORCLPDB1` (incorrect), mdp `oracle` (incorrect) | Mis à jour : `oracle-free`, `FREEPDB1`, `techstore` |
| 00 | `00_environnement` | `05_verification_oracle.sql` | ✅ CORRIGÉ | Fichier vide (2 lignes inutiles) | Réécriture complète : script de vérification réel |
| 00 | `00_environnement` | `06_creation_utilisateur_techstore.sql` | ⚠️ INFO | Mot de passe `TechStore#2026` ≠ mdp réel `techstore` | Non modifié (cohérence script/doc ; le mdp live est `techstore`) |
| 01 | `01_modelisation_conception` | `1_1_cahier_des_charges.md`, `1_2_contraintes_integrite.md`, MCD/MLD | ✅ OK | — | — |
| 02 | `02_creation_objets` | `2_1_creation_tables.sql` | ✅ OK | — | — |
| 02 | `02_creation_objets` | `2_2_creation_sequences.sql` | ✅ OK | 4 séquences dont `seq_stock_historique` | — |
| 02 | `02_creation_objets` | `2_3_creation_index.sql` | ✅ OK | Index bitmap testé : VALID en Oracle 23c Free | — |
| 02 | `02_creation_objets` | `2_4_creation_vues.sql` | ✅ OK | — | — |
| 02 | `02_creation_objets` | `2_5_creation_synonymes.sql` | ✅ OK | — | — |
| 03 | `03_insertion_donnees` | `3_1_donnees_test.sql` | ✅ OK | Stocks tous corrects (init − vendu) | — |
| 03 | `03_insertion_donnees` | `3_2_scripts_insertion.sql` | ✅ OK | 50 LC, 0 LC pour ANNULEE, seq_stock_historique | — |
| 03 | `03_insertion_donnees` | `verification_insertions.sql` | ✅ OK | — | — |
| 04 | `04_requetes_interrogation` | `4_1` à `4_5` | ✅ OK | — | — |
| 05 | `05_optimisation` | `5_1_analyse_performances.sql` | ✅ OK | EXPLAIN PLAN + index d'optimisation | — |
| 05 | `05_optimisation` | `5_2_partitionnement.sql` | ✅ OK | Contraintes explicites + INSERT SELECT | — |
| 05 | `05_optimisation` | `5_3_statistiques.sql` | ✅ OK | DBMS_STATS sur les 8 tables | — |
| 06 | `06_administration_securite` | `6_1_utilisateurs_roles.sql` | ✅ OK | — | — |
| 06 | `06_administration_securite` | `6_2_profils_utilisateurs.sql` | ✅ OK | — | — |
| 06 | `06_administration_securite` | `6_3_audit.sql` | ✅ OK | Audit unifié + 2 triggers audit métier | — |
| 06 | `06_administration_securite` | `tests_securite.sql` | ✅ CORRIGÉ | `DELETE FROM COMMANDE WHERE num_commande=50029` → ORA-02292 (2 enfants dans LIGNE_COMMANDE) | Changé pour `num_commande=50007` (ANNULEE, 0 enfant) |
| 07 | `07_sauvegarde_restauration` | `7_1_configuration_archivelog_fra.sql` | ✅ CORRIGÉ | Aucun avertissement SYSDBA — exécuté dans DataGrip = erreur | Ajout entête ⚠️ SYSDBA obligatoire + commandes Docker |
| 07 | `07_sauvegarde_restauration` | `7_2_scripts_rman.rman` | ✅ CORRIGÉ | `rman target /` en 1ère ligne (commande shell ≠ RMAN) ; pas de `EXIT;` ; structure confuse | Réécriture : sections claires (config, vérif, niv.0, niv.1, nettoyage, validation) + EXIT |
| 07 | `07_sauvegarde_restauration` | `strategie_sauvegarde.md` | ✅ OK | — | — |
| 07 | `07_sauvegarde_restauration` | `test_restauration.md` | ✅ CORRIGÉ | `SQL ALTER TABLESPACE` → manque `>` (syntaxe RMAN incorrecte) | Corrigé en `SQL> ALTER TABLESPACE` |
| 08 | `08_procedures_declencheurs` | `8_1_procedures_stockees.sql` | ✅ OK | — | — |
| 08 | `08_procedures_declencheurs` | `8_2_declencheurs_triggers.sql` | ✅ OK | — | — |
| 08 | `08_procedures_declencheurs` | `tests_procedures.sql` | ✅ OK | — | — |
| 08 | `08_procedures_declencheurs` | `tests_triggers.sql` | ✅ OK | — | — |
| 09 | `09_reseau_local` | `configuration_reseau.md` | ⚠️ INFO | Mdp affiché `TechStore#2026` ≠ mdp live `techstore` | Non modifié (mdp fictif documenté pour l'exercice) |
| 09 | `09_reseau_local` | `configuration_listener.md` | ✅ OK | — | — |
| 09 | `09_reseau_local` | `test_connexion_autre_groupe.sql` | ⚠️ INFO | Mdp dans DB LINK `TechStore#2026` ≠ mdp live | Non modifié (à adapter selon l'autre groupe) |
| 10 | `10_rapport` | `annexes_scripts.md` | ✅ CORRIGÉ | Référence à `backup_level1_cumulative.rman` inexistant | Supprimé ; tout est dans `7_2_scripts_rman.rman` |
| 10 | `10_rapport` | `rapport_final.docx` | ✅ OK | Document Word présent | — |
| 11 | `11_soutenance` | `scenario_demo.md` | ✅ OK | — | — |
| 11 | `11_soutenance` | `demo_finale.sql` | ✅ OK | ROLLBACK final protège les tests | — |
| 11 | `11_soutenance` | `presentation_TechStore.pptx` | ✅ OK | Fichier PowerPoint présent | — |

---

## 3. Résultat détaillé par section

### SECTION 00 — Environnement

**`01_docker_compose.md` (CORRIGÉ)**
- ❌ Conteneur référencé comme `oracle-db` → correct : `oracle-free`
- ❌ Service `ORCLPDB1` → correct : `FREEPDB1`
- ❌ Mot de passe `oracle` → correct : `techstore`
- ✅ Mis à jour avec les bonnes informations + mention SYSDBA

**`05_verification_oracle.sql` (CORRIGÉ)**
- ❌ Fichier ne contenait que 2 lignes de connexion inutiles
- ✅ Réécriture : vérification utilisateur, service, version Oracle, tables, séquences, index, vues, triggers, synonymes

**`06_creation_utilisateur_techstore.sql` (INFO)**
- ⚠️ Mot de passe dans le script : `TechStore#2026`
- ⚠️ Mot de passe réel live : `techstore`
- Non modifié : le script peut être rejoué avec `TechStore#2026` si besoin d'une réinstallation propre

---

### SECTION 02 — Création des objets (TOUT OK)

| Objet | Statut live |
|---|---|
| 8 tables principales | ✅ VALID |
| AUDIT_PRIX_PRODUIT | ✅ VALID |
| AUDIT_SUPPRESSION_COMMANDE | ✅ VALID |
| COMMANDE_PARTITIONNEE (6 partitions) | ✅ VALID |
| UTILISATEUR_CLIENT | ✅ VALID |
| 4 séquences + SEQ_STOCK_HISTORIQUE | ✅ VALID |
| 7 index + renommage IDX_CLIENT_EMAIL | ✅ VALID |
| Index bitmap IDX_COMMANDE_STATUT | ✅ VALID (Oracle 23c Free le supporte) |
| 5 vues | ✅ VALID |
| 2 synonymes | ✅ VALID |

---

### SECTION 03 — Insertion des données (TOUT OK)

**Volumes vérifiés en base :**

| Table | Attendu | Live | Statut |
|---|---|---|---|
| CATEGORIE | 5 | 5 | ✅ |
| FOURNISSEUR | 5 | 5 | ✅ |
| CLIENT | 15 | 15 | ✅ |
| PRODUIT | 20 | 20 | ✅ |
| COMMANDE | 30 | 30 | ✅ |
| LIGNE_COMMANDE | 50 | 50 | ✅ |
| AVIS | 10 | 10 | ✅ |
| STOCK_HISTORIQUE | 15 | 15 | ✅ |

**Répartition des commandes par statut :**

| Statut | Nombre |
|---|---|
| LIVREE | 18 |
| CONFIRMEE | 4 |
| EN_ATTENTE | 3 |
| EXPEDIEE | 3 |
| ANNULEE | 2 |

**Cohérence montants (vérifiés manuellement) :**  
Tous les 30 `montant_total` ont été recalculés via `∑(quantité × prix × (1 − remise/100))` et correspondent exactement.

**Cohérence stocks (vérifiés manuellement) :**  
Tous les 20 produits : `stock_actuel = stock_initial − total_vendu_LIGNE_COMMANDE`.

**Avis valides (TRG_AVIS) :**  
Les 10 avis ont été vérifiés : chaque client a bien acheté le produit correspondant dans une commande non annulée.

---

### SECTION 04 — Requêtes (TOUT OK)

Toutes les requêtes sont syntaxiquement correctes et Oracle-compatibles :
- ✅ Requêtes simples : filtre, tri, conditions de date
- ✅ Jointures : 4 tables, hiérarchique `SYS_CONNECT_BY_PATH`, LEFT JOIN
- ✅ Fonctions de groupe : GROUP BY, HAVING, AVG, COUNT, SUM, NULLS LAST
- ✅ Sous-requêtes : corrélées, `NOT IN`, `MEDIAN()`, scalaires imbriquées
- ✅ Analytiques : `RANK()`, `DENSE_RANK()`, `SUM() OVER (ROWS BETWEEN)`, `AVG() OVER (PARTITION BY)`

---

### SECTION 05 — Optimisation (TOUT OK)

- ✅ `EXPLAIN PLAN FOR` + `DBMS_XPLAN.DISPLAY` : syntaxe correcte
- ✅ `CREATE INDEX idx_opt_commande_client_statut_montant` : cohérent avec la requête analysée
- ✅ `COMMANDE_PARTITIONNEE` : 6 partitions RANGE sur `date_commande`, contraintes PK + 3 CHECK
- ✅ `DBMS_STATS.GATHER_TABLE_STATS` sur les 8 tables : syntaxe correcte

---

### SECTION 06 — Sécurité (CORRIGÉ)

**Problème corrigé :** `tests_securite.sql` Section 6

```sql
-- AVANT (BUG) :
DELETE FROM COMMANDE WHERE num_commande = 50029;
-- → ORA-02292 : LIGNE_COMMANDE a 2 lignes enfants pour 50029

-- APRÈS (CORRIGÉ) :
DELETE FROM COMMANDE WHERE num_commande = 50007;
-- → OK : commande ANNULEE, aucune ligne dans LIGNE_COMMANDE
```

**Reste fonctionnel :**
- ✅ 4 rôles (ROLE_VENTES, ROLE_STOCK, ROLE_ADMIN, ROLE_CLIENT)
- ✅ 4 utilisateurs (U_VENTES, U_STOCK, U_ADMIN, CLIENT_DEMO)
- ✅ PROFIL_SECURITE avec PASSWORD_LIFE_TIME=90, FAILED_LOGIN_ATTEMPTS=3
- ✅ `AUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL` (audit unifié Oracle 23c)
- ✅ TRG_AUDIT_PRIX_PRODUIT (ENABLED)
- ✅ TRG_AUDIT_SUPPRESSION_COMMANDE (ENABLED)

---

### SECTION 07 — Sauvegarde RMAN (FOCUS SPÉCIAL — 3 CORRECTIONS)

#### 7_1_configuration_archivelog_fra.sql (CORRIGÉ)

**Problème :** Le script contenait `SHUTDOWN IMMEDIATE; STARTUP MOUNT; ALTER DATABASE ARCHIVELOG;` sans aucune mention que ces commandes exigent SYSDBA. Exécuté avec TECHSTORE ou dans DataGrip → erreur garantie.

**Correction :** Ajout d'un entête ⚠️ clair indiquant :
1. Connexion SYSDBA obligatoire
2. Commandes Docker exactes pour se connecter
3. Numérotation des étapes avec commentaires

**État actuel de la base :**
- ✅ Mode ARCHIVELOG : **ACTIVÉ** (vérifié live)
- ✅ FRA : `/opt/oracle/oradata/recovery_area` — **10 Go** (vérifié live)

#### 7_2_scripts_rman.rman (CORRIGÉ)

**Problèmes identifiés :**
1. La 1ère ligne `rman target /` est une commande **shell**, pas une commande RMAN — invalide dans un fichier `.rman`
2. Le script mélangeait la configuration (à faire 1 fois) et les sauvegardes (à faire chaque jour)
3. Aucune commande `EXIT;` à la fin
4. Pas de section `RESTORE DATABASE VALIDATE` / `RESTORE ARCHIVELOG ALL VALIDATE`

**Correction :** Réécriture complète avec 5 sections claires :
```
SECTION 1 : CONFIGURE (à faire 1 fois)
SECTION 2 : VÉRIFICATION avant sauvegarde
SECTION 3A : BACKUP LEVEL 0 (dimanche)
SECTION 3B : BACKUP LEVEL 1 CUMULATIVE (lun-sam)
SECTION 4 : NETTOYAGE (DELETE OBSOLETE)
SECTION 5 : VALIDATION (RESTORE VALIDATE)
EXIT;
```

#### test_restauration.md (CORRIGÉ)

**Problème :** Syntaxe RMAN invalide : `SQL ALTER TABLESPACE users OFFLINE IMMEDIATE;`  
Le mot-clé `SQL` dans RMAN permet d'exécuter du SQL mais la syntaxe requiert le `>` : `SQL> ALTER TABLESPACE users OFFLINE IMMEDIATE;`

**Correction :** `SQL ALTER` → `SQL> ALTER` aux deux endroits.

#### Commandes RMAN à connaître pour la soutenance

```bash
# 1. Entrer dans le conteneur et lancer RMAN
docker exec -it oracle-free bash
rman target /

# 2. Vérifier les sauvegardes
LIST BACKUP SUMMARY;
LIST ARCHIVELOG ALL;

# 3. Tester la restauration (sans toucher à la base)
RESTORE DATABASE VALIDATE;
RESTORE ARCHIVELOG ALL VALIDATE;

# 4. Lancer une sauvegarde complète (niveau 0)
BACKUP INCREMENTAL LEVEL 0 DATABASE PLUS ARCHIVELOG DELETE INPUT TAG 'BACKUP_LEVEL0_DIMANCHE';

# 5. Voir les backups obsolètes
REPORT OBSOLETE;
```

---

### SECTION 08 — Procédures et Triggers (TOUT OK)

**État live des triggers :**

| Trigger | Type | Status | Rôle |
|---|---|---|---|
| TRG_STOCK | BEFORE INSERT / LIGNE_COMMANDE | ✅ ENABLED | Bloque stock insuffisant + commande ANNULEE |
| TRG_HISTORIQUE | AFTER INSERT / LIGNE_COMMANDE | ✅ ENABLED | Décrémente stock + insère STOCK_HISTORIQUE |
| TRG_AVIS | BEFORE INSERT / AVIS | ✅ ENABLED | Bloque avis si client n'a pas acheté |
| TRG_AUDIT_PRIX_PRODUIT | BEFORE UPDATE / PRODUIT | ✅ ENABLED | Audit des modifications de prix |
| TRG_AUDIT_SUPPRESSION_COMMANDE | BEFORE DELETE / COMMANDE | ✅ ENABLED | Audit des suppressions |

**Procédures :**
- ✅ `calculer_total_commande(p_num_commande)` : recalcule via `SUM(qty × prix × (1-remise/100))`
- ✅ `appliquer_fidelite(p_id_client, p_montant)` : 1 pt/10€, plafond 10 000, v_points NUMBER (débordement corrigé)
- ✅ `reapprovisionner_stock` : sans paramètre, filtre `stock <= seuil_alerte`

---

### SECTION 09 — Réseau local (OK — INFO)

- ✅ `configuration_listener.md` : commandes `lsnrctl status`, erreurs fréquentes documentées
- ✅ `configuration_reseau.md` : IP Ubuntu, pare-feu UFW, DataGrip configuration
- ✅ `test_connexion_autre_groupe.sql` : DB Link, tests de connexion, DROP DB LINK
- ⚠️ Le mot de passe dans les docs (`TechStore#2026`) diffère du mot de passe live (`techstore`). À adapter selon la configuration réelle lors de la soutenance.

---

### SECTION 10 — Rapport (CORRIGÉ)

**`annexes_scripts.md` (CORRIGÉ)**
- ❌ Référençait `backup_level1_cumulative.rman` qui n'existe pas
- ✅ Supprimé ; la section 07 ne contient que `7_2_scripts_rman.rman` (qui contient maintenant les deux niveaux)

---

### SECTION 11 — Soutenance (TOUT OK)

- ✅ `scenario_demo.md` : 10 étapes claires, durée 10-15 min, conseils de présentation
- ✅ `demo_finale.sql` : 12 sections avec ROLLBACK final (protège les données)
- ✅ Ordre de démonstration réaliste (voir section 6 ci-dessous)

---

## 4. Focus spécial — Section 07 : Sauvegarde et restauration RMAN

### Ce qui fonctionne en live

| Paramètre | Valeur vérifiée |
|---|---|
| Mode ARCHIVELOG | ✅ ACTIVÉ |
| FRA dest | `/opt/oracle/oradata/recovery_area` |
| FRA size | 10 Go |
| Rétention | 7 jours (CONFIGURE RETENTION POLICY) |
| CONTROLFILE AUTOBACKUP | ON |

### Ce que DataGrip ne peut PAS faire

| Commande | Outil requis |
|---|---|
| `SHUTDOWN IMMEDIATE` | SQL*Plus en SYSDBA |
| `STARTUP MOUNT` | SQL*Plus en SYSDBA |
| `ALTER DATABASE ARCHIVELOG` | SQL*Plus en SYSDBA |
| Toutes les commandes RMAN | Session RMAN (pas SQL) |

### Procédure complète pour une sauvegarde niveau 0

```bash
# Depuis le terminal Ubuntu
docker exec -it oracle-free bash

# Dans le conteneur :
rman target /

# Dans RMAN :
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
BACKUP INCREMENTAL LEVEL 0 DATABASE PLUS ARCHIVELOG DELETE INPUT TAG 'BACKUP_LEVEL0_DIMANCHE';
LIST BACKUP SUMMARY;
EXIT;
```

### Procédure de test de restauration (sans risque)

```bash
docker exec -it oracle-free bash
rman target /

RESTORE DATABASE VALIDATE;
# Résultat attendu : Statement processed (validation succeeded)

RESTORE ARCHIVELOG ALL VALIDATE;
EXIT;
```

---

## 5. Liste des commandes à exécuter dans l'ordre (installation complète)

```text
ORDRE D'EXÉCUTION (installation from scratch) :

PHASE 1 — ENVIRONNEMENT (une seule fois)
  ① docker-compose up -d
  ② sqlplus sys as sysdba → 06_creation_utilisateur_techstore.sql
  ③ sqlplus sys as sysdba → 7_1_configuration_archivelog_fra.sql   ← SYSDBA

PHASE 2 — SCHÉMA (comme TECHSTORE)
  ④ 02_creation_objets/2_1_creation_tables.sql
  ⑤ 02_creation_objets/2_2_creation_sequences.sql
  ⑥ 02_creation_objets/2_3_creation_index.sql
  ⑦ 02_creation_objets/2_4_creation_vues.sql
  ⑧ 02_creation_objets/2_5_creation_synonymes.sql

PHASE 3 — DONNÉES (avant triggers)
  ⑨  03_insertion_donnees/3_1_donnees_test.sql
  ⑩  03_insertion_donnees/3_2_scripts_insertion.sql

PHASE 4 — PL/SQL (après données)
  ⑪ 08_procedures_declencheurs/8_1_procedures_stockees.sql
  ⑫ 08_procedures_declencheurs/8_2_declencheurs_triggers.sql

PHASE 5 — SÉCURITÉ
  ⑬ 06_administration_securite/6_1_utilisateurs_roles.sql
  ⑭ 06_administration_securite/6_2_profils_utilisateurs.sql
  ⑮ 06_administration_securite/6_3_audit.sql

PHASE 6 — OPTIMISATION
  ⑯ 05_optimisation/5_1_analyse_performances.sql
  ⑰ 05_optimisation/5_2_partitionnement.sql
  ⑱ 05_optimisation/5_3_statistiques.sql

PHASE 7 — VÉRIFICATION
  ⑲ 03_insertion_donnees/verification_insertions.sql
  ⑳ 08_procedures_declencheurs/tests_procedures.sql
  ㉑ 08_procedures_declencheurs/tests_triggers.sql
  ㉒ 06_administration_securite/tests_securite.sql

PHASE 8 — RMAN (dans le conteneur Docker)
  ㉓ docker exec -it oracle-free bash → rman target /
     → commandes dans 7_2_scripts_rman.rman
```

---

## 6. Ordre de démonstration recommandé pour la soutenance

| Étape | Durée | Contenu | Outil |
|---|---|---|---|
| 1. Introduction | 1 min | Contexte TechStore, Oracle 23c, Docker | Slides |
| 2. Conception | 2 min | MCD, MLD, 8 entités | Slides + images |
| 3. Objets DB | 2 min | Tables, vues, index — liste dans DataGrip | DataGrip |
| 4. Données | 1 min | Comptage par table (demo_finale.sql §3) | DataGrip |
| 5. Requêtes | 2 min | CA fournisseur, RANK clients (demo §6-7) | DataGrip |
| 6. PL/SQL | 2 min | calculer_total, trigger stock (demo §8-10) | DataGrip |
| 7. Optimisation | 1 min | EXPLAIN PLAN, partitions | DataGrip |
| 8. Sécurité | 1 min | Rôles, audit prix (demo §11) | DataGrip |
| 9. RMAN | 2 min | ARCHIVELOG + LIST BACKUP SUMMARY | Terminal |
| 10. Réseau | 1 min | DB Link, test connexion distante | DataGrip |

---

## 7. Traces et captures à conserver

| # | Capture | Comment l'obtenir |
|---|---|---|
| 1 | `docker ps` avec port 1521 | `docker ps` dans le terminal |
| 2 | `ARCHIVE LOG LIST` | SQL*Plus en SYSDBA |
| 3 | `SHOW PARAMETER db_recovery_file_dest` | SQL*Plus en SYSDBA |
| 4 | `LIST BACKUP SUMMARY` | RMAN dans le conteneur |
| 5 | `RESTORE DATABASE VALIDATE` | RMAN — résultat "validation succeeded" |
| 6 | Comptage par table (demo §3) | DataGrip — demo_finale.sql |
| 7 | Test trigger stock insuffisant | DataGrip — ORA-20001 attendu |
| 8 | Audit prix produit | DataGrip — AUDIT_PRIX_PRODUIT |
| 9 | Connexion distante DataGrip | "Connected successfully" depuis autre poste |

---

## 8. Corrections appliquées dans cette session

| # | Fichier | Problème | Correction |
|---|---|---|---|
| 1 | `00_environnement/01_docker_compose.md` | Conteneur, service et mdp incorrects | Mis à jour avec `oracle-free`, `FREEPDB1`, `techstore` |
| 2 | `00_environnement/05_verification_oracle.sql` | Fichier vide / inutile | Réécriture : script de vérification complet |
| 3 | `06_administration_securite/tests_securite.sql` | DELETE commande 50029 → ORA-02292 (FK enfant) | Changé pour commande 50007 (ANNULEE, 0 enfant) |
| 4 | `07_sauvegarde_restauration/7_1_configuration_archivelog_fra.sql` | Aucune mention SYSDBA obligatoire | Ajout entête ⚠️ + commandes Docker |
| 5 | `07_sauvegarde_restauration/7_2_scripts_rman.rman` | `rman target /` en 1ère ligne (commande shell) ; pas de EXIT ; structure confuse | Réécriture structurée en 5 sections + EXIT |
| 6 | `07_sauvegarde_restauration/test_restauration.md` | `SQL ALTER TABLESPACE` (syntaxe invalide RMAN) | Corrigé : `SQL> ALTER TABLESPACE` |
| 7 | `10_rapport/annexes_scripts.md` | Référence à `backup_level1_cumulative.rman` inexistant | Supprimé de la table |

---

## 9. Conclusion : le projet est-il prêt pour la soutenance ?

**OUI — le projet est 100% opérationnel.**

✅ **Base de données** : 11 tables (8 métier + 2 audit + COMMANDE_PARTITIONNEE + UTILISATEUR_CLIENT), toutes avec contraintes correctes  
✅ **Données** : volumes conformes au sujet, cohérence stock/commande vérifiée  
✅ **PL/SQL** : 3 procédures + 5 triggers compilés et testés  
✅ **Optimisation** : EXPLAIN PLAN fonctionnel, partitionnement à 6 partitions  
✅ **Sécurité** : 4 rôles, 4 utilisateurs, 1 profil, audit connexion + 2 triggers d'audit  
✅ **ARCHIVELOG** : activé, FRA 10 Go configurée  
✅ **Scripts** : corrigés, commentés, avec entêtes clairs  
✅ **Soutenance** : scenario_demo.md + demo_finale.sql prêts  

**Seul point d'attention :** le mot de passe TECHSTORE live est `techstore`, mais les docs réseau et le script de création utilisent `TechStore#2026`. À communiquer clairement lors de la soutenance ou adapter selon la configuration choisie.
