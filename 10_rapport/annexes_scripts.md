# Annexes des scripts - Projet Oracle TechStore

Ce fichier liste les scripts et documents produits pour le projet.

## 00_environnement

| Fichier | Role |
|---|---|
| 05_verification_oracle.sql | Verifier la connexion, la version Oracle et la PDB. |
| 06_creation_utilisateur_techstore.sql | Creer le schema principal TECHSTORE. |

## 01_modelisation_conception

| Fichier | Role |
|---|---|
| 1_1_cahier_des_charges.md | Analyse du besoin metier. |
| 1_2_contraintes_integrite.md | Contraintes d'integrite demandees. |
| 1_3_dictionnaire_donnees.xlsx | Dictionnaire des donnees. |
| mcd/MCD_TechStore.png | Schema MCD. |
| mld/MLD_TechStore.png | Schema MLD. |

## 02_creation_objets

| Fichier | Role |
|---|---|
| 2_1_creation_tables.sql | Creation des tables et contraintes. |
| 2_2_creation_sequences.sql | Creation des sequences. |
| 2_3_creation_index.sql | Creation des index. |
| 2_4_creation_vues.sql | Creation des vues. |
| 2_5_creation_synonymes.sql | Creation des synonymes. |

## 03_insertion_donnees

| Fichier | Role |
|---|---|
| 3_1_donnees_test.sql | Insertion des categories, fournisseurs, clients et produits. |
| 3_2_scripts_insertion.sql | Insertion des commandes, lignes, avis et historiques de stock. |
| verification_insertions.sql | Verification du nombre de lignes inserees. |

## 04_requetes_interrogation

| Fichier | Role |
|---|---|
| 4_1_requetes_simples.sql | Requetes simples. |
| 4_2_jointures.sql | Requetes avec jointures. |
| 4_3_fonctions_groupe.sql | Fonctions de groupe. |
| 4_4_sous_requetes.sql | Sous-requetes. |
| 4_5_requetes_analytiques.sql | Requetes analytiques. |

## 05_optimisation

| Fichier | Role |
|---|---|
| 5_1_analyse_performances.sql | Analyse des performances et plans d'execution. |
| 5_2_partitionnement.sql | Proposition de partitionnement trimestriel. |
| 5_3_statistiques.sql | Collecte de statistiques et colonnes candidates aux index bitmap. |

## 06_administration_securite

| Fichier | Role |
|---|---|
| 6_1_utilisateurs_roles.sql | Roles, privileges et utilisateurs. |
| 6_2_profils_utilisateurs.sql | Profil de securite. |
| 6_3_audit.sql | Audit unifie et audit metier par triggers. |
| tests_securite.sql | Tests de securite et audit. |

## 07_sauvegarde_restauration

| Fichier | Role |
|---|---|
| 7_1_configuration_archivelog_fra.sql | Activation ARCHIVELOG et configuration FRA (exécuter en SYSDBA). |
| 7_2_scripts_rman.rman | Scripts RMAN complets : niveau 0 (dimanche), niveau 1 cumulatif (lun-sam), validation et nettoyage. |
| strategie_sauvegarde.md | Documentation de la strategie de sauvegarde. |
| test_restauration.md | Procedures de test et de restauration RMAN. |

## 08_procedures_declencheurs

| Fichier | Role |
|---|---|
| 8_1_procedures_stockees.sql | Procedures stockees. |
| 8_2_declencheurs_triggers.sql | Triggers metier. |
| tests_procedures.sql | Tests des procedures. |
| tests_triggers.sql | Tests des triggers. |

## 09_reseau_local

| Fichier | Role |
|---|---|
| configuration_reseau.md | Configuration reseau local. |
| configuration_listener.md | Verification du listener Oracle. |
| test_connexion_autre_groupe.sql | Tests de connexion distante et DATABASE LINK. |

## 10_rapport

| Fichier | Role |
|---|---|
| rapport_final.docx | Rapport final du projet. |
| annexes_scripts.md | Liste des scripts et annexes. |
