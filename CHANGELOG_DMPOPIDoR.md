# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

## 14/05/2025

- Correctiion du lien "voir tous les modules" depuis la page historique
- Alerte de partage ANR masquée si le plan est partagé avec l'ANR dans l'onglet "Partager"
- Correction d'un problème lié au titre du plan lors de l'import RDA

## 07/05/2025

- Amélioration de l'affichage de la création d'un produit de recherche (#12713)
- Découpage de la fonction d'import de plan par interface dans un nouveau service
- Réutilisation du service pour l'import de plan par interface
- Réutilisation du service pour la route d'import de plan de l'API V1
- Réutilisation du service pour la mutation d'import de plan de l'API GraphQL
- Gestion des droits à la création/import de plan pour l'API REST et GraphQL
- Gestion des droits pour la création de produits de recherche de l'API GraphQL
- Suppression de l'option "Supprimer" (dupliquée) dans la section Modules
- Masquage du bouton "Aperçu" dans l'édition d’un module
- Correction du texte du bouton "Voir tous les modules" dans l’historique d’un module

## 05/05/2025

- Amélioration des textes du formulaire des produits de recherche (#12713)
- Correction du problème empêchant les utilisateurs avec un accès Editeur au plan de créer/modifier/supprimer un PR (#13059)
- Correction du lien Historique pour les modules (#12800)
- Améliorations de l'API GraphQL (#13067)

## 29/04/2025

- Correction d'un problème des titres des plans importés (#12546)
- Mise à jour du message de partage à l'ANR (#12939)

## 24/04/2025

- Correction d'un problème affectant l'import de plan au format standard (#12546)
- Améliorations Bootstrap (#10828)
  - Amélioration dans le profil utilisateur (Structures, Language)
  - Ajout d'espaces manquants dans le Tableau de Bord & Export de plan

## 23/04/2025

- Amélioration de l'indicateur de partage d'un plan dans le tableau de bord (#12940)
- Améliorations Bootstrap (#10828)
  - Retrait d'un point en trop dans le menu
  - Amélioration des paramètres de téléchargement du plan
  - Amélioration de l'affichage de la liste lors du choix de l'organisme.

## 09/04/2025

- Création d’une mutation GraphQL pour la création de produits de recherche dans un plan (#12973)
- Possibilité de vider le champ de sélection du projet financeur (#12939)
- Correction du retour en haut de la liste des groupes de recommandations et modification de l’ordonnancement : les groupes sélectionnés apparaissent désormais en haut (#12858)
- Correction affichage recommandations d'un plan classique (#12950)

## 07/04/2025

- [EN ATTENTE] Ajout de scripts de correction des référentiels (#11668)
- Correction de la valeur de nameType suite au changement du référentiel NameTypeValues (#11948, #11949)
- Mise à jour de la visite guidée  (#12937)
- Amélioration de l'indicateur de partage sur dans la liste des plans du Tableau de bord (#12940)

## 31/03/2025

- Retrait de la création du principalInvestigator à la création du plan (#12934)
- Amélioration de l'affichage d'un contributeur avec un rôle constant (#12545)
- Correction du problème de création de lien dans un éditeur présent dans un fenêtre modale (#11060)
- Améliorations suite à la migration Bootstrap (bannière organisme, champ de recherche liste utilisateurs...)

## 26/03/2025

- Ajout du support du role constant dans un template Contributeur (#12545)
- Ajout de "Jeu de données/Dataset" aux PR sans type (#12859)
- Changement de cardinalité pour des contributeurs à cardinalité 1..1 (#12546)

## 24/03/2025

- Corrections Bootstrap 5 (#10828)
- Ajout d'éléments génériques lors du chargement de l'onglet Rédiger (placeholder)

## 17/03/2025

- Erreur GraphQL si ``className``, ``field`` et ``operator`` sont absents ou vide, erreur si value est vide
- Erreur GraphQL si ``and`` ou ``or`` ne sont pas dans filter

## 03/03/2025

- Correction du problème affectant l'import RDA (#12574)
- Ajout du nom manquant du PR dans la liste des rôles affichées dans l'onglet Contributeurs (#12647)
- Simplification de la création de plan, retrait des modèles de l'organisme de l'utilisateur (#12712)

## 28/02/2025

- Retrait des produits de recherche associés aux contributeurs dans l'export JSON (#12670)
- Retrait de l'affichage du module utilisé dans la rédaction (#12691)
- Améliorations de l'interface d'édition des modules (#12372 | #12370)
- Améliorations de l'interface de l'onglet Partager (#12685 | #12563)
- Amélioration de la recherche des groupes de recommandations (#12207)
- Traduction d'un titre de PGD copié (#12315)
- Ajout du libellé "Import de" dans un plan importé (#12696)

## 26/02/2025

- Mise à jour de traductions (#12685 | #12696)
- Suppression des tooltips (#12685)
- Traduction de ``Copy of ...`` par ``Copie de ...` (#12315)

## 25/02/2025

- Un produit de recherche utilisant un module est désormais importé dans un module utilisant la locale du plan (#12503)
- Ajout d'une tâche permettant d'initialiser le dataType des fragments ResearchOutput n'en possédant pas (#12645)
- Correction d'un problème de copie des informations de configuration d'un PR lors d'une copie de plan (#12666)
- Refonte de l'API GraphQL
    - Factorisationn de la construction des requêtes
    - Création dynamique des enums
    - Filtre des produits de recherche

## 21/02/2025

- Modifications de la liste des plans proposés lors de l'import de produit de recherche. (#12646)
- Correction du problème d'affichage des mails lors d'un import RoR/ORCID (#12637)

## 17/02/2025

- Correction du problème de mise à jour des formulaires lors de la sauvegarde d'une question non répondue
- Le message invitant à partager avec l'ANR ne s'affiche désormais que pour les plans structurés.

## 13/02/2025

- Ajout du lien vers la Feuille de route dans le pied de page (#12531)
- Correction du problème d'accès à l'onglet Produits de Recherche (#12564)
- Correction du problème d'accès aux référentiels dans les sous formulaires (#12530)
- Correction d'un problème d'affichage de la valeur "données personelles" dans l'infobox d'un produit de recherche.
- Amélioration de l'onglet Partager (#12563)
- Correction du problème de récupération des noms d'organisme dans l'import RoR (#12554)
- Correction du problème d'accès aux référentiels dans les sous formulaires (#12530)

## 12/02/2025

- Ajout d'un évenement pour recharger les données du produit de recherche après création (#12373)
- Affichage uniquement des plans structurés dans l'import de produit de recherche (#12504)
- Mise à jour interface ANR

## 11/02/2025

- Correction des problèmes d'affichage des référentiels (#12530, #12532, #12533)
- Correction d'affichage de la question données personnelles de l'infobox (#12476)

### 10/02/2025

- Mise à jour de la mutation ``authenticate`` de l'API GraphQL pour générer un token via les identifiants d'un Client API
- Ajout d'une condition selon le type de plan dans ``/app/models/dmpopidor/plan.rb:222`` pour récuper la liste des **fundings**

## 07/02/2025

- Ajout d'un message incitant un utilisateur à partager son plan avec l'ANR (#12349)
- Ajout d'un "badge" indiquant que le plan a été partagé ou non avec un service externe (#12349)
- Refonte des référentiels (#12236) : 
  - Suppression de la table registry_values => Les valeurs sont directement stockées dans la table registries
  - Ajout des champs `data_types` & `category` permettant de choisir de proposer les référentiels disponibles dans un formulaire
- Ajout de `data_type` à la table des Thèmes afin de ne proposer que les thèmes pertinents à un module donné (#12223)

## 06/02/2025

- Ajout d'une alerte indiquant à l'utilisateur de partager son plan avec un financeur lors d'un import Financeur (#12349)

## 03/02/2025

- Modification de la position des notifications (#12452)
- Améliorations de l'API GraphQL
- Ajout d'une barre de défilement au niveau du choix des recommandations

## 31/01/2025

- Annulation : Retrait de la possibilité de copier un plan (#12385)
- Retrait du switch des indiquant la présence de données personnelles dans un produit Logiciel (#12361)

## 29/01/2025

- Retrait de la possibilité de copier un plan (#12385)
- Correction du problème de sélection des produits de recherche lors de l'export de plan (#12416)
- Retrait de l'export des PR Logiciel du format RDA JSON & ajout de messages pour l'utilisateur. Ajout du type de produit de recherche dans la liste des PR lors de l'export (#12416)
- Ajout d'une option de configuration permettant d'améliorer le chargement des traductions dans l'onglet Rédiger et Infos Générales (#12283)

## 28/01/2025

- Amélioration des textes et traductions du formulaire de création de PR (#12361)
- L'abbréviation du PR est désormais importée correctement lors d'un import de plan (#12438)

## 23/01/2025

- Retrait des modules non publiés de l'export des modèles publics (#12239)
- Import de plan : Correction du problème d'import des données dans un produit de recherche utilisant un module (#12238)
- La propriété `datasetId` n'est désormais plus générée lors de la création d'un produit de recherche

## 21/01/2025

- Ajout du support de l'export d'un plan utilisant un module (#12237)
- Retrait des modes d'export PDF/DOCX par question et par section (#12237)
- Ajout de la mise à jour de l'abbreviation/shortName du produit de recherche lors de la mise à jour de la description et de l'infobox du PR (#12352)
- Retrait de la possibilité pour un utilisateur ayant un accès en lecture seule de créer un produit de recherche dans un plan (#12407)

## 20/01/2025

- Changement de l'URL "Voir tout" des actualités (#12344)
- Retrait du context dans le choix d'un module lors de la création d'un produit logiciel 
- Ajout du support de l'import de plan avec un PR Logiciel (#12338)
- Correction du problème d'export des questions autre que la description dans la PR Logiciel(#12354)

## 13/01/2025

- Amélioration de la gestion des modules (#12353)
- Suppression du lien Actualités dans le pied de page & Ajout d'un lien Voir Tout pour les actualités de l'accueil (#12338)
- Retrait de l'export DOCX pour les modèles publics et l'historique des modèles (#12339)
- Correction du problème d'affichage du choix des recommandations (#12351)
- Correction du problème de création de fragments contenant des valeurs vides avec des contraintes d'unicité. ex: Partenaires (#12355)


## 10/01/2025

- Mise à jour API GraphQL, opérateurs AND, OR et NOT, filtre sur plan et grantId
- Désactivation de l'authentification sur les schémas 

## 05/12/2024

- Ajout d'un icone indiquant la présence d'un tooltip sur un libellé (#11798)
- Ajout d'un bouton permettant de réinitialiser la valeur d'un référentiel simple (#12252)
- Retrait de l'onglet d'import d'un produit de recherche lors de la création du premier produit (#12256)
- Ajout des modules aux exports des modèles PDF structurés (#12239)

## 29/11/2024

- Correction du problème d'affichage des groupes de recommandations en fonction de la langue du plan (#12230)

## 28/11/2024

- [PR Logiciel] Ajout de l'affichage des recommandations dans un produit de recherche logiciel (#12193)
- Amélioration de la gestion de la langue des recommandations (#12209)
- Amélioration de la gestion des erreurs dans la formulaire de contact (#12188)

## 26/11/2024

- [PR Logiciel] Correction du problème d'accès à la liste des modules
- [PR Logiciel] Ajout de la classe SoftwareOutreach
- Correction du problème de sélection des recommandations dans un plan classique (#12209)
- Correction du problème de mise à jour des des formulaires après un changement de produit de recherche (#11771)

## 25/11/2024

- Correction du problème d'affichage des recommandations dans la langue du plan dans un plan classique (#12209)
- [PR Logiciel] Un module ne peut plus être supprimé lorsqu'au moins un plan l'utilise (#11093)
- Correction du problème d'enregistrement d'un contributeur après la sauvegarde d'un formulaire (#12136)
- Correction du problème de traduction de la visibilité dans les notifications mail (#10439)
- [PR Logiciel] Correction du problème d'affichage des recommandations dans un produit Logiciel (#12193)

## 21/11/2024

- Correction du dysfonctionnement du moteur des recherche sur les groupes de recommandations (#12198)
- Correction du dysfonctionnement du bouton Voir tout dans la liste des modèles et groupe de recommandations publics (#10325)
- Correction du problème de mise à jour du titre du plan après un import financeur (#12157)

## 20/11/2024

- Ajout de l'export PDF des recommandations (#11836)
- Ajout de la possibilité de réordonner les thèmes (#11922)
- Correction du problème d'affichage de l'exemple dans les champs de listes de chaine de caractères (#12004)
- Correction du problème d'affichage dans les champs de sélection (ex: choix des autorisations d'un plan) (#12172)
- Amélioration des textes et traductions (#12183)
- La propriété 'name' est générée automatiquement à la création d'un plan entité (#12156)
- Correction du problème d'affichage du Responsable du Plan après un import financeur (#12170)
- Correction du problème d'une valeur provenant d'un référentiel à choix multiples (#12171)
- Améliorations CSS du Glossaire (#12177, #12178)
- Mise à jour de l'API GraphQL, prise en compte des droites sur les données, mise à jours des filtres
