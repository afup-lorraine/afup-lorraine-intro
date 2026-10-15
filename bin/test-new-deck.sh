#!/usr/bin/env bash
# Tests du générateur bin/new-deck.sh, exécutés dans un bac à sable temporaire.
set -uo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT
failure_count=0

cp -r "$repository_root/bin" "$repository_root/template" "$sandbox/"
ln -s "$repository_root/images" "$sandbox/images"
ln -s "$repository_root/shared" "$sandbox/shared"

# Deck précédent balisé, avec une image propre au mois.
mkdir -p "$sandbox/2000-01-opening/assets/images"
cp "$repository_root/images/php.png" "$sandbox/2000-01-opening/assets/images/actu-test.png"
printf '<!-- actu:start -->\n<section><img src="./assets/images/actu-test.png" alt=""></section>\n<!-- actu:end -->\n' \
    > "$sandbox/2000-01-opening/index.html"

generate() { # generate <réponses séparées par des retours ligne>
    printf '%s\n' "$@" | "$sandbox/bin/new-deck.sh" > /dev/null 2>&1
}

check() { # check <description> <commande...>
    if "${@:2}"; then echo "  ok   $1"; else echo "  ÉCHEC $1"; failure_count=$((failure_count + 1)); fi
}

contains() { grep -qF -- "$2" "$sandbox/$1/index.html"; }

epitech_number=0
for logo_path in "$repository_root"/images/sponsors/*; do
    epitech_number=$((epitech_number + 1))
    [[ "${logo_path##*/}" == logo-epitech.png ]] && break
done

echo "Deck complet avec reprise des actus"
generate 2030-10 "Jeudi 15 octobre 2030" 'Jean & "Toto" <x>|y\z' "https://meetup.com/e/1?a=1&b=2" EPITECH "$epitech_number" o
check "mois en français" contains 2030-10-opening "Meetup AFUP<br>Octobre 2030"
check "date" contains 2030-10-opening "<p>Jeudi 15 octobre 2030</p>"
check "présentateur échappé" contains 2030-10-opening 'Jean &amp; &quot;Toto&quot; &lt;x&gt;|y\z'
check "lien meetup échappé" contains 2030-10-opening 'href="https://meetup.com/e/1?a=1&amp;b=2"'
check "logo de l'hôte" contains 2030-10-opening 'src="../images/sponsors/logo-epitech.png" alt="EPITECH"'
check "bloc actu repris" contains 2030-10-opening 'src="./assets/images/actu-test.png"'
check "image du bloc copiée" test -f "$sandbox/2030-10-opening/assets/images/actu-test.png"
check "aucune variable restante" bash -c "! grep -q '{{' '$sandbox/2030-10-opening/index.html'"

echo "Champs optionnels vides"
generate 2030-11 "" "" "" "" "" ""
check "date retirée" bash -c "! grep -A1 'title-slide' '$sandbox/2030-11-opening/index.html' | grep -q '<p>'"
check "lignes hôte retirées" bash -c "! grep -qE 'Merci à|sponsors/' '$sandbox/2030-11-opening/index.html'"
check "ligne présentateur retirée" bash -c "! grep -q 'par <strong>' '$sandbox/2030-11-opening/index.html'"
check "actus par défaut" contains 2030-11-opening "<h1>Actu AFUP</h1>"
check "aucune variable restante" bash -c "! grep -q '{{' '$sandbox/2030-11-opening/index.html'"

echo "Logo hors liste"
generate 2030-12 "" "" "" Hôte 999 ""
check "logo ignoré, hôte conservé" bash -c "grep -q 'Merci à Hôte' '$sandbox/2030-12-opening/index.html' && ! grep -q 'sponsors/' '$sandbox/2030-12-opening/index.html'"

echo "Refus"
check "mois existant refusé" bash -c "! printf '2030-10\n' | '$sandbox/bin/new-deck.sh' 2>/dev/null"
check "mois invalide refusé" bash -c "! printf '2030-13\n' | '$sandbox/bin/new-deck.sh' 2>/dev/null"
check "aucun dossier créé pour un mois invalide" test ! -e "$sandbox/2030-13-opening"

echo "Mois par défaut"
generate "" "" "" "" "" "" ""
check "mois suivant créé" test -d "$sandbox/$(date -d "$(date +%Y-%m-01) +1 month" +%Y-%m)-opening"

if ((failure_count > 0)); then echo "$failure_count test(s) en échec."; exit 1; fi
echo "Tous les tests passent."
