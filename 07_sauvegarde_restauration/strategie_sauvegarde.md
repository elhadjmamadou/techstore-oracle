# Stratégie de sauvegarde — TechStore Oracle

## 1. Objectif

Ce document décrit la stratégie de sauvegarde mise en place pour la base de données Oracle TechStore.
L'objectif est de garantir la récupération des données en cas de panne, d'erreur humaine ou de corruption.

---

## 2. Mode ARCHIVELOG

La base fonctionne en mode **ARCHIVELOG**.

Ce mode permet de sauvegarder la base pendant qu'elle est en ligne (sans l'arrêter) et de rejouer les transactions depuis n'importe quel point dans le temps.

Activation :

```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
```

---

## 3. Flash Recovery Area (FRA)

La FRA est une zone de stockage dédiée aux sauvegardes, archives et fichiers de contrôle.

| Paramètre | Valeur |
|---|---|
| Emplacement | `/opt/oracle/oradata/recovery_area` |
| Taille | 10 Go |
| Rétention | 7 jours |

---

## 4. Politique de sauvegarde hebdomadaire

| Jour | Type de sauvegarde | Description |
|---|---|---|
| Dimanche | Niveau 0 (complète) | Sauvegarde complète de toute la base + archive logs |
| Lundi → Samedi | Niveau 1 cumulatif | Sauvegarde des blocs modifiés depuis le dernier niveau 0 |

**Avantage du niveau 1 cumulatif :** en cas de restauration, on n'a besoin que du dernier niveau 0 et du dernier niveau 1 — pas de toute la semaine.

---

## 5. Fichier de contrôle

Le fichier de contrôle est sauvegardé automatiquement après chaque backup grâce à :

```
CONFIGURE CONTROLFILE AUTOBACKUP ON;
```

---

## 6. Nettoyage automatique

Les sauvegardes expirées et obsolètes sont supprimées automatiquement :

```
DELETE NOPROMPT EXPIRED BACKUP;
DELETE NOPROMPT OBSOLETE;
```

---

## 7. Résumé

- Mode ARCHIVELOG activé
- FRA de 10 Go configurée
- Rétention de 7 jours
- Backup complet le dimanche
- Backup cumulatif du lundi au samedi
- Autobackup du fichier de contrôle
