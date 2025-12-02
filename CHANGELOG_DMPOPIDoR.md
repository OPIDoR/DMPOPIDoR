# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

## 02/12/2025

- Ajout des corrections et fonctionnalités V4.3.5 : 
  - Ajout des plans entité publics et de tous les plans accessibles (lecture et édition) aux plans accessibles à l'import de PR
  - Correction d'un problème de sauvegarde des contributeurs avec un role constant (#14308)
  - Correction d'un problème d'initialisation des informations d'un PR lors de l'import d'un plan (#14234)
  - Correction du problème de fonctionnement des boutons "développer tout/réduire tout" dans les plans classiques (#13441)
  - Modification de la description de la route `/api/v1/madmp/plans/import` dans le Swagger (#13532)
- Ajout d'icones et d'un "placeholder" de chargement dans l'import de produit de recherche

## 12/11/2025

- Correction du problème de traduction de la visibilité dans les mails de Changement de visibilité (#14155)
- Correction du problème provoquant la création de formulaire vides lors de l'import d'un produit contenant des réponses non répondues (#14100)
- Ajout des questions dans les exports de plans publics (#14201)
- La visibilité des plans copiés est désormais "Privé" par défaut (#14199)

## 04/11/2025

- Correction du problème de fusion des organismes (#14161)
- Amélioration du bouton Créer un Plan sur la page d'accueil (#11964)
- Amélioration de l'affichage des tooltips des groupes de recommandations (#13735)
- Amélioration de l'import de produit de recherche avec des réponses utilisant des formulaires personnalisés (#14100)

## 28/10/2025

- Mise à jour des traductions
- L'import et la duplication des produits de recherche garde les formulaires sélectionnés (#14100)
- Correction du problème de création des produits de recherche dans les plans classiques (#13962)
- Les recommandations par défaut sont désormais sélectionnées lors de l'import/duplication d'un produit de recherche (#14099)
- Les référentiels des sous formulaires s'affichent selon la thématique sélectionnée (#14137)

## 13/10/2025

- Tentative de résoudre le problème d'affichage après la création d'un nouveau produit de recherche (#14041)
- Ajout du topic dans l'export JSON (#14071)
- Ajout du support du topic dans l'import de produits de recherche et de plans
- Correction d'un souci de traduction (#14080)
- Correction d'import de données ROR, le champs de filtre (pays) ne disparait plus (#13979)
- Ajout du "Kit Communication" dans le pied de page (#12080)

## 09/10/2025

- Retrait du caractère "*" indiquant un modèle par défaut dans la liste des modèles
- Seuls les groupes de recommandations publiés n'apparaissent dans la liste des recos (#14070)
- Correction du problème d'affichage des recommandations sélectionnées dans un PR
- Correction du problème de fonctionnement de la case à cocher 'modèle recommandé' (#14056)
- Mise à jour des traductions de la Rédaction de plan et Infos Générales (#13977)
- Le filtre se réinitialise lors de la sauvegarde des recommandations sélectionnées

## 06/10/2025

- Ajout des contextes (`contexts`) au modèle de plans.
  - Le contexte fournit lors de la création de plan permet de filtrer les modèles
  - Un modèle peut avoir plusieurs contextes. 
  - Ajout d'un icone indiquant les contextes d'un modèle aux différentes listes de modèles
  - Ajout d'une tâche permettant de récupérer le contexte précédemment rempli
- Ajout du type de données à la liste des recommandations
- Correction des problèmes d'affichage des formulaires par défaut et de la boite d'affichage des formulaires (#14044)

## 02/10/2025

- Le choix de formulaire inclus désormais les formulaires liés à la thématique "standard" et à la thématique éventuellement choisie (#14016)
- Mise à jour des traductions (#13977)
- Ajout du type de données aux groupes de recommandations (#13957)
  - Ajout du type de données aux formulaires des groupes de reco
  - Affichage des groupes de recommandations disponibles en fonction du type de PR
- Correction de la langue par défaut de l'application (#13968)
- (Turbo) Correction du problème empêchant l'export PDF & DOCX (#13971/13972)
- Correction d'un problème de mise à jour du choix des recommandations lors de la création d'un nouveau PR
- Si disponible, le formulaire thématique est affiché par défaut
- La sélection des formulaires ne s'affiche désormais que lorsqu'un formulaire thématique n'est pas disponible
- Les recommandations thématiques sont désormais sélectionnées par défaut

## 24/09/2025

- Correction de la case à cocher Recommandé dans la liste des modèles
- Ajout d'icones et d'une légende au Tableau de bord, indiquant les plans projets et entité
- Modification de l'affichage des formulaires en fonction de la thématique :
  - Le formulaire lié à la question est proposé par défaut
  - A REVOIR : Le choix des formulaires ne prend plus en compte la thématique (à revoir car idéalement la liste devrait proposer les formulaires thématiques + Mesocentres + formulaire par défaut)
- Ajout de la liste des recommendations sélectionnées aux exports PDF/DOCX et JSON
- Ajout de la liste des recommentations sélectionnées au dessus de l'infobox et déplacement de la zone de sélection en dessous de l'infobox
- Correction du problème empêchant la modification du profil utilisateur
- Correction du probllème de sélection/déselection du pays dans l'import RoR
- Correction d'un problème d'édition de l'infobox

## 11/09/2025

- Ajout de la page "Accessibilité" (création de page dans directus)
- Correction de l'export JSON d'un plan
- Ajout d'une route d'API REST (API V1) pour récupérer les plans publics
- Mise à jour de l'API ROR (utilisation de l'API V2)
- Correction de la persistance du filtre de pays (import ROR)
- Mise à jour de la documentation (schema) GraphQL
- Utilisation de driver.js en remplacement de joyride pour la visite guidée
- Élargissement du produit de recherche (côté gauche) dans la partie rédiger
- Correction "Tout développer/Tout réduire" des modèles classiques
- Correction de la case à cocher "Plan test" dans la partie "Renseignements sur le plan" des "Informations générales"
- Ouverture du groupe de produit de recherche courant à la création
- Après suppression d’un produit, le produit courant se positionne désormais sur le produit précédent (N-1) dans la liste de recherche.

## 04/09/2025

- Refonte des plans pour les entités de recherche : l'information du contexte est désormais attachée aux plans. Il n'est plus nécessaire d'avoir des modèles spécifiques pour les entités (#12963)
  - Retrait du `context` de la table des modèles
  - Ajout du `context` à la table des plans
  - Migration de la valeur du context de la table des modèles à la table des plans
- Ajout du choix de la thématique aux produits de recherche (en anglais : topic) (#12705)
  - Ajout du référentiel Topics
  - Ajout du choix des thématiques associées aux formulaires (madmp_schemas), référentiels (registries) & groupes de recommendations
  - Les formulaires proposés dans le choix de formulaires sont désormais ceux associés à la thématique du produit de recherche. Le formulaire par défaut reste celui associé à la question
  - Les référentiels proposés dans les formulaires dynamiques sont désormais ceux associés à la thématique du produit de recherche. Si aucun référentiels n'est disponible, les référentiels standards (topics=standard) sont proposés
- Ajout de la possibilité de choisir les recommendations au niveau des produits de recherche dans les plans structurés (#13542)
  - Ajout de filtres sur les organismes et la thématique
  - Affichage des recommentations liés au produit de recherche au niveau des questions
  - Refonte du systeme d'affichage de l'icone indiquant la présence de recommentation liée à une question
  - Migration des groupes de recommentations du plan aux produits de recherche
- Migration vers Rails 8 (#11756)
- Migration vers React 19 (#12965)
- (En cours) Migration de Rails UJS à Turbo (#11330): Une grande partie du code est migrée mais certaines fonctionnalités comme l'édition de modèle ne fonctionnent pas encore. 
