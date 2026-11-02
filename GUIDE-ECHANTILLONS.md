# WORKMAN LEADS AI — gestion des échantillons

**Version 1.13.0-rc1 — 2 novembre 2026.** Mise à jour cumulative depuis les versions 1.9 à 1.12 préparées dans ce fil. Le nouveau module est distinct des devis IA, du portail et des dashboards existants. Rien n’a été déployé sur OVH.

## Parcours disponible

Menu « Échantillons », ou bouton « Demander un échantillon » dans une fiche CRM :

**Demande → validation commerciale → validation direction → affectation/préparation → contrôle final → expédition → réception client → relance commerciale → clôture facultative.**

Une demande peut contenir 1 à 20 lignes, avec produit du catalogue, taille, couleur, description du logo/personnalisation, quantité, unité et coût prévisionnel unitaire HT. Elle conserve le client, la destination, le responsable commercial, la devise, le budget transport, les coûts réels, le transporteur, la référence de remise, les dates d’envoi et de réception et le suivi commercial.

Les produits, références et unités sont copiés dans la demande pour conserver leur état historique. La devise du client est figée sur cette demande. Aucun montant n’est converti automatiquement.

### 1. Créer et faire valider

1. Choisir le client. La recherche permet de retrouver une entreprise au-delà de la liste initiale.
2. Renseigner produits, variantes, logos, quantités, destination et responsable.
3. Compléter tous les coûts unitaires prévisionnels et le budget transport avant l’approbation commerciale. Un coût nul doit être saisi explicitement ; un champ vide signifie inconnu.
4. Le validateur commercial approuve ou refuse avec un commentaire.
5. Après accord commercial, le validateur direction approuve ou refuse avec un commentaire.

Les étapes ne peuvent pas être sautées. Après validation, les lignes et le budget ne sont plus modifiables par le formulaire de demande. En cas de changement, annuler avant l’envoi et créer une nouvelle demande. Une demande refusée peut être révisée puis resoumise par son créateur, son responsable ou un validateur commercial. Les anciennes lignes et décisions sont conservées ; les validations sont remises à zéro pour la nouvelle révision.

### 2. Affecter le stock par taille et couleur

Le module réutilise les comptages du registre de stock ajouté en 1.12. Il ajoute des **lots par taille et couleur**, rattachés à ces comptages.

1. Vérifier le comptage parent dans Tableaux de bord → Production → Registre de stock : référence, dépôt, unité, quantité physique et réservée.
2. Dans Échantillons → Lots par taille/couleur, créer les variantes réellement comptées, avec date et source.
3. La somme des lots actifs ne doit pas dépasser le stock physique parent. Pour un réapprovisionnement, mettre d’abord à jour le comptage parent, puis les lots. Pour réduire le physique parent, corriger d’abord les lots si nécessaire, sans passer sous une réservation en cours.
4. Affecter chaque ligne validée à un ou plusieurs lots. Référence, unité, taille et couleur doivent correspondre. Les quantités doivent être couvertes exactement.

L’affectation réserve le stock parent et le lot, sans diminuer le physique. Les réservations faites pour d’autres besoins sont conservées. Une réaffectation remplace les réservations de la demande dans une même transaction : si la nouvelle affectation échoue, les anciennes restent en place.

Une annulation avant expédition libère uniquement les réservations de cette demande. Elle ne modifie pas le physique. L’expédition consomme le physique et libère la réservation simultanément, une seule fois. Les mouvements, comptages et affectations historiques sont journalisés.

Le registre de stock existant empêche d’effacer une réservation d’échantillon par une saisie manuelle et protège la couverture des lots. L’identité d’un stock possédant des lots actifs ne peut pas être changée arbitrairement. Un lot réservé ne peut pas être archivé, relabellisé ou réduit sous sa réservation.

### 3. Préparer et expédier

Après affectation, confirmer explicitement le contrôle des produits, tailles, couleurs, logos et quantités. Une réaffectation ultérieure remet ce contrôle à faire.

