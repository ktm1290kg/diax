#!/usr/bin/env python3
"""Sklapa diax-preview.html: ubacuje sve slike kao base64 u index.html.
Pokretanje: python3 build.py  (iz diax-sajt foldera)"""
import base64, os, sys

CATS = ["gume","kocioni","filteri","ulja","motor","elektrika","klima","izduvni",
        "vesanje","karoserija","osvetljenje","amortizeri","akumulatori","kvacilo",
        "hladjenje","kaisevi","svecice","brisaci","lezajevi","spone","servo",
        "zaptivke","enterijer"]

LOGOS = ["luk","sachs","mahle","valeo","bosch","skf","brembo","trw","osram","continental"]

def b64(path, mime='image/jpeg'):
    with open(path,'rb') as f:
        return f'data:{mime};base64,'+base64.b64encode(f.read()).decode()

html = open('template.html').read()
html = html.replace('__HERO__', b64('assets/hero.jpg'))
html = html.replace('__STORE__', b64('assets/store.jpg'))
html = html.replace('__STOREWIDE__', b64('assets/store-wide.jpg'))
missing = []
for c in CATS:
    p = f'assets/cat-{c}.jpg'
    if os.path.exists(p):
        html = html.replace(f'__CAT_{c}__', b64(p))
    else:
        missing.append(c)
for l in LOGOS:
    p = f'assets/logos/{l}.svg'
    if os.path.exists(p):
        html = html.replace(f'__LOGO_{l}__', b64(p, 'image/svg+xml'))
    else:
        missing.append('logo:'+l)
open('index.html','w').write(html)
open('diax-preview.html','w').write(html)
print('OK', len(html), 'bytes; missing:', missing or 'none')
sys.exit(1 if missing else 0)
