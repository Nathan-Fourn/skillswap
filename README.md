# SkillSwap — l'environnement du module

**R3.01 · Développement web · BUT2 apprentis**

Vous n'installez ni PHP, ni MySQL, ni Apache sur votre poste : tout tourne dans
des conteneurs, avec **les mêmes versions pour les douze postes de la salle**.
Le seul prérequis est Docker.

---

## Démarrer

Depuis ce dossier (celui qui contient `docker-compose.yml`) :

```bash
docker compose up -d --build
```

Le `--build` n'est nécessaire qu'au premier lancement et après une modification
du `Dockerfile`. Les fois suivantes, `docker compose up -d` suffit.

Le premier démarrage prend quelques minutes : les images se téléchargent et la
base s'initialise. Ensuite, c'est immédiat.

### Les trois adresses

| Adresse | Ce que vous y trouvez |
|---|---|
| http://localhost:8080 | L'application SkillSwap |
| http://localhost:8081 | Adminer — l'administration de la base |
| `localhost:13306` | MySQL, pour un outil installé sur votre poste |

Sur http://localhost:8080 vous devez voir la **page de vérification de
l'environnement**, avec la version de PHP, les extensions et l'état de la base.
Tant qu'elle n'est pas entièrement verte, ne commencez pas le TP : signalez-le.

Dans Adminer : système **MySQL**, serveur **`db`**, utilisateur **`skillswap`**,
mot de passe **`skillswap`**, base **`skillswap`**.

---

## Où mettre vos fichiers

```
skillswap/
├── docker-compose.yml
├── docker/php/Dockerfile
├── sql/            ← le schéma et le jeu de données, joués au 1er démarrage
├── public/         ← LA RACINE WEB. Seul dossier visible du navigateur
├── inc/            ← éléments réutilisables (en-tête, pied de page, fonctions)
├── data/           ← données figées de la séance 1
└── cli/            ← les scripts en ligne de commande
```

`public/` est **le seul dossier exposé**. Une page n'est joignable que si elle
est là :

| Fichier | Adresse |
|---|---|
| `public/index.php` | http://localhost:8080/ |
| `public/fiche.php` | http://localhost:8080/fiche.php |

Il n'y a **pas** de `/public/` dans l'adresse : Apache sert déjà ce dossier.

`cli/`, `inc/`, `data/` et `sql/` sont à côté, donc hors d'atteinte d'un
navigateur. C'est voulu : personne ne peut télécharger vos données en devinant
leur adresse. C'est aussi l'organisation que Symfony imposera en séance 6.

---

## Exécuter un script en ligne de commande

**Toujours dans le conteneur**, jamais avec le PHP de votre poste :

```bash
docker compose exec web php cli/a1_bienvenue.php
```

Ou, si vous en enchaînez plusieurs :

```bash
docker compose exec web bash    # vous êtes maintenant DANS le conteneur
php cli/a1_bienvenue.php
php cli/a2_fiche.php
exit
```

Pourquoi pas le `php` de votre poste : il n'existe pas partout, et quand il
existe ce n'est ni la même version ni les mêmes extensions que chez le voisin.
Comparez vous-même :

```bash
php -v                           # le PHP de VOTRE poste, s'il existe
docker compose exec web php -v   # celui du module : 8.3, identique pour tous
```

---

## Les commandes du quotidien

```bash
docker compose up -d           # démarrer
docker compose ps              # vérifier que les trois services tournent
docker compose logs -f web     # les erreurs PHP en direct — votre meilleur outil
docker compose exec web bash   # ouvrir un terminal dans le conteneur
docker compose stop            # arrêter sans rien perdre
docker compose down            # arrêter et supprimer les conteneurs
```

### Repartir d'une base propre

```bash
docker compose down -v
docker compose up -d
```

`down -v` supprime le volume, donc **toutes les données de la base**, et les
scripts de `sql/` sont rejoués au démarrage suivant. C'est exactement ce qu'on
veut quand la base est dans un état douteux — mais faites-le en connaissance de
cause. Votre code, lui, n'est jamais touché : il est sur votre poste.

---

## Depuis le conteneur, la base s'appelle `db`

C'est l'erreur numéro un de la séance 2.

| D'où vous parlez | Hôte | Port |
|---|---|---|
| Votre code PHP, qui s'exécute **dans** le conteneur | `db` | `3306` |
| Un outil installé sur **votre poste** | `localhost` | `13306` |

Le port 13306 est un port de votre machine que Docker fait suivre vers le 3306
du conteneur. Votre code, lui, est déjà à l'intérieur : il n'en a pas besoin.

---

## Dépannage

| Symptôme | Cause et traitement |
|---|---|
| `port is already allocated` | Un programme occupe 8080, 8081 ou 13306 sur votre poste. Fermez-le, ou signalez-le pour qu'on décale les ports |
| Page blanche, aucun message | Erreur fatale PHP. `docker compose logs -f web` la montre |
| Le code PHP s'affiche **en texte** dans le navigateur | Vous avez ouvert le fichier par un double-clic (adresse en `file://`). Passez par http://localhost:8080 |
| `Could not open input file: cli/xxx.php` | Vous n'êtes pas à la racine du projet, ou le fichier n'est pas dans `cli/` |
| Erreur 404 sur une page qui existe | Le fichier n'est pas dans `public/`, ou son nom diffère — la casse compte |
| `Connection refused` vers la base | Votre code vise `localhost` ou `13306` au lieu de `db` et `3306` |
| Les tables sont absentes d'Adminer | Le volume existait déjà au premier démarrage. `docker compose down -v` puis `up -d` |
| Une modification n'apparaît pas | Cache du navigateur : rechargez avec Ctrl+F5 |

Si rien de tout cela ne correspond, `docker compose logs -f web` puis la
première ligne d'erreur : c'est elle qui compte, pas les suivantes.