Enregistrer ensuite la remise effective : date réelle, transporteur/mode de remise, référence de transport ou de bon de remise et commentaire. Les dates futures ou antérieures à la validation direction sont refusées. Aucun service transporteur n’est appelé : ce module enregistre l’expédition réelle réalisée par votre équipe.

Renseigner les coûts réels HT de l’ensemble des échantillons et du transport s’ils sont connus. Sinon, les laisser vides puis les compléter après réception des justificatifs. Le budget approuvé n’est jamais assimilé automatiquement à une dépense réelle.

Une demande déjà expédiée ne peut pas être annulée pour réinjecter fictivement le stock. Les corrections de comptage et retours physiques éventuels relèvent d’une opération de stock réelle et justifiée.

### 4. Confirmer la réception et relancer

Deux moyens :

- **Équipe** : déclarer le réceptionnaire, la date réelle et la preuve/confirmation obtenue.
- **Portail client** : le contact authentifié ouvre « Échantillons » puis confirme sa réception. Le compte et la date technique sont enregistrés. Les autres clients ne voient pas cette demande.

La réception doit suivre la date d’envoi et ne peut pas être future. Le portail n’expose ni coûts internes, ni budgets, ni validations commerciales. Les demandes n’y apparaissent qu’après expédition.

Une relance est planifiée à réception : par défaut **trois jours calendaires** après la date reçue ; l’équipe peut préciser une autre date. Cette échéance est propre au module et ne remplace pas la prochaine action CRM existante. Les retards apparaissent aussi dans INSIGHT, hors clients opposés à la prospection.

Enregistrer ensuite la relance réellement effectuée, son compte rendu et éventuellement une prochaine échéance, puis clôturer le suivi si nécessaire. Une opposition bloque l’enregistrement d’une relance commerciale ; la clôture du dossier reste possible. Aucun email n’est envoyé automatiquement.

## Droits et traçabilité

Les administrateurs disposent des trois droits. Dans « Droits de validation », ils peuvent attribuer séparément :

- Validation commerciale ;
- Validation direction ;
- Stock et expédition.

Les autres membres peuvent créer et suivre des demandes, mais ne peuvent pas approuver ni réserver/expédier sans le droit correspondant. Les deux décisions restent distinctes et tracées ; l’application permet qu’un administrateur assure les deux étapes, et n’impose donc pas deux personnes différentes.

Les coûts réels peuvent être complétés par la logistique ou un compte autorisé Finance. Les confirmations/rejets d’attribution de commandes et la déclaration d’une origine échantillon sur une commande nécessitent la validation commerciale. Le retrait d’un droit est contrôlé aux opérations suivantes.

Les changements simultanés sont détectés par version. Le journal de chaque demande conserve décisions, révisions, mouvements, expédition, réception, corrections économiques et relances avec acteur et date. Les anciennes lignes et attributions ne sont pas supprimées. Une entreprise liée à une demande ne peut plus être supprimée ou fusionnée par les anciens parcours.

## Commandes, rapprochement automatique et IA

Les commandes B2B précédentes n’avaient pas de lignes produits ni de données de marge. Dans « Données et origine des commandes », compléter si disponibles :

- Date effective de commande ;
- Produits, tailles, couleurs, logos et quantités ;
- Devise, montant net HT et coûts variables HT ;
- Source/justification des informations.

Les coûts variables renseignés pour la marge de commande doivent correspondre à cette commande, sans y déduire une seconde fois les coûts des échantillons. Il ne s’agit pas d’une comptabilité, d’une facturation ou d’un suivi bancaire automatique.

### Origine explicitement connue

Dans le formulaire de commande B2B, un validateur commercial peut sélectionner l’échantillon reçu à son origine, indiquer la date effective et confirmer la déclaration. Le lien est alors créé automatiquement avec cette preuve. Les coûts et produits peuvent être complétés ensuite depuis Échantillons.

