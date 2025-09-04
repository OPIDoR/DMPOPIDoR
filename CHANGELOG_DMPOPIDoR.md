# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

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
