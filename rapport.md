# Analyse complète — TECHSTORE ORACLE

---

## Avancement réel du projet

```
PARTIE 1 - Modélisation        ████████████████████  100%  DONE
PARTIE 2 - Création objets     ████████████████████  100%  DONE
PARTIE 3 - Insertion données   ████████████████████  100%  DONE
PARTIE 4 - Requêtes            ████████████████████  100%  DONE
PARTIE 5 - Optimisation        ████████████████████  100%  DONE
PARTIE 6 - Sécurité            ████████████████████  100%  DONE
PARTIE 7 - Sauvegarde RMAN     ████████████████░░░░   80%  PRESQUE
PARTIE 8 - PL/SQL Triggers     ████████████████████  100%  DONE
PARTIE 9 - Réseau              ████████████████████  100%  DONE
PARTIE 11 - Soutenance         ████████████████████  100%  DONE
```

Le projet est à **~97% complet**.

---

## PARTIE 1 — Modélisation `01_modelisation_conception/`

**Statut : COMPLETE**

- MCD généré en `.dot`, `.png`, `.pdf` via Graphviz
- MLD en `.md`, `.png`, `.pdf` — 8 tables, 9 FK bien documentées
- Cahier des charges avec 9 associations et cardinalités
- Contraintes d'intégrité : 5 règles métier documentées (3 CHECK, 2 triggers)
- Dictionnaire des données `.xlsx` présent
- Hiérarchie de catégories bien gérée avec auto-référence

---

## PARTIE 2 — Création des objets `02_creation_objets/`

**Statut : COMPLETE — quelques points à noter**

**Tables (`2_1_creation_tables.sql`) :** 8 tables complètes avec :
- Toutes les PK, FK, CHECK, UNIQUE, NOT NULL
- Conventions respectées : `pk_`, `fk_`, `ck_`, `un_`
- `DEFAULT SYSDATE` sur les dates, `DEFAULT 0` sur les stocks et points

**Séquences (`2_2_creation_sequences.sql`) :**

| Séquence | Début | Cache | Cycle |
|---|---|---|---|
| seq_client | 1000 | 20 | Non |
| seq_commande | 50000 | Aucun | Non |
| seq_avis | 1 | Aucun | Oui (max 99999) |

**Index (`2_3_creation_index.sql`) :**
- B-tree sur `(nom, prenom)` clients
- Composite sur `(id_client, date_commande)` commandes
- Bitmap sur `statut` commandes

> **Manque** : l'index UNIQUE sur `email` des clients — il est défini comme contrainte dans la table mais l'index explicite demandé dans le sujet (`CREATE UNIQUE INDEX`) n'est pas dans ce fichier.

**Vues (`2_4_creation_vues.sql`) :** Les 3 vues demandées + une 4ème bonus :
- `vue_produits_stock_faible` — produits sous le seuil d'alerte
- `vue_top_clients` — clients ayant dépensé > 1000€, hors commandes annulées
- `vue_stats_ventes_mensuelles` — CA mensuel avec `WITH READ ONLY`
- `vue_commandes_recentes` — bonus, utilisée par le synonyme public

**Synonymes (`2_5_creation_synonymes.sql`) :**
- Synonyme privé `produits` → `PRODUIT`
- Synonyme public `commandes_recentes` → `vue_commandes_recentes`

---

## PARTIE 3 — Insertion des données `03_insertion_donnees/`

**Statut : COMPLETE**

Volumes insérés conformes au sujet :

| Table | Attendu | Inséré |
|---|---|---|
| CATEGORIE | 5 (avec hiérarchie) | 5 (C_ELEC parent, 4 enfants) |
| FOURNISSEUR | — | 5 (basés à Conakry) |
| CLIENT | 15 | 15 |
| PRODUIT | 20 | 20 (iPhone, Samsung, MacBook, Dell...) |
| COMMANDE | 30 sur 6 mois | 30 (Déc 2025 → Mai 2026) |
| LIGNE_COMMANDE | 50 | 50 |
| AVIS | 10 | 10 |
| STOCK_HISTORIQUE | 15 | 15 (10 entrées + 5 sorties) |

Données réalistes avec des noms guinéens, villes de Conakry, produits tech connus. Ordre d'insertion respecté (contraintes FK). `COMMIT` présent à la fin.

---

