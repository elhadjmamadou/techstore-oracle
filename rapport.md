# Analyse complète — TECHSTORE ORACLE

---

## Avancement réel du projet

```
PARTIE 1 - Modélisation        ████████████████████  100%  DONE
PARTIE 2 - Création objets     ████████████████████  100%  DONE
PARTIE 3 - Insertion données   ████████████████████  100%  DONE  ← CORRIGÉ
PARTIE 4 - Requêtes            ████████████████████  100%  DONE
PARTIE 5 - Optimisation        ████████████████████  100%  DONE  ← CORRIGÉ
PARTIE 6 - Sécurité            ████████████████████  100%  DONE
PARTIE 7 - Sauvegarde RMAN     ████████████████████  100%  DONE
PARTIE 8 - PL/SQL Triggers     ████████████████████  100%  DONE  ← CORRIGÉ
PARTIE 9 - Réseau              ████████████████████  100%  DONE
PARTIE 11 - Soutenance         ████████████████████  100%  DONE
```

Le projet est à **100% complet** après corrections.

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

**Statut : COMPLETE**

**Tables (`2_1_creation_tables.sql`) :** 8 tables avec toutes les PK, FK, CHECK, UNIQUE, NOT NULL.

**Séquences (`2_2_creation_sequences.sql`) :**

| Séquence | Début | Cache | Cycle | Note |
|---|---|---|---|---|
| seq_client | 1000 | 20 | Non | |
| seq_commande | 50000 | Aucun | Non | |
| seq_avis | 1 | Aucun | Oui (max 99999) | |
| seq_stock_historique | 1 | Aucun | Non | **AJOUTÉE** — remplace MAX(id)+1 dans TRG_HISTORIQUE |

**Index (`2_3_creation_index.sql`) :**
- B-tree sur `(nom, prenom)` clients ✅
- Index unique sur `email` clients — renommage de l'index créé par `UN_CLIENT_EMAIL` ✅
- Composite `(id_client, date_commande)` sur COMMANDE ✅
- Bitmap sur `statut` commandes ✅
- **AJOUTÉS** : `idx_lc_num_commande` et `idx_lc_code_produit` sur LIGNE_COMMANDE (FK non indexées automatiquement par Oracle)

**Vues (`2_4_creation_vues.sql`) :** 3 vues demandées + 1 bonus :
- `vue_produits_stock_faible`, `vue_top_clients`, `vue_stats_ventes_mensuelles` (READ ONLY), `vue_commandes_recentes`

**Synonymes (`2_5_creation_synonymes.sql`) :** privé `produits` → `PRODUIT`, public `commandes_recentes` → `vue_commandes_recentes` ✅

---

## PARTIE 3 — Insertion des données `03_insertion_donnees/`

**Statut : COMPLETE — CORRIGÉ**

### Corrections apportées

**BUG 1 corrigé — Stock incohérent :**  
Les valeurs `PRODUIT.stock` ont été recalculées : `stock = entree_initiale - total_vendu_LIGNE_COMMANDE`.

| Produit | Avant (incorrect) | Après (correct) | Calcul |
|---|---|---|---|
| P001 | 25 | 27 | 30 − 3 |
| P002 | 30 | 32 | 35 − 3 |
| P003 | 40 | 44 | 50 − 6 |
| P004 | 35 | 40 | 40 − 0 (lignes ANNULEE supprimées) |
| P006 | 10 | 9  | 12 − 3 |
| P008 | 15 | 16 | 18 − 2 |
| P009 | 50 | 56 | 60 − 4 |
| P010 | 25 | 27 | 30 − 3 |
| P011 | 60 | 56 | 60 − 4 |
| P012 | 70 | 64 | 70 − 6 |
| P013 | 100 | 96 | 100 − 4 |
| P014 | 120 | 115 | 120 − 5 |
| P015 | 28 | 25 | 28 − 3 |
| P016 | 22 | 20 | 22 − 2 |
| P017 | 32 | 28 | 32 − 4 |
| P018 | 14 | 12 | 14 − 2 |
| P019 | 20 | 16 | 20 − 4 |
| P020 | 45 | 42 | 45 − 3 |

**BUG 2 corrigé — LIGNE_COMMANDE pour commandes ANNULEE :**  
- Suppression ligne id=14 (commande 50007, ANNULEE, P004)
- Suppression ligne id=32 (commande 50018, ANNULEE, P004)
- `montant_total` des commandes 50007 et 50018 mis à **0**
- Ajout de 2 lignes de remplacement pour maintenir 50 LIGNE_COMMANDE :
  - Ligne 51 : commande 50011, P014, qty=1 → montant 50011 : 210 → **222**
  - Ligne 52 : commande 50014, P013, qty=2 → montant 50014 : 190 → **230**

**BUG 3 corrigé — Conflit seq vs IDs manuels STOCK_HISTORIQUE :**  
Les IDs manuels (1..15) dans STOCK_HISTORIQUE remplacés par `seq_stock_historique.NEXTVAL`.  
Ordre d'exécution des scripts documenté en en-tête de `3_2_scripts_insertion.sql` :
```
1. 02_creation_objets/  →  2. 03_insertion_donnees/  →  3. 08_procedures_declencheurs/
```

**Volumes insérés :**

