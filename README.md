# WORKMAN LEADS AI — mise à jour 1.13.0-rc1

Paquet cumulatif de mise à jour FTP et SQL pour une installation WORKMAN existante, préparé depuis Sourcing 1.9 et les extensions CRM, Devis IA, Portail B2B, Pilotage/GPT/INSIGHT et Échantillons.

## Télécharger

Utiliser **Code → Download ZIP** dans GitHub, puis décompresser l’archive. Les fichiers applicatifs sont dans `ftp/www/`, les migrations dans `sql/`.

## Installer

Lire **[GUIDE-ECHANTILLONS.md](GUIDE-ECHANTILLONS.md)** avant toute opération. Sauvegarder tous les fichiers et toute la base, comparer les personnalisations avec le manifeste et recetter sur une copie.

- Version 1.9 : migrations 09, 10, 11, 12.
- Version 1.10 : migrations 10, 11, 12.
- Version 1.11 : migrations 11, 12.
- Version 1.12 : migration 12 uniquement.

Ne pas réinstaller la base ; ne pas importer `01-production.sql` pour cette mise à jour. Garder la configuration privée, la clé `app_key`, les secrets, sauvegardes et moteur PDF existants. Seuls les fichiers applicatifs ciblés sont inclus.

Les mouvements d’échantillons agissent ensuite sur le stock partagé : consulter les instructions de retour arrière avant de revenir à une ancienne version.

## Vérifications

Voir **[RAPPORT-TESTS-ECHANTILLONS.md](RAPPORT-TESTS-ECHANTILLONS.md)**. Les tests sont locaux et synthétiques. OpenAI réel et OVH restent à valider. Aucun déploiement OVH n’est effectué par cette publication.

`MANIFESTE.json` décrit les versions et empreintes des fichiers. `SHA256SUMS.txt` permet de vérifier le contenu du paquet (hors ce README de présentation).

Aucune configuration privée ou donnée client réelle n’est incluse.
