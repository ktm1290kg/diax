#!/bin/bash
# Kaci sajt na Andrejev hosting preko FTP-a.
# Lozinka se cita iz .env fajla (FTP_PASS) — nikad je ne upisuj ovde.
set -euo pipefail
cd "$(dirname "$0")"
# citaj .env bukvalno (radi i ako lozinka ima razmake/specijalne znakove)
FTP_HOST=$(grep '^FTP_HOST=' .env | cut -d= -f2-)
FTP_USER=$(grep '^FTP_USER=' .env | cut -d= -f2-)
FTP_PASS=$(grep '^FTP_PASS=' .env | cut -d= -f2-)

if [ "$FTP_PASS" = "OVDE_NALEPI_LOZINKU" ]; then
  echo "GRESKA: upisi pravu lozinku u .env fajl (red FTP_PASS=...)"; exit 1
fi

URL="ftp://$FTP_HOST/"
SSL="--ssl-reqd"

echo "== Proba FTPS (sifrovana veza)..."
if ! LIST=$(curl -s --connect-timeout 15 $SSL --user "$FTP_USER:$FTP_PASS" "$URL" 2>&1); then
  echo "   FTPS ne radi, prelazim na obican FTP (nesifrovano)."
  SSL=""
  LIST=$(curl -s --connect-timeout 15 --user "$FTP_USER:$FTP_PASS" "$URL")
fi
echo "== Sadrzaj pocetnog foldera:"
echo "$LIST"

# Nadji web root
DIR=""
for d in public_html www htdocs httpdocs web; do
  if echo "$LIST" | grep -qw "$d"; then DIR="$d/"; break; fi
done
echo "== Kacim index.html u: /$DIR"
curl -s $SSL --user "$FTP_USER:$FTP_PASS" -T index.html "$URL$DIR" && echo "== OK: index.html okacen."