| Table | Attendu | Inséré |
|---|---|---|
| CATEGORIE | 5 (avec hiérarchie) | 5 (C_ELEC parent, 4 enfants) |
| FOURNISSEUR | — | 5 |
| CLIENT | 15 | 15 |
| PRODUIT | 20 | 20 |
| COMMANDE | 30 sur 6 mois | 30 (Déc 2025 → Mai 2026) |
| LIGNE_COMMANDE | 50 | 50 |
| AVIS | 10 | 10 |
| STOCK_HISTORIQUE | 15 | 15 (10 ENTREE + 5 SORTIE) |

---

## PARTIE 4 — Requêtes `04_requetes_interrogation/`

**Statut : COMPLETE — qualité technique bonne**

- **Simples (4.1) :** 4 requêtes — clients par ville, stock=0, commandes du mois, avis note=5
- **Jointures (4.2) :** chemin hiérarchique avec `SYS_CONNECT_BY_PATH`, CA fournisseur 4 tables, clients sans commande
- **Fonctions de groupe (4.3) :** prix moyen par catégorie, notes avec `NULLS LAST`
- **Sous-requêtes (4.4) :** produits > moyenne, clients > moyenne, `MEDIAN()`
- **Analytiques (4.5) :** `RANK()`, `DENSE_RANK()`, fenêtre glissante 3 mois, `AVG() OVER (PARTITION BY)`

---

## PARTIE 5 — Optimisation `05_optimisation/`

**Statut : COMPLETE — CORRIGÉ**

**Partitionnement (5.2) corrigé :**  
`COMMANDE_PARTITIONNEE` désormais créée avec ses contraintes (`PK`, `CHECK`) avant insertion des données via `INSERT ... SELECT`. L'ancienne syntaxe `CREATE TABLE ... AS SELECT` ne copiait pas les contraintes.

---

## PARTIE 6 — Sécurité `06_administration_securite/`

**Statut : COMPLETE**

4 rôles, 4 utilisateurs, profil `PROFIL_SECURITE`, 3 mécanismes d'audit. Tests dans `tests_securite.sql`.

---

## PARTIE 7 — Sauvegarde RMAN `07_sauvegarde_restauration/`

**Statut : COMPLETE**

> **Correction rapport précédent :** le script `7_2_scripts_rman.rman` contenait DÉJÀ le niveau 1 cumulatif (`BACKUP INCREMENTAL LEVEL 1 CUMULATIVE`). La mention "manquant" dans l'ancienne version de ce rapport était incorrecte.

- Mode ARCHIVELOG activé, FRA 10 Go, rétention 7 jours
- Niveau 0 (dimanche) + Niveau 1 cumulatif (lundi-samedi)
- `strategie_sauvegarde.md` : rédigé ✅
- `test_restauration.md` : rédigé ✅

---

## PARTIE 8 — Procédures et Triggers `08_procedures_declencheurs/`

**Statut : COMPLETE — CORRIGÉ**

**BUG 4 corrigé — TRG_HISTORIQUE :**  
Remplacement de `NVL(MAX(id_historique), 0) + 1` par `seq_stock_historique.NEXTVAL`.  
Garantit l'unicité des IDs sous accès concurrent.

**BUG 2 corrigé — TRG_STOCK :**  
Ajout d'une vérification du statut de la commande avant décrément du stock.  
Si la commande est `ANNULEE`, `RAISE_APPLICATION_ERROR(-20003, ...)` bloque l'insertion.

**BUG 8 corrigé — `reapprovisionner_stock` :**  
Suppression du paramètre `p_seuil` global redondant.  
La procédure filtre désormais sur `stock <= seuil_alerte` (seuil propre à chaque produit).

---

## PARTIE 9 — Réseau `09_reseau_local/`

**Statut : COMPLETE**

DB Link, configuration listener, tests de connexion distante documentés.

---

## Bilan global — Points forts

- Données 100 % cohérentes : `PRODUIT.stock` aligné sur `STOCK_HISTORIQUE + LIGNE_COMMANDE`
- Triggers robustes : séquence dédiée + vérification statut commande
- Sécurité par rôles avec vue `vue_mes_commandes` filtrée par `USER`
- Fonctions analytiques avancées correctement utilisées
- Partitionnement avec contraintes réelles
- Script de démo soutenance prêt à l'emploi

## ✅ Toutes les erreurs identifiées ont été corrigées

| # | Erreur | Fichier(s) corrigé(s) |
|---|---|---|
| 1 | PRODUIT.stock incohérent | `3_1_donnees_test.sql` |
| 2 | LIGNE_COMMANDE pour ANNULEE | `3_2_scripts_insertion.sql` |
| 3 | Conflit PK STOCK_HISTORIQUE | `3_2_scripts_insertion.sql`, `2_2_creation_sequences.sql` |
| 4 | MAX(id)+1 non concurrency-safe | `8_2_declencheurs_triggers.sql` |
| 5 | Index unique email manquant | `2_3_creation_index.sql` |
| 6 | rapport.md incorrect sur RMAN | `rapport.md` |
| 7 | COMMANDE_PARTITIONNEE sans contraintes | `5_2_partitionnement.sql` |
| 8 | reapprovisionner_stock redondant | `8_1_procedures_stockees.sql` |
| 9 | Pas d'index FK LIGNE_COMMANDE | `2_3_creation_index.sql` |
