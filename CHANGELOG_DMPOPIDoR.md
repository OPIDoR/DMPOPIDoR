# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

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
