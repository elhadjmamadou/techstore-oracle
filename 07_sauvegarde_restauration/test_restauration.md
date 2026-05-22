# Test de restauration — TechStore Oracle

## 1. Objectif

Ce document décrit la procédure de test pour vérifier que la sauvegarde RMAN fonctionne correctement et que la base peut être restaurée en cas de besoin.

---

## 2. Vérification des sauvegardes disponibles

Depuis le conteneur Docker :

```bash
docker exec -it oracle-free bash
rman target /
```

Puis dans RMAN :

```
LIST BACKUP SUMMARY;
LIST ARCHIVELOG ALL;
CROSSCHECK BACKUP;
```

---

## 3. Test de restauration sans écraser la base (RESTORE VALIDATE)

Ce test vérifie que les fichiers de sauvegarde sont lisibles et suffisants pour une restauration, sans toucher à la base en production.

```
RESTORE DATABASE VALIDATE;
RESTORE ARCHIVELOG ALL VALIDATE;
```

Résultat attendu : `validation succeeded`

---

## 4. Restauration complète (en cas de panne réelle)

> **Attention** : cette procédure efface les données actuelles. Ne l'exécuter qu'en cas de panne réelle.

```bash
rman target /
```

```
SHUTDOWN ABORT;
STARTUP MOUNT;
RESTORE DATABASE;
RECOVER DATABASE;
ALTER DATABASE OPEN RESETLOGS;
ALTER PLUGGABLE DATABASE ALL OPEN;
```

---

## 5. Restauration d'un tablespace spécifique

Si seul un tablespace est corrompu :

```
SQL ALTER TABLESPACE users OFFLINE IMMEDIATE;
RESTORE TABLESPACE users;
RECOVER TABLESPACE users;
SQL ALTER TABLESPACE users ONLINE;
```

---

## 6. Vérification après restauration

```sql
SELECT name, open_mode FROM v$pdbs;
SELECT COUNT(*) FROM techstore.client;
SELECT COUNT(*) FROM techstore.commande;
SELECT COUNT(*) FROM techstore.produit;
```

---

## 7. Captures à conserver

- Résultat de `LIST BACKUP SUMMARY`
- Résultat de `RESTORE DATABASE VALIDATE`
- Message de succès de la restauration
