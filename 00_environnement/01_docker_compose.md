# 01 - Environnement Docker Oracle

## Objectif

Ce document décrit l'environnement Oracle utilisé pour le projet TechStore.

La base Oracle tourne dans un conteneur Docker **séparé** du dossier projet.

---

## Emplacement du fichier docker-compose

```text
../oracle/docker-compose.yml
```

---

## Démarrage du conteneur

```bash
# Se placer dans le dossier oracle
cd ../oracle

# Lancer le conteneur Oracle
docker-compose up -d

# Vérifier que le conteneur tourne
docker ps
```

Résultat attendu :
```
CONTAINER ID   IMAGE                      PORTS                    NAMES
xxxxxxxxxxxx   gvenzl/oracle-free:latest  0.0.0.0:1521->1521/tcp   oracle-free
```

---

## Arrêt du conteneur

```bash
docker-compose down
```

---

## Vérification des logs

```bash
docker logs oracle-free
# Suivi en temps réel :
docker logs -f oracle-free
```

---

## Informations de connexion (CORRIGÉ)

| Paramètre     | Valeur                  |
|---------------|-------------------------|
| Conteneur     | oracle-free             |
| Image         | gvenzl/oracle-free:latest |
| Host          | localhost               |
| Port          | 1521                    |
| Service       | FREEPDB1                |
| Utilisateur projet | techstore          |
| Mot de passe  | techstore               |
| Utilisateur admin | system / sys        |
| Mot de passe admin | Voir .env          |

---

## Connexion SQL*Plus depuis le terminal Ubuntu

```bash
# Connexion utilisateur projet TECHSTORE
docker exec -it oracle-free sqlplus techstore/techstore@//localhost:1521/FREEPDB1

# Connexion administrateur SYSDBA (nécessaire pour ARCHIVELOG, RMAN, etc.)
docker exec -it oracle-free sqlplus 'sys/ChangeMoiFort123!@//localhost:1521/FREEPDB1 as sysdba'
```

---

## Notes importantes

- Le conteneur doit être **démarré avant** toute connexion DataGrip ou SQL*Plus.
- Le premier démarrage peut prendre plusieurs minutes (initialisation de la base).
- Les commandes ARCHIVELOG, RMAN et STARTUP/SHUTDOWN nécessitent une connexion **SYSDBA**, pas TECHSTORE.
- Voir `02_connexion_datagrip.md` pour la configuration DataGrip.
- Voir `07_sauvegarde_restauration/` pour les commandes RMAN.
