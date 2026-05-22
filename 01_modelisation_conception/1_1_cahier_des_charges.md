# Partie 1.1 - Cahier des charges fonctionnel

## 1. Contexte

TechStore est une plateforme de vente en ligne spécialisée dans les produits électroniques.  
Le projet consiste à concevoir la base de données Oracle permettant de gérer les produits, les catégories, les clients, les commandes, les lignes de commande, les fournisseurs, les avis clients et les mouvements de stock.

## 2. Objectif de la modélisation

L'objectif de cette partie est de transformer le besoin métier en une structure de données claire avant toute création SQL.

Les livrables de conception sont :

- le Modèle Conceptuel de Données (MCD) ;
- le Modèle Logique de Données (MLD) ;
- le dictionnaire des données ;
- la documentation des contraintes d'intégrité.

## 3. Entités à gérer

| Entité | Rôle métier |
|---|---|
| CLIENT | Représente un acheteur inscrit sur la plateforme. |
| COMMANDE | Représente une commande passée par un client. |
| LIGNE_COMMANDE | Détaille les produits commandés dans une commande. |
| PRODUIT | Représente un article vendu par TechStore. |
| CATEGORIE | Permet de classer les produits avec une hiérarchie de catégories. |
| FOURNISSEUR | Représente l'entreprise qui fournit les produits. |
| AVIS | Représente l'évaluation d'un produit par un client. |
| STOCK_HISTORIQUE | Trace les mouvements d'entrée et de sortie de stock. |

## 4. Choix de modélisation retenus

### 4.1 Relation entre produit et fournisseur

Le sujet demande de calculer le chiffre d'affaires par fournisseur.  
Pour rendre cette requête possible, chaque produit est rattaché à un fournisseur principal.

Règle retenue :

> Un fournisseur peut fournir plusieurs produits, mais un produit est rattaché à un seul fournisseur principal.

### 4.2 Hiérarchie des catégories

Une catégorie peut avoir une catégorie parente.  
Cela permet de représenter une arborescence simple, par exemple :

```text
Informatique
├── Ordinateurs
└── Accessoires
```

Règle retenue :

> Une catégorie peut avoir zéro ou une catégorie parente. Une catégorie parente peut avoir plusieurs sous-catégories.

### 4.3 Gestion des avis

Un avis est lié à un client et à un produit.  
La règle métier importante est qu'un client ne peut laisser un avis que s'il a déjà acheté le produit.

Cette règle ne peut pas être totalement garantie par une simple contrainte CHECK.  
Elle sera donc contrôlée plus tard par un trigger `TRG_AVIS`.

### 4.4 Gestion du stock

Le stock courant est stocké dans la table `PRODUIT`.  
Les mouvements de stock sont historisés dans `STOCK_HISTORIQUE`.

Règle retenue :

> Chaque mouvement de stock concerne un produit et enregistre le stock après mouvement.

## 5. Relations et cardinalités

| Association | Cardinalité côté gauche | Cardinalité côté droit | Description |
|---|---:|---:|---|
| CLIENT - COMMANDE | CLIENT 0,N | COMMANDE 1,1 | Un client peut passer plusieurs commandes. Une commande appartient à un seul client. |
| COMMANDE - LIGNE_COMMANDE | COMMANDE 1,N | LIGNE_COMMANDE 1,1 | Une commande contient au moins une ligne. Une ligne appartient à une commande. |
| PRODUIT - LIGNE_COMMANDE | PRODUIT 0,N | LIGNE_COMMANDE 1,1 | Un produit peut être commandé plusieurs fois. Une ligne concerne un seul produit. |
| CATEGORIE - PRODUIT | CATEGORIE 0,N | PRODUIT 1,1 | Une catégorie contient plusieurs produits. Un produit appartient à une catégorie. |
| CATEGORIE - CATEGORIE | Parent 0,N | Enfant 0,1 | Une catégorie peut avoir des sous-catégories. |
| FOURNISSEUR - PRODUIT | FOURNISSEUR 0,N | PRODUIT 1,1 | Un fournisseur fournit plusieurs produits. Un produit a un fournisseur principal. |
| CLIENT - AVIS | CLIENT 0,N | AVIS 1,1 | Un client peut rédiger plusieurs avis. Un avis appartient à un seul client. |
| PRODUIT - AVIS | PRODUIT 0,N | AVIS 1,1 | Un produit peut recevoir plusieurs avis. Un avis concerne un seul produit. |
| PRODUIT - STOCK_HISTORIQUE | PRODUIT 0,N | STOCK_HISTORIQUE 1,1 | Un produit peut avoir plusieurs mouvements de stock. |

## 6. Hypothèses de conception

1. Le montant total d'une commande est stocké dans `COMMANDE`, mais il doit être recalculé à partir des lignes de commande.
2. Le prix unitaire dans `LIGNE_COMMANDE` correspond au prix appliqué au moment de l'achat.
3. La remise est exprimée en pourcentage.
4. Le stock ne peut jamais être négatif.
5. Les statuts sont contrôlés par des listes de valeurs.
6. Les points de fidélité sont compris entre 0 et 10 000.
7. Une commande annulée ne doit pas avoir de date de livraison.
8. Un client ne peut publier un avis que sur un produit déjà acheté.

## 7. Livrables associés

| Livrable | Emplacement |
|---|---|
| MCD schéma PNG | `01_modelisation_conception/mcd/MCD_TechStore.png` |
| MCD schéma PDF | `01_modelisation_conception/mcd/MCD_TechStore.pdf` |
| MLD schéma PNG | `01_modelisation_conception/mld/MLD_TechStore.png` |
| MLD schéma PDF | `01_modelisation_conception/mld/MLD_TechStore.pdf` |
| MLD détaillé | `01_modelisation_conception/mld/MLD_TechStore.md` |
| Dictionnaire des données | `01_modelisation_conception/1_3_dictionnaire_donnees.xlsx` |