### Origine à examiner

Les propositions sont recalculées à l’ouverture/actualisation du module, sans configuration de cron. Elles retiennent le même client, une commande non annulée postérieure à la réception et située dans les **90 jours** suivants, puis les références ou variantes correspondantes.

- Produit, taille, couleur et logo correspondants : score de correspondance 90/100 ;
- Produit, taille et couleur, logo différent : 75/100 ;
- Référence d’échantillon citée dans le libellé de commande : 85/100 ;
- Référence produit citée, variante non prouvée : 40/100.

Le meilleur rapprochement par commande est proposé, avec les alternatives disponibles. Ces scores sont des règles de correspondance, pas des probabilités causales. Les déclarations explicites et décisions humaines restent distinctes des suggestions.

« Prioriser avec l’IA » réutilise votre clé/modèle OpenAI existants pour classer ces propositions autorisées. Le modèle ne peut ni inventer un identifiant, ni confirmer une conversion, ni modifier les KPI. Une réponse invalide ou un service indisponible conserve le classement par règles. Limite locale : 20 demandes IA par société/jour. Sans clé, les propositions calculées restent disponibles.

Le commercial confirme ou rejette le lien avec justification. Une confirmation exige une réception, le même client et une chronologie cohérente. Une attribution explicite peut être faite au-delà de la fenêtre des propositions. Une commande ne possède qu’un seul lien traité, ce qui évite les doubles comptes ; un échantillonnage peut générer plusieurs commandes. Les rejets ne sont pas reproposés automatiquement ; ils restent révisables dans la liste des décisions.

Une part de revenu/marge attribuée, de 0,01 à 100 %, peut être précisée. La modification du lien est tracée et contrôlée par version. Annuler ensuite une commande l’exclut immédiatement des KPI, en conservant le lien historique.

WORKMAN GPT comprend également les questions sur les échantillons et leur ROI. Les relances d’échantillons reçus et en retard sont intégrées à INSIGHT et à ses plans d’action.

## KPI et calculs

Les KPI portent sur la société entière, toutes dates. La recherche filtre seulement la liste des demandes.

- **Envois** : nombre de demandes effectivement expédiées. Les quantités de produits sont aussi affichées, regroupées par unité.
- **Transformation** : demandes expédiées avec au moins une commande confirmée non annulée / demandes expédiées. Une proposition IA ne compte jamais comme conversion.
- **Coût global réel HT**, par devise : coût réel des échantillons + coût réel transport des demandes expédiées. Si un coût manque, le total global est non calculable ; le sous-total des envois dont les coûts sont complets reste affiché.
- **Marge variable HT attribuée** : (montant net HT de la commande − coûts variables HT) × part attribuée, pour les liens confirmés, hors commandes annulées. Chaque commande ne compte qu’une fois.
- **ROI indicatif**, par devise : (marge variable attribuée − coût global réel des envois) / coût global réel × 100.

Les demandes expédiées non converties restent dans les coûts du ROI. Un coût global nul, un coût incomplet, une marge inconnue ou des devises non comparables donnent un ROI non calculable. Une perte reste négative. Aucun taux de change n’est supposé. Le calcul repose sur les données économiques déclarées des commandes, sans assimiler revenu commandé et encaissement.

La période d’observation peut être courte pour les envois récents : ce taux toutes dates ne constitue pas un taux de conversion final par cohorte. Les ratios et graphiques ne prouvent pas une causalité commerciale à eux seuls.

## Limites d’affichage

200 demandes et 200 commandes récentes dans les listes ; 200 échantillonnages reçus et 200 commandes pour les propositions ; 50 propositions ; 500 lots et 1 000 comptages parents ; 200 événements par demande affichés (les événements plus anciens restent en base). Les KPI agrègent toutes les demandes expédiées, indépendamment de ces plafonds.

Une demande correspond à une expédition complète. Plusieurs lots sont possibles pour une même ligne, mais toutes ses quantités doivent être préparées avant l’envoi.

