# Partie 1.2 - Contraintes d'intégrité

## 1. Objectif

Ce document décrit les contraintes d'intégrité nécessaires pour garantir la cohérence des données de la base TechStore.

Certaines contraintes peuvent être gérées directement par des contraintes SQL (`CHECK`, `UNIQUE`, `NOT NULL`, `FOREIGN KEY`).  
D'autres nécessitent une logique PL/SQL avec des triggers, car elles dépendent de plusieurs tables.

---

## 2. Contraintes imposées par le sujet

| N° | Contrainte demandée | Table concernée | Type de contrôle prévu | Justification |
|---:|---|---|---|---|
| 1 | Un client ne peut pas avoir plus de 10 000 points de fidélité. | CLIENT | CHECK | La règle concerne une seule colonne. |
| 2 | Une commande annulée ne peut pas avoir de date de livraison. | COMMANDE | CHECK | La règle concerne le statut et les dates de livraison dans la même table. |
| 3 | Le prix de vente doit être supérieur au prix d'achat. | PRODUIT | CHECK | La règle compare deux colonnes d'une même table. |
| 4 | Un avis ne peut être laissé que par un client ayant acheté le produit. | AVIS, COMMANDE, LIGNE_COMMANDE | TRIGGER | La règle nécessite de vérifier l'existence d'un achat dans plusieurs tables. |
| 5 | Le stock ne peut pas devenir négatif. | PRODUIT, LIGNE_COMMANDE | CHECK + TRIGGER | Le stock courant est contrôlé par CHECK, mais la sortie de stock doit être contrôlée avant l'insertion d'une ligne de commande. |

---

## 3. Contraintes détaillées

### 3.1 Points de fidélité

Règle :

```text
0 <= points_fidelite <= 10000
```

Implémentation prévue :

```sql
CONSTRAINT ck_client_points CHECK (points_fidelite BETWEEN 0 AND 10000)
```

---

### 3.2 Commande annulée sans date de livraison

Règle métier :

> Si une commande est annulée, elle ne doit pas avoir de date de livraison prévue ni de date de livraison réelle.

Implémentation prévue :

```sql
CONSTRAINT ck_commande_annulee_dates
CHECK (
    statut <> 'ANNULEE'
    OR (
        date_livraison_prevue IS NULL
        AND date_livraison_reelle IS NULL
    )
)
```

---

### 3.3 Prix de vente supérieur au prix d'achat

Règle :

```text
prix_vente > prix_achat
```

Implémentation prévue :

```sql
CONSTRAINT ck_produit_prix CHECK (prix_vente > prix_achat)
```

---

### 3.4 Avis seulement après achat

Règle métier :

> Un client ne peut laisser un avis sur un produit que s'il a déjà commandé ce produit.

Cette contrainte ne peut pas être écrite avec un simple `CHECK`, car elle nécessite de consulter les tables :

- `AVIS`
- `COMMANDE`
- `LIGNE_COMMANDE`

Implémentation prévue plus tard :

```text
Trigger TRG_AVIS
```

Principe :

1. Lorsqu'on insère un avis, récupérer `id_client` et `code_produit`.
2. Vérifier qu'il existe au moins une commande du client contenant ce produit.
3. Si aucun achat n'existe, refuser l'insertion avec `RAISE_APPLICATION_ERROR`.

---

### 3.5 Stock non négatif

Règles :

```text
stock >= 0
quantite commandée > 0
stock disponible >= quantite commandée
```

Implémentations prévues :

1. Contrainte `CHECK` sur `PRODUIT.stock`.
2. Trigger `TRG_STOCK` avant insertion dans `LIGNE_COMMANDE`.
3. Trigger `TRG_HISTORIQUE` après insertion dans `LIGNE_COMMANDE` pour mettre à jour le stock et enregistrer le mouvement.

---

## 4. Contraintes complémentaires recommandées

| Table | Contrainte | Type | Raison |
|---|---|---|---|
| CLIENT | email unique | UNIQUE | Éviter deux comptes avec le même email. |
| PRODUIT | statut dans ACTIF / INACTIF | CHECK | Contrôler les valeurs autorisées. |
| COMMANDE | statut dans EN_ATTENTE / CONFIRMEE / EXPEDIEE / LIVREE / ANNULEE | CHECK | Contrôler le cycle de commande. |
| AVIS | note entre 1 et 5 | CHECK | Respecter le cahier des charges. |
| LIGNE_COMMANDE | quantite > 0 | CHECK | Éviter une ligne de commande invalide. |
| LIGNE_COMMANDE | remise entre 0 et 100 | CHECK | Une remise est un pourcentage. |
| STOCK_HISTORIQUE | type_mouvement dans ENTREE / SORTIE | CHECK | Distinguer les entrées et sorties de stock. |
| STOCK_HISTORIQUE | stock_apres_mouvement >= 0 | CHECK | Garantir l'historique cohérent. |

---

## 5. Résumé

Les contraintes simples seront mises en place avec :

```text
PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK
```

Les contraintes métier complexes seront mises en place avec :

```text
TRG_STOCK, TRG_HISTORIQUE, TRG_AVIS
```

Cette séparation permet de respecter le cahier des charges tout en gardant une conception claire.
