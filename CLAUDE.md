# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Vue d'ensemble

Slides d'introduction ("opening") des meetups mensuels de l'antenne AFUP Lorraine, en [reveal.js](https://revealjs.com/). Dépôt statique : ni build, ni bundler, ni `package.json`. L'usage côté organisateur est décrit dans `README.md`.

## Commandes

```bash
make new     # génère AAAA-MM-opening/ depuis template/index.html (questions sur l'entrée standard)
make serve   # python3 -m http.server à la racine, port 8000 (PORT=…)
make test    # shellcheck bin/*.sh + bin/test-new-deck.sh (bac à sable mktemp, ne touche pas au dépôt)
```

`make test` doit passer après toute modification de `bin/` ou de `template/index.html`.

## Architecture

- `AAAA-MM-opening/` (racine) : decks actifs. Ne contiennent que `index.html` et `assets/images/` (images propres au mois). Ils pointent vers `../shared/` et `../images/`.
- `shared/reveal/` : reveal.js 6.0.2 vendorisé (`reveal.js`, `reveal.css`, `reset.css`), provenance dans `shared/reveal/VERSION`. Pas de plugin (highlight volontairement exclu).
- `shared/theme/afup.css` : thème unique (polices Roboto Condensed / Belgrano dans `shared/theme/fonts/`, logo de fond `images/logo.png`). Classes utilitaires : `title-slide`, `slide-small`, `centered-logo`, `sponsor-logos` (logos côte à côte).
- `images/` : images communes ; logos des hôtes dans `images/sponsors/` (proposés par `make new`).
- `template/index.html` : modèle. Variables `{{MONTH_LABEL}}`, `{{DATE_LABEL}}`, `{{SPEAKER}}`, `{{HOST_NAME}}`, `{{HOST_LOGO}}`, `{{MEETUP_URL}}` ; une variable vide fait supprimer **toute sa ligne** par le générateur, donc garder chaque variable optionnelle seule sur sa ligne (avec les éléments qui n'ont pas de sens sans elle).
- Bloc d'actualités délimité par `<!-- actu:start -->` / `<!-- actu:end -->` : `make new` peut le recopier depuis le dernier deck, avec les images `assets/images/…` qu'il référence. Conserver ces marqueurs dans chaque deck.
- `archives/` : decks à l’ancien format (jusqu’à 2026-09 inclus), figés, avec leur propre reveal.js 3 embarqué ; chemins `../../images/`. Ne pas les modifier ni les migrer.

## Conventions

- Une `<section>` par écran, contenu en français.
- Images des decks actifs : chemins relatifs `assets/images/…` (propres au mois) ou `../images/…` (communes) ; jamais `../AAAA-MM-opening/…` ni de ressource distante (tout est vendorisé).
- Qualité HTML attendue (IDEA / Sonar) : `lang="fr"`, `alt` sur chaque `<img>`, pas de style inline (ajouter une classe dans `afup.css`), pas d'`<img>` directement dans une liste, `&amp;` pour `&`. `sonar-project.properties` exclut `archives/**` et `shared/reveal/**`.
- Les fichiers `*:Zone.Identifier` (métadonnées Windows) sont ignorés par `.gitignore`.
