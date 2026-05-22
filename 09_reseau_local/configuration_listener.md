# Configuration Listener Oracle — TechStore

## 1. Objectif

Le listener Oracle est le processus qui écoute les connexions entrantes sur le port 1521.
Il doit être actif et enregistrer le service `FREEPDB1` pour que les connexions distantes fonctionnent.

---

## 2. Entrer dans le conteneur Docker

Depuis le terminal Ubuntu :

```bash
docker exec -it oracle-free bash
```

On se retrouve dans le shell du conteneur :

```
bash-4.4$
```

---

## 3. Vérifier le listener avec lsnrctl

```bash
lsnrctl status
```

Résultat attendu (extrait) :

```
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))

Services Summary...
Service "FREEPDB1" has 1 instance(s).
  Instance "FREE", status READY, has 1 handler(s) for this service...
```

Points importants à vérifier :
- Le protocole est bien `tcp`
- Le port est bien `1521`
- Le service `FREEPDB1` apparaît avec statut `READY`

---

## 4. Vérification du service FREEPDB1

Si le service `FREEPDB1` n'apparaît pas dans `lsnrctl status`, se connecter en sysdba et vérifier :

```bash
sqlplus 'sys/ChangeMoiFort123!@//localhost:1521/FREEPDB1 as sysdba'
```

Puis vérifier les services actifs :

```sql
SELECT name, open_mode FROM v$pdbs;
```

Si la PDB est montée mais pas ouverte :

```sql
ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;
```

---

## 5. Test de connexion SQL*Plus depuis le conteneur

Depuis l'intérieur du conteneur, tester la connexion avec l'utilisateur du projet :

```bash
sqlplus techstore/techstore@//localhost:1521/FREEPDB1
```

Résultat attendu :

```
Connected to:
Oracle AI Database 23ai Free Release ...
SQL>
```

---

## 6. Test de connexion SQL*Plus depuis un autre poste

Depuis le poste Windows de l'autre groupe, ouvrir un terminal et exécuter :

```bash
sqlplus techstore/techstore@//192.168.1.20:1521/FREEPDB1
```

*(Remplacer `192.168.1.20` par l'IP réelle du poste Ubuntu)*

Résultat attendu :

```
Connected to:
Oracle AI Database 23ai Free Release ...
SQL>
```

---

## 7. Erreurs fréquentes et solutions

### ORA-12514 : service non enregistré

```
ORA-12514: Cannot connect to database. Service FREEPDB1 is not registered with the listener.
```

**Cause** : La PDB n'est pas ouverte ou le service n'est pas enregistré.

**Solution** :
```sql
ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;
```

---

### ORA-12541 : pas de listener

```
ORA-12541: No listener at host ... port 1521.
```

**Cause** : Le listener n'est pas démarré ou le port 1521 n'est pas accessible.

**Solution** :
```bash
lsnrctl stop
lsnrctl start
```

---

### Problème de pare-feu

Si la connexion échoue depuis Windows mais fonctionne en local, c'est probablement le pare-feu Ubuntu qui bloque le port 1521.

**Solution** :
```bash
sudo ufw allow 1521/tcp
sudo ufw reload
```
