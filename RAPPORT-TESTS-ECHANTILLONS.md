# Recette du module Échantillons — 1.13.0-rc1

2 novembre 2026. Tests locaux sur données et comptes synthétiques, avec PHP 8.4.27, PDO MySQL, MariaDB 10.11.19 et Chromium. Aucun accès FTP/OVH réel, commande réelle, transport réel ou message réel.

## Vérifications passées

- Syntaxe des 32 fichiers PHP de l’API et des 12 scripts JavaScript ; identité du code public final avec la copie testée.
- Demande multiligne, instantané catalogue, taille, couleur, logo, quantité, adresse, devise, propriétaire et budget.
- Coûts prévisionnels incomplets : approbation refusée. Refus puis révision : anciennes lignes inactives conservées, décision tracée et nouvelle demande remise à valider.
- Ordre obligatoire des deux validations ; tentative de validation direction directe refusée ; membre sans droits bloqué sur validation et affectation ; attribution puis retrait d’un droit effectifs.
- Lots : somme des variantes supérieure au comptage parent refusée ; cohérence référence/unité/taille/couleur contrôlée.
- Affectation multiligne et multi-dépôts : toutes les lignes doivent être couvertes ; affectation incomplète annulée intégralement ; une même ligne peut être répartie sur plusieurs dépôts.
- Affectation : réservation du parent et du lot sans modification du physique ; réaffectation invalide annulée intégralement, avec réservation précédente conservée.
- Protection du registre de stock historique : effacement d’une réservation, comptage sous les lots actifs et relabellisation du produit refusés.
- Concurrence réelle : deux clients et deux sessions distinctes, requêtes simultanées sur plusieurs processus PHP, deux demandes de 2 unités pour un stock de 3. Une réussite et un refus pour insuffisance, aucun dépassement. Annulation ultérieure : réservations libérées, physique conservé.
- Autre réservation existante : l’affectation puis l’annulation d’un échantillon ne l’effacent pas.
- Préparation confirmée avant expédition ; expédition consommant physique et réservation une fois ; répétition obsolète refusée. Annulation après expédition refusée, sans réinjection du stock.
- Réception : portail Alpha autorisé et événement lié à son compte, sans faux acteur staff ; portail Beta refusé sur la demande d’Alpha. Budgets, coûts et décisions internes absents des données client.
- Chronologie : réception future refusée sans changement ; attribution à une demande non reçue refusée ; relance prévue aujourd’hui non classée comme retard.
- Relance commerciale enregistrée, historique et échéance propres au module, sans écrasement de la prochaine action CRM.
- Rapprochements automatiques : correspondance produit/variante/logo et même client ; proposition affichée sans changer le nombre de conversions.
- Réponse OpenAI simulée avec clés autorisées acceptée ; clé inventée refusée avec maintien des règles. Aucune confirmation commerciale ni valeur de ROI générée par le modèle.
- Origine explicite dans la commande B2B : lien créé automatiquement après déclaration autorisée ; tentative par un membre sans droit commercial refusée et commande non enregistrée partiellement.
- Une seule attribution traitée par commande ; mise à jour concurrente refusée ; part de marge/revenu attribuée modifiable et tracée.
- KPI : 1 envoi coûtant 20 TND et générant une marge attribuée de 40 TND donne un ROI indicatif de 100 %. Attribution réduite à 50 % : ROI 0 %. Une seconde commande sans marge connue bloque le ROI jusqu’à complétude.
- Coût réel inconnu, marge absente ou devises différentes : ROI non calculable, sans supprimer le lien commercial confirmé. Coût global nul : aucun pourcentage infini ou inventé. Une perte reste négative.
- Annulation d’une commande : elle cesse de compter immédiatement, sans supprimer la preuve historique.
- Scénario final de navigation : 3 demandes envoyées, 2 converties, 4 pièces, coût 36 TND et marge variable attribuée 140 TND, soit taux 66,67 % et ROI indicatif 288,89 %. Données entièrement synthétiques.
- Isolation entre sociétés : demandes, lots, commandes, options et attributions de l’autre société absents ou refusés. CSRF invalide refusé.
- Questions échantillons/ROI dans WORKMAN GPT et ouverture des signaux dans le pilotage ; lectures de KPI faites dans un instantané cohérent.
- Parcours navigateur complet : création, validations, affectation, contrôle, expédition, confirmation client, relance, mise à jour de lot, origine B2B, saisie des données économiques et dashboard responsive, sans erreur JavaScript.
- Changement de client/devise : coûts anciens effacés plutôt que convertis ; échec réseau simulé : ancien client rétabli, devise cohérente et formulaire préservé.
- Historique lisible avec libellés métier, corrections de coûts et acteurs ; absence de JSON technique brut dans le parcours. Captures inspectées visuellement.
- Migration 12 : première application sans changement d’aucune ligne des tables préexistantes, y compris le stock partagé. Deuxième application conservant aussi demandes, lignes, lots, réservations, mouvements, décisions, réceptions, coûts et attributions déjà saisis.
- Intégrité ZIP, empreintes et reconstitution exacte du code final depuis les bases 1.9, 1.10, 1.11 ou 1.12 avec le paquet cumulatif.

## Limites

L’IA réelle n’a pas été appelée : seul le transport fournisseur de la copie de test est remplacé par des réponses synthétiques. Aucun simulateur ni secret de test n’est livré. Les heuristiques de rapprochement indiquent une correspondance à vérifier, pas une causalité prouvée.

Les KPI utilisent les données économiques déclarées, sans connexion comptable ou transporteur. Le ROI est un indicateur commercial par devise et dépend de coûts et marges complets. Le taux toutes dates peut évoluer pour les demandes récemment envoyées.

Aucune nouvelle recette fournisseur de Sourcing, Microsoft, Hunter, Apify ou du moteur PDF n’a été faite dans cette itération. Les parcours existants utilisés par les échantillons ont été exercés localement, notamment CRM/catalogue, commandes B2B, portail et registre de stock.

La version PHP de votre hébergement, son schéma réel et ses personnalisations restent à vérifier sur une copie. La sauvegarde privée existante découvre les tables `wm_*` dynamiquement ; tester la restauration complète sur une base distincte. En cas de retour arrière du code, les mouvements et réservations du stock partagé doivent être conservés et réconciliés avant de rouvrir l’écriture avec une ancienne version.
