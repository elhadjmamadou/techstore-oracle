# Modèle Logique de Données - TechStore

## 1. Objectif

Ce document présente le Modèle Logique de Données (MLD) du projet TechStore.  
Il transforme le MCD en tables relationnelles prêtes à être implémentées dans Oracle.

## 2. Conventions

- `PK` : clé primaire
- `FK` : clé étrangère
- `UN` : contrainte d'unicité
- `CK` : contrainte de contrôle
- Les clés étrangères sont indiquées avec `#`.

## 3. Tables relationnelles

### CATEGORIE

```text
CATEGORIE(
    code_categorie PK,
    nom,
    description,
    code_categorie_parent FK -> CATEGORIE(code_categorie)
)
```

### FOURNISSEUR

```text
FOURNISSEUR(
    id_fournisseur PK,
    raison_sociale,
    contact,
    telephone,
    email,
    adresse,
    delai_livraison
)
```

### PRODUIT

```text
PRODUIT(
    code_produit PK,
    code_categorie FK -> CATEGORIE(code_categorie),
    id_fournisseur FK -> FOURNISSEUR(id_fournisseur),
    nom,
    description,
    prix_achat,
    prix_vente,
    stock,
    seuil_alerte,
    date_creation,
    statut
)
```

### CLIENT

```text
CLIENT(
    id_client PK,
    civilite,
    nom,
    prenom,
    email UN,
    telephone,
    adresse,
    code_postal,
    ville,
    date_inscription,
    points_fidelite
)
```

### COMMANDE

```text
COMMANDE(
    num_commande PK,
    id_client FK -> CLIENT(id_client),
    date_commande,
    date_livraison_prevue,
    date_livraison_reelle,
    montant_total,
    statut
)
```

### LIGNE_COMMANDE

```text
LIGNE_COMMANDE(
    id_ligne PK,
    num_commande FK -> COMMANDE(num_commande),
    code_produit FK -> PRODUIT(code_produit),
    quantite,
    prix_unitaire,
    remise
)
```

### AVIS

```text
AVIS(
    id_avis PK,
    id_client FK -> CLIENT(id_client),
    code_produit FK -> PRODUIT(code_produit),
    note,
    commentaire,
    date_avis
)
```

### STOCK_HISTORIQUE

```text
STOCK_HISTORIQUE(
    id_historique PK,
    code_produit FK -> PRODUIT(code_produit),
    date_mouvement,
    type_mouvement,
    quantite,
    stock_apres_mouvement
)
```

## 4. Liste des clés étrangères

| Table | Colonne | Référence | Rôle |
|---|---|---|---|
| CATEGORIE | code_categorie_parent | CATEGORIE(code_categorie) | Hiérarchie de catégories |
| PRODUIT | code_categorie | CATEGORIE(code_categorie) | Classement du produit |
| PRODUIT | id_fournisseur | FOURNISSEUR(id_fournisseur) | Fournisseur principal du produit |
| COMMANDE | id_client | CLIENT(id_client) | Client ayant passé la commande |
| LIGNE_COMMANDE | num_commande | COMMANDE(num_commande) | Commande concernée |
| LIGNE_COMMANDE | code_produit | PRODUIT(code_produit) | Produit commandé |
| AVIS | id_client | CLIENT(id_client) | Auteur de l'avis |
| AVIS | code_produit | PRODUIT(code_produit) | Produit évalué |
| STOCK_HISTORIQUE | code_produit | PRODUIT(code_produit) | Produit concerné par le mouvement |

## 5. Justification principale

Le modèle permet de répondre à toutes les demandes du projet :

- gestion des produits, catégories et fournisseurs ;
- gestion des clients et commandes ;
- calcul du chiffre d'affaires par fournisseur ;
- suivi du stock et de son historique ;
- contrôle des avis clients ;
- création des vues, requêtes, index, triggers et procédures demandés dans les parties suivantes.