## PARTIE 4 — Requêtes `04_requetes_interrogation/`

**Statut : COMPLETE — qualité technique bonne**

**Simples (4.1) :** 4 requêtes — clients par ville, stock=0, commandes du mois, avis note=5

**Jointures (4.2) :** 4 requêtes de qualité :
- Détail commandes avec calcul `quantite * prix * (1 - remise/100)`
- Chemin hiérarchique catégories avec `SYS_CONNECT_BY_PATH` + `CONNECT BY PRIOR`
- Clients sans commande avec `LEFT JOIN ... WHERE IS NULL`
- CA par fournisseur avec jointure 4 tables

**Fonctions de groupe (4.3) :** 4 requêtes — statut, prix moyen par catégorie, clients >1 commande, notes moyennes avec `NULLS LAST`

**Sous-requêtes (4.4) :** 4 requêtes — produits les plus vendus vs moyenne, clients > moyenne, produits jamais commandés, commandes > `MEDIAN()`

**Analytiques (4.5) :** 4 requêtes avancées :
- `RANK()` et `DENSE_RANK()` sur les clients
- CA cumulé sur 3 mois glissants avec `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`
- % du CA par catégorie avec `SUM(...) OVER ()`
- Écart prix vs prix moyen catégorie avec `AVG() OVER (PARTITION BY)`

---

## PARTIE 5 — Optimisation `05_optimisation/`

**Statut : COMPLETE**

**Performances (5.1) :**
- `EXPLAIN PLAN` avant création de l'index
- Création d'index composite `(id_client, statut, montant_total)` sur COMMANDE
- `EXPLAIN PLAN` après pour comparaison

**Partitionnement (5.2) :**
- Table `COMMANDE_PARTITIONNEE` créée par `PARTITION BY RANGE (date_commande)` trimestriel
- 6 partitions de T4-2025 à T4-2026 + partition `MAXVALUE`
- Vérification par `user_tab_partitions`

**Statistiques (5.3) :**
- `DBMS_STATS.GATHER_TABLE_STATS` sur les 8 tables
- Requête sur `user_tab_col_statistics` pour colonnes avec NULL
- Identification des colonnes candidates bitmap : `COMMANDE.STATUT`, `PRODUIT.STATUT`, `STOCK_HISTORIQUE.TYPE_MOUVEMENT`, `AVIS.NOTE`

---

## PARTIE 6 — Sécurité `06_administration_securite/`

**Statut : COMPLETE — avec bonus**

**Rôles et utilisateurs (6.1) :** 4 rôles créés avec les bons privilèges :

| Rôle | Privilèges |
|---|---|
| `role_ventes` | SELECT PRODUIT, SELECT/INSERT/UPDATE COMMANDE |
| `role_stock` | SELECT/UPDATE PRODUIT, INSERT/UPDATE STOCK_HISTORIQUE |
| `role_admin` | DML complet sur toutes les tables + CREATE USER/TABLE |
| `role_client` | SELECT PRODUIT, INSERT COMMANDE, SELECT vue_mes_commandes |

4 utilisateurs créés (`u_ventes`, `u_stock`, `u_admin`, `client_demo`) avec quotas limités.

**Bonus :** Table `UTILISATEUR_CLIENT` + vue `vue_mes_commandes` avec `WHERE uc.nom_utilisateur = USER` — solution élégante pour que chaque client ne voie que ses propres commandes.

**Profil (6.2) :** `PROFIL_SECURITE` avec expiration 90j, 3 tentatives, blocage 1j, inactivité 30min — appliqué aux 4 utilisateurs.

**Audit (6.3) :** 3 mécanismes :
- `AUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL` — connexions échouées
- Trigger `TRG_AUDIT_PRIX_PRODUIT` — modifications de `prix_vente` avec avant/après
- Trigger `TRG_AUDIT_SUPPRESSION_COMMANDE` — capture avant suppression

---

## PARTIE 7 — Sauvegarde RMAN `07_sauvegarde_restauration/`

**Statut : 80% — manque la sauvegarde niveau 1**

**Configuration (7.1) :** Séquence complète :
- `SHUTDOWN IMMEDIATE` → `STARTUP MOUNT` → `ALTER DATABASE ARCHIVELOG` → `OPEN`
- FRA configurée à 10 Go sur `/opt/oracle/oradata/recovery_area`
- Vérification avec `ARCHIVE LOG LIST` et `SHOW PARAMETER`

