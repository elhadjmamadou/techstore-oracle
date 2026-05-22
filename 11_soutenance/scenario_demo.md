# Scenario de demonstration - Soutenance TechStore

## Objectif

Presenter une demonstration courte et coherente du projet Oracle TechStore : conception, objets, donnees, requetes, optimisation, securite, sauvegarde et reseau.

## Duree conseillee

10 a 15 minutes.

## Ordre de presentation

### 1. Introduction du projet

Presenter rapidement le contexte : TechStore est une plateforme e-commerce de vente de produits electroniques. L'objectif est de concevoir, developper et administrer une base Oracle complete.

A montrer :

- titre du projet ;
- objectif general ;
- version Oracle utilisee ;
- environnement Docker + DataGrip.

### 2. Conception

Presenter le MCD puis le MLD.

Points a expliquer :

- un client passe des commandes ;
- une commande contient plusieurs lignes ;
- une ligne concerne un produit ;
- un produit appartient a une categorie ;
- une categorie peut avoir une categorie parente ;
- un fournisseur fournit des produits ;
- un avis est lie a un client et a un produit ;
- l'historique de stock trace les mouvements.

### 3. Creation des objets

Expliquer que la partie 2 est separee en cinq fichiers :

1. creation des tables ;
2. creation des sequences ;
3. creation des index ;
4. creation des vues ;
5. creation des synonymes.

A montrer dans DataGrip :

- liste des tables ;
- quelques contraintes ;
- vues creees ;
- index principaux.

### 4. Insertion des donnees

Expliquer le jeu de donnees :

- 5 categories ;
- 20 produits ;
- 15 clients ;
- 30 commandes ;
- 50 lignes de commande ;
- 10 avis ;
- 15 mouvements de stock.

A executer : verification du nombre de lignes par table.

### 5. Requetes d'interrogation

Montrer quelques requetes importantes :

- clients par ville ;
- commandes avec client, produit, quantite et prix ;
- chiffre d'affaires par fournisseur ;
- classement des clients par montant depense ;
- pourcentage du chiffre d'affaires par categorie.

### 6. Procedures et triggers

Montrer que la base applique des regles metier.

Procedures :

- calcul du total d'une commande ;
- ajout des points fidelite ;
- liste des produits a reapprovisionner.

Triggers :

- stock insuffisant refuse ;
- stock mis a jour apres une ligne de commande ;
- avis refuse si le client n'a pas achete le produit.

### 7. Optimisation

Presenter :

- plan d'execution de la requete Top 10 clients ;
- index supplementaire ;
- partitionnement trimestriel de COMMANDE ;
- collecte des statistiques avec DBMS_STATS.

### 8. Securite et audit

Presenter :

- roles : ROLE_VENTES, ROLE_STOCK, ROLE_ADMIN, ROLE_CLIENT ;
- profil de securite ;
- audit des connexions echouees ;
- audit des modifications de prix ;
- audit des suppressions de commandes.

### 9. Sauvegarde et restauration

Expliquer la strategie :

- mode ARCHIVELOG ;
- Flash Recovery Area de 10 Go ;
- retention de 7 jours ;
- sauvegarde RMAN niveau 0 le dimanche ;
- sauvegarde niveau 1 cumulative les autres jours ;
- sauvegarde automatique du fichier de controle.

### 10. Reseau local

Montrer que la base peut etre consultee depuis un autre poste.

A montrer :

- adresse IP du poste serveur ;
- test du port 1521 ;
- connexion DataGrip distante ;
- SELECT sur une table distante ou via DATABASE LINK.

## Fichier de demonstration

Le fichier suivant peut etre execute pendant la soutenance :

```text
11_soutenance/demo_finale.sql
```

## Conseils pour la soutenance

- Ne pas lire les scripts ligne par ligne.
- Expliquer le role de chaque partie.
- Montrer seulement quelques resultats importants.
- Garder les captures si une commande RMAN ou reseau ne peut pas etre executee en direct.
- Terminer par les difficultes rencontrees et les ameliorations possibles.
