#!/usr/bin/env bash
# Génère le deck d'ouverture d'un nouveau mois à partir de template/index.html.
# Les réponses sont lues sur l'entrée standard : utilisable en interactif comme en test (pipe).
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly repository_root
readonly french_months=(Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre)

ask() { # ask <question> [valeur par défaut]
    local answer
    read -r -p "$1${2:+ [$2]} : " answer || true
    printf '%s' "${answer:-${2:-}}"
}

html_escape() {
    printf '%s' "$1" | sed -e 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'
}

sed_escape() { # échappe une valeur pour la partie remplacement de sed (délimiteur |)
    printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

default_month="$(date -d "$(date +%Y-%m-01) +1 month" +%Y-%m)"
month="$(ask "Mois du meetup (AAAA-MM)" "$default_month")"
[[ "$month" =~ ^20[0-9]{2}-(0[1-9]|1[0-2])$ ]] || { echo "Mois invalide : '$month' (attendu AAAA-MM)" >&2; exit 1; }

deck_directory="$repository_root/$month-opening"
[[ ! -e "$deck_directory" ]] || { echo "Le deck $month-opening existe déjà." >&2; exit 1; }

month_index=$((10#${month#*-} - 1))
month_label="${french_months[$month_index]} ${month%-*}"
date_label="$(ask "Date du meetup (ex. Jeudi 15 octobre 2026, vide pour ignorer)")"
speaker="$(ask "Présentateur")"
meetup_url="$(ask "Lien meetup")"
host_name="$(ask "Hôte / sponsor du lieu")"

host_logo=""
sponsor_logos=()
for logo_path in "$repository_root"/images/sponsors/*; do sponsor_logos+=("${logo_path##*/}"); done
for logo_index in "${!sponsor_logos[@]}"; do
    echo "  $((logo_index + 1))) ${sponsor_logos[$logo_index]}" >&2
done
logo_choice="$(ask "Logo de l'hôte (numéro, vide pour aucun)")"
if [[ "$logo_choice" =~ ^[0-9]+$ ]] && ((logo_choice >= 1 && logo_choice <= ${#sponsor_logos[@]})); then
    host_logo="${sponsor_logos[$((logo_choice - 1))]}"
fi

copy_news="$(ask "Reprendre les slides d'actu du deck précédent ? (o/N)" "N")"

declare -A placeholders=(
    [MONTH_LABEL]="$month_label"
    [DATE_LABEL]="$date_label"
    [SPEAKER]="$speaker"
    [MEETUP_URL]="$meetup_url"
    [HOST_NAME]="$host_name"
    [HOST_LOGO]="$host_logo"
)

# Une variable vide supprime sa ligne, les autres sont remplacées.
sed_arguments=()
for name in "${!placeholders[@]}"; do
    if [[ -z "${placeholders[$name]}" ]]; then
        sed_arguments+=(-e "/{{$name}}/d")
    else
        sed_arguments+=(-e "s|{{$name}}|$(sed_escape "$(html_escape "${placeholders[$name]}")")|g")
    fi
done

mkdir -p "$deck_directory/assets/images"
sed "${sed_arguments[@]}" "$repository_root/template/index.html" > "$deck_directory/index.html"

if [[ "$copy_news" =~ ^[oOyY] ]]; then
    previous_deck="$(find "$repository_root" -maxdepth 1 -type d -name '20[0-9][0-9]-[0-9][0-9]-opening' \
        | sort | awk -v current="$deck_directory" '$0 < current' | tail -n 1)"
    if [[ -n "$previous_deck" ]] && grep -q '<!-- actu:start -->' "$previous_deck/index.html"; then
        news_block="$(mktemp)"
        trap 'rm -f "$news_block"' EXIT
        sed -n '/<!-- actu:start -->/,/<!-- actu:end -->/p' "$previous_deck/index.html" > "$news_block"
        awk -v block_file="$news_block" '
            /<!-- actu:start -->/ { while ((getline line < block_file) > 0) print line; skipping = 1; next }
            /<!-- actu:end -->/   { skipping = 0; next }
            !skipping
        ' "$deck_directory/index.html" > "$deck_directory/index.html.tmp"
        mv "$deck_directory/index.html.tmp" "$deck_directory/index.html"
        # Copie uniquement les images du mois référencées par le bloc repris.
        grep -oE 'src="(\./)?assets/images/[^"]+"' "$news_block" | sed -E 's/^src="(\.\/)?//; s/"$//' \
            | while read -r image_path; do
                cp "$previous_deck/$image_path" "$deck_directory/assets/images/" \
                    || echo "Image introuvable, à vérifier : $image_path" >&2
            done
        echo "Slides d'actu reprises de $(basename "$previous_deck")."
    else
        echo "Aucun deck précédent avec un bloc <!-- actu:start --> : actus par défaut du template conservées." >&2
    fi
fi

echo "Deck créé : $month-opening/index.html"