## Mise à jour FTP et SQL

1. Sauvegarder tous les fichiers, la configuration privée et **toute la base**, puis vérifier la restauration sur une base distincte.
2. Recetter sur une copie isolée, avec cron et services externes désactivés. Aucun export de votre base réelle ni accès FTP n’a été utilisé dans ce travail.
3. Comparer les fichiers en ligne aux empreintes du manifeste 1.9/1.10/1.11/1.12. Fusionner vos personnalisations avant remplacement ; le paquet ne les fusionne pas automatiquement.
4. Exécuter `sql/00-controle-avant-migration.sql` en lecture seule dans la bonne base. Vérifier la présence des tables historiques. Si les tables d’une migration existent déjà, comparer aussi types, valeurs par défaut, clés et index : CREATE TABLE IF NOT EXISTS ne corrige pas une structure incompatible.
5. Prévoir une courte maintenance : suspendre accès, mouvements de stock, expéditions et cron pendant la bascule.
6. Appliquer uniquement les migrations manquantes, dans l’ordre :
   - Depuis Sourcing **1.9** : **09, 10, 11, 12** ;
   - Depuis CRM **1.10** : **10, 11, 12** ;
   - Depuis Devis IA/Portail **1.11** : **11, 12** ;
   - Depuis Pilotage **1.12** : **12 uniquement**.
7. Transférer seulement le contenu de `ftp/www/` dans votre dossier public existant, aux mêmes chemins, sans option de suppression des fichiers distants. Ne pas mettre SQL ou les guides dans la racine publique.
8. Conserver `private/config.php`, `app_key`, secrets, moteur PDF, sauvegardes, `.htaccess`, `.ovhconfig` et tous les fichiers absents du paquet. Aucune nouvelle option privée n’est obligatoire. Le cache des fichiers modifiés utilise la version 1.13.0-rc1, y compris le portail client.
9. Réactualiser le navigateur et si nécessaire OPcache selon votre procédure OVH. Tester une demande synthétique et les anciens CRM, Sourcing, devis, portail et dashboards avant réouverture.

**Ne pas importer `01-production.sql` ni réexécuter 02 à 08 pour cette mise à jour.** Les migrations fournies sont additives. La migration 12 ne réserve, ne libère et ne consomme aucun stock ; seuls les actes explicites du workflow produisent ensuite ces mouvements.

Les prérequis PHP/PDO/MySQL et PDF de votre application restent applicables. Aucune nouvelle bibliothèque ou dépendance JavaScript distante n’est nécessaire.

## Retour arrière et stock partagé

Suspendre les accès et les opérations de stock. Sauvegarder l’état courant, puis restaurer uniquement les fichiers de code de la version précédente si nécessaire.

**Conserver les tables 09 à 12 et tous les journaux. Ne pas restaurer une ancienne quantité de stock pour annuler un envoi déjà réalisé.** Les expéditions ont modifié le stock partagé pour refléter une sortie réelle ; les réservations encore ouvertes restent également inscrites dans le parent.

Avant de remettre une ancienne version en écriture sur le stock, traiter/libérer correctement les demandes non expédiées depuis le module, ou maintenir le stock en lecture seule jusqu’à réconciliation des réservations. Une ancienne version ne connaît pas le détail des lots et ne possède pas les nouvelles protections. Les mouvements réalisés et preuves de réception restent à conserver.

Ne pas restaurer une sauvegarde ancienne par-dessus une base ayant reçu des saisies. Toute restauration complète nécessite d’abord de préserver et réconcilier les données nouvelles.

## Recette

Voir `RAPPORT-TESTS-ECHANTILLONS.md`. Les tests sont locaux et synthétiques ; les réponses OpenAI sont simulées. Aucun déploiement OVH, commande réelle, transport ou relance réelle n’a été effectué. L’appel OpenAI réel et votre hébergement restent à vérifier sur une copie avant usage commercial.
