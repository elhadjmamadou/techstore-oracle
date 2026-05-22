# Configuration Réseau — TechStore Oracle

## 1. Objectif

Cette partie a pour but de relier deux bases de données Oracle situées sur deux postes différents.
Depuis un poste, on doit pouvoir consulter les données de la base Oracle de l'autre groupe.

La connexion se fait via le réseau local (LAN) en exposant le port Oracle 1521 du conteneur Docker.

---

## 2. Environnement technique

| Poste | OS | Oracle | Connexion |
|---|---|---|---|
| Groupe A (nous) | Ubuntu + Docker | gvenzl/oracle-free | localhost:1521/FREEPDB1 |
| Groupe B (eux) | Windows | Oracle natif ou Docker | IP_WINDOWS:1521/FREEPDB1 |

Utilisateur projet : `techstore`
Mot de passe : `TechStore#2026`
Service : `FREEPDB1`

---

## 3. Vérification du conteneur Docker (Ubuntu)

S'assurer que le conteneur est bien démarré et que le port 1521 est exposé :

```bash
docker ps
```

Résultat attendu :

```
CONTAINER ID   IMAGE                      PORTS                    NAMES
xxxxxxxxxxxx   gvenzl/oracle-free:latest  0.0.0.0:1521->1521/tcp   oracle-free
```

Si le conteneur est arrêté :

```bash
docker start oracle-free
```

---

## 4. Récupération de l'adresse IP Ubuntu

Sur le poste Ubuntu, récupérer l'adresse IP locale :

```bash
ip a
```

ou plus directement :

```bash
hostname -I
```

Exemple de résultat : `192.168.1.20`

Cette adresse IP sera donnée à l'autre groupe pour qu'il puisse se connecter.

---

## 5. Vérification du pare-feu Ubuntu

Vérifier si le pare-feu est actif :

```bash
sudo ufw status
```

Si le port 1521 est bloqué, l'autoriser :

```bash
sudo ufw allow 1521/tcp
sudo ufw reload
```

Vérification :

```bash
sudo ufw status | grep 1521
```

---

## 6. Test du port 1521 depuis Windows

Depuis le poste Windows de l'autre groupe, ouvrir un terminal PowerShell et tester la connectivité :

```powershell
Test-NetConnection -ComputerName 192.168.1.20 -Port 1521
```

Résultat attendu :

```
TcpTestSucceeded : True
```

Si `False` → le pare-feu Ubuntu bloque le port ou les deux postes ne sont pas sur le même réseau.

---

## 7. Connexion depuis DataGrip (autre groupe)

Sur le poste Windows, ouvrir DataGrip et créer une nouvelle source de données Oracle :

| Champ | Valeur |
|---|---|
| Host | 192.168.1.20 *(remplacer par l'IP réelle)* |
| Port | 1521 |
| Service | FREEPDB1 |
| User | techstore |
| Password | TechStore#2026 |

Cliquer sur **Test Connection**.
Si le test réussit → la connexion réseau est fonctionnelle.

---

## 8. Captures à conserver dans `captures/`

| Nom du fichier | Contenu |
|---|---|
| `01_docker_ps.png` | Résultat de `docker ps` avec le port 1521 exposé |
| `02_ip_ubuntu.png` | Résultat de `hostname -I` ou `ip a` |
| `03_ufw_status.png` | Résultat de `sudo ufw status` |
| `04_test_port_windows.png` | Résultat de `Test-NetConnection` depuis Windows |
| `05_datagrip_connexion_distante.png` | Fenêtre DataGrip avec la connexion distante configurée |
| `06_datagrip_test_ok.png` | Message "Connected successfully" dans DataGrip |
| `07_select_produits_distant.png` | Résultat d'un SELECT sur la base distante |
