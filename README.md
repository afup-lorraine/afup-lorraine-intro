# AFUP Lorraine — slides d'ouverture des meetups

Les slides d'introduction présentées en début de chaque meetup mensuel de l'antenne AFUP Lorraine, réalisées avec [reveal.js](https://revealjs.com/). Le dépôt est statique : pas de build ni de dépendances npm.

Prérequis : `bash`, `make`, `python3` (pour `make serve`) et `shellcheck` (pour `make test`).

## Préparer le meetup du mois

```bash
make new
```

Le script pose les questions suivantes ; laisser une réponse vide retire la ligne correspondante du deck :

| Question | Utilisation |
|---|---|
| Mois (`AAAA-MM`, par défaut le mois suivant) | nom du dossier `AAAA-MM-opening/` et titre |
| Date du meetup | slide de titre |
| Présentateur | slide « Aujourd'hui ! » |
| Lien meetup | slide de fin |
| Hôte / sponsor du lieu | slide « Et pour finir » |
| Logo de l'hôte (numéro dans la liste de `images/sponsors/`) | slide « Et pour finir » |
| Reprendre les actus du deck précédent (o/N) | copie le bloc d'actus du dernier deck, avec ses images |

Il reste ensuite à compléter `AAAA-MM-opening/index.html` :

1. le titre du talk (« À compléter ») ;
2. les slides d'actualité, entre `<!-- actu:start -->` et `<!-- actu:end -->` ;
3. les images propres au mois, à déposer dans `AAAA-MM-opening/assets/images/`.

Pour présenter :

```bash
make serve    # puis ouvrir http://localhost:8000/AAAA-MM-opening/
```

## Structure du dépôt

```
AAAA-MM-opening/     decks actifs : index.html + assets/images/ propres au mois
archives/            decks antérieurs à août 2026, figés (reveal.js 3 embarqué)
images/              images communes (logos, sponsors…), partagées entre les decks
shared/reveal/       reveal.js 6 vendorisé (voir shared/reveal/VERSION)
shared/theme/        thème AFUP (afup.css) et polices
template/index.html  modèle utilisé par `make new`
bin/                 générateur (new-deck.sh) et ses tests (test-new-deck.sh)
```

Les slides qui reviennent chaque mois (AFUP, antenne, « Nous aider », Lorraine Tech Hub) se modifient dans `template/index.html` ; les decks déjà générés ne sont pas mis à jour.

## Commandes

| Commande | Rôle |
|---|---|
| `make new` | crée le deck d'un nouveau mois |
| `make serve` | sert le dépôt en HTTP (port 8000, `make serve PORT=9000` pour changer) |
| `make test` | shellcheck + scénarios du générateur |

`listing-slides.md` référence les slides des intervenants des AFUP Day.
