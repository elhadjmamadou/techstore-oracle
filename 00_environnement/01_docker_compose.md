# 01 - Environnement Docker Oracle

## Objectif

Ce document décrit l'environnement Oracle utilisé pour le projet TechStore.

La base Oracle tourne dans un conteneur Docker séparé du dossier projet.

## Emplacement du conteneur Oracle

Dossier Oracle local :

```text
../oracle/
```

## Démarrage du conteneur

```bash
# Se placer dans le dossier oracle
cd ../oracle

# Lancer le conteneur Oracle
docker-compose up -d

# Vérifier que le conteneur tourne
docker ps
```

## Arrêt du conteneur

```bash
docker-compose down
```

## Vérification des logs

```bash
docker logs oracle-db
# ou
docker logs -f oracle-db
```

## Informations de connexion

| Paramètre     | Valeur             |
|---------------|--------------------|
| Host          | localhost          |
| Port          | 1521               |
| SID / Service | ORCLCDB / ORCLPDB1 |
| Utilisateur   | system / sys       |
| Mot de passe  | oracle             |

## Connexion via SQL*Plus

```bash
docker exec -it oracle-db sqlplus system/oracle@//localhost:1521/ORCLPDB1
```

## Notes

- Le conteneur doit être démarré **avant** toute connexion DataGrip ou SQL*Plus.
- Le premier démarrage peut prendre plusieurs minutes (initialisation de la base).
- Voir `02_connexion_datagrip.md` pour la configuration DataGrip.