**Scripts RMAN (7.2) :**
- Politique de rétention 7 jours
- Autobackup controlfile activé
- Backup niveau 0 avec `PLUS ARCHIVELOG DELETE INPUT`
- Nettoyage des backups obsolètes et expirés

> **Manque** : le script de sauvegarde **niveau 1 cumulatif** (pour les jours de la semaine hors dimanche).

> **Manque** : `strategie_sauvegarde.md` et `test_restauration.md` sont vides.

---

## PARTIE 8 — Procédures et Triggers `08_procedures_declencheurs/`

**Statut : COMPLETE — qualité technique solide**

**3 procédures (8.1) :**
- `calculer_total_commande(p_num_commande)` — recalcule et met à jour `montant_total` avec remise
- `appliquer_fidelite(p_id_client, p_montant)` — 1 point par 10€, plafond 10 000 avec `LEAST()`
- `reapprovisionner_stock(p_seuil)` — retourne un `SYS_REFCURSOR` avec `DBMS_SQL.RETURN_RESULT`

**3 triggers (8.2) :**
- `TRG_STOCK` (BEFORE INSERT LIGNE_COMMANDE) — bloque si stock insuffisant avec `-20001`
- `TRG_HISTORIQUE` (AFTER INSERT LIGNE_COMMANDE) — décrémente stock + insère dans STOCK_HISTORIQUE
- `TRG_AVIS` (BEFORE INSERT AVIS) — vérifie l'achat préalable via JOIN sur COMMANDE/LIGNE_COMMANDE

> **Point technique :** `TRG_HISTORIQUE` génère l'ID avec `NVL(MAX(id_historique),0)+1` — fragile sous accès concurrent. Mieux vaudrait une séquence dédiée `seq_stock_historique`.

**Tests (tests_triggers.sql) :** 4 scénarios couverts :
- Insertion valide avec vérification du stock avant/après
- Test avis valide (client 1011 a acheté P018)
- Test stock insuffisant (quantite=10000) → message d'erreur capturé
- Test avis refusé (client 1011 n'a pas acheté P001) → message capturé
- `ROLLBACK` final propre

---

## PARTIE 9 — Réseau `09_reseau_local/`

**Statut : COMPLETE**

- `configuration_reseau.md` — guide complet Ubuntu/Windows
- `configuration_listener.md` — vérification listener, erreurs ORA-12514, ORA-12541
- `test_connexion_autre_groupe.sql` — DB Link vers IP fictive `192.168.1.30`

---

## PARTIE 11 — Soutenance `11_soutenance/`

**Statut : COMPLETE**

- `demo_finale.sql` — 12 sections exécutables de bout en bout avec `ROLLBACK` final
- `scenario_demo.md` — plan de présentation 10-15 minutes en 10 étapes
- `presentation.pptx` — présent

---

## Ce qui reste à faire

| Fichier | Action |
|---|---|
| `02_creation_objets/2_3_creation_index.sql` | Ajouter `CREATE UNIQUE INDEX` sur `CLIENT.email` |
| `07_sauvegarde_restauration/7_2_scripts_rman.rman` | Ajouter le backup niveau 1 cumulatif |
| `07_sauvegarde_restauration/strategie_sauvegarde.md` | Rédiger la justification de la stratégie |
| `07_sauvegarde_restauration/test_restauration.md` | Documenter la procédure de restauration |
| `03_insertion_donnees/verification_insertions.sql` | Remplir les requêtes de vérification |
| `06_administration_securite/tests_securite.sql` | Remplir les tests de droits |
| `10_rapport/rapport_final.docx` | Rédiger le rapport final |

---

## Bilan global

**Points forts :**
- Données réalistes avec contexte guinéen (Conakry, noms locaux)
- Triggers bien conçus et testés avec cas d'erreur
- Fonctions analytiques avancées correctement utilisées
- Sécurité par rôles avec vue `vue_mes_commandes` filtrée par `USER`
- Script de démo soutenance prêt à l'emploi

**Points à corriger avant soutenance :**
- Index unique email manquant dans `2_3_creation_index.sql`
- Script RMAN niveau 1 manquant dans `7_2_scripts_rman.rman`
- 3 fichiers de documentation vides (stratégie, restauration, vérification)
