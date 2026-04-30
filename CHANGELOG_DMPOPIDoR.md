# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

## 29/04/2025
- Refonte de l'API GraphQL
- Correction du filtre obligatoire pour les produits de recherche
- Modification page d'aide, ajout de couleur aux onglets et de l'index de l'onglet dans l'URL

## 24/04/2026
- Ajout de la possibilité de créer des produits de recherche avec le questionnaire Objet Physique
- Ajout de la colonne `is_default` aux groupes de recommendation. Ces groupes sont sélectionnés par défaut à la création d'un produit de recherche en fonction du dataType, de la langue et du topic choisi (#14853)

## 13/04/2026
- Correction du problème d'affichage de l'onglet Infos Générales après un import financeur
- Correction d'un problème de redirection lorsque la création d'une recommandation ne se déroule pas avec succès
- Les recommandations possédant un dataType différent de 'dataset' sont désormais sélectionnées par défaut (#14853)

## 10/04/2026
- Retrait des icônes de la création de plan (#14681)
- Correction du problème d'actualisation du tableau après la modification des droits d'administration (#13978)
- Refonte de la sélection du type de produit de recherche lors de la création (#14679)
  - Le type est désormais limité Dataset et Software
  - Le dataType par défaut est "dataset" au lieu de "none"
  - Ajout du dataType "physical object" dans la partie administration
- Syntaxe du code : refonte du code ReactJS. Gros travail de mise en conformité du code ReactJS. Ce travail ne devrait pas changer le fonctionnement mais apporte une meilleure gestion des référentiels chargés en mémoire, de l'affichage des composants et des variables.

## 31/03/2026
- Ajout d'une tache de convertion des fragments contributeurs utilisant le référentiel SoftwareRoles (#14371)
- Ajout d'un message à coté de l'infobox indiquant qu'aucune recommandation n'est sélectionnée (#14852)
- Correction du problème de création de compte (#14878)
- Correction du problème d'affichage des thèmes lors de la création/edition d'une recommandation (#14897)

## 19/03/2026
- Ajout d'un système de mise en cache des Domaines de Recherche des plans publics (#14760)
- Changement de l'icone Financeur dans la création de plan (#14681)
- Affichage du libellé de la thématique dans l'infobox des PR (#14819)
- Mise à jour des fichiers des templates et référentiels 


## 16/03/2026
- Changement des URLS des pages de gestion des recommandations (#14797)
  - Afin de préparer la mise à jour des recommandations (voir #14141), le code et les urls de gestion des recommandations a été changé pour adopter une approche plus "REST". C'est en principe transparent pour l'utilisateur, tous les liens dans l'interface ont été mis à jour. Les nouvelles URL sont décrites ci dessous.
  - Recommandations : `org/admin/guidance/...` -> `org_admin/guidances`
  - Groupes de Recommandations : `org/admin/guidancegroup/...` -> `org_admin/guidance_groups`

## 13/03/2026
- Ajout d'un indicatif de chargement lors de la suppression d'un produit de recherche (#14756)
- Mise à jour de l'icone des financeurs dans la création de plan (#14681)
- Mise à jour du libellé de l'export RDA dans le téléchargement de plan (#14632)
- Mise à jour des textes de la visité guidée (#14640)

## 10/03/2026
- La sélection d'une thématique est obligatoire lors de la création d'un PR (#14755)
- Amélioration de l'affichage des recommandations sélectionnées (#14746)

## 26/02/2026
- Correction du problème de contributeur vide créé à la copie de plan (#14561)
- Mise à jour du texte de partages à un service externe (#14663)
- Ajout d'un icone pour les financeurs dans la création de plan (#14681)
- Ajout des icones des plans projet/entité dans les plans publics (#14680)
- Correction du problème d'affichage des préférences de notifications (#14639)
- Correction affectant le changement de mot de passe (#14641)

## 19/02/2026
- Ajout d'une option de configuration pour désactiver l'ajout de la thématique aux PR
- Ajout des groupes de recommandations manquants dans l'export JSON (#14672)
- Améliorations des textes de l'interface de sélection des recommandations 
- Correction du problème de changement de mot de passe (#14641)

# 10/02/2026

- Création de plan : Abandon de react-form-stepper & réécriture d'un composant interne. (la librairie n'était plus maintenue)
- Les points suivant concernent du travail de fond et de la dette technique
  - Abandon du dépot de code séparé & Intégration du code ReactJS au code DMP OPIDoR (Meilleure maintenance et )
  - Migration vers esbuild-loader (amélioration de la vitesse de construction du code)
  - Amélioration de la configuration eslint (règles de codage pour améliorer le code)

# 28/01/2026
- Modification GraphQL : le champ researchOutput accepte désormais des paramètres permettant de filtrer les produits de recherche d’un plan.

## 22/01/2026
- Améliorations de l'interface des recommandations (#14391)
  - Changement de position du bouton Réinitialiser
- Le champ Thématique est désormais masqué lors de la création d'un PR Logiciel (#14509)

## 21/01/2026
- Utilisation de la table json_plans pour l'export JSON au format DMP OPIDoR

## 15/01/2026
- Amélioration de la résolution des noms avec repli sur la locale, le code pays ou le premier élément
- Correction du problème d'affichage des notifications de changement de droit d'accès d'un plan
- Améliorations de l'interface des recommandations (#14391)
  - Changement de position des boutons Enregistrer et Réinitialiser
  - Ajout de la recherche sans prendre en compte les accents
- Améliorations de la V4.3.7 : 
  - Amélioration des exports PDF (#14483)

## 14/01/2026
- Optimisation GraphQL des requêtes SQL de récupérations des plans (récupération par liste d'identifiant de plan)
- Optimisation GraphQL d'ajout de la partie configuration dans les produits de recherche

## 13/01/2026

- Correction du problème affectant le changement des droits d'accès au plan (#14335)
- Les plans sans produit de recherche ne peuvent plus changer de visibilité (#14338)
- Amélioration de la traduction (#13977)
- Améliorations de l'interface des recommandations (#14391)
  - Possibilité de rechercher sur l'organisme et sur le nom des groupes
  - Affichage de la barre de recherche
  - Le bouton Réinitialiser permet de retrouver les recommandations par défaut d'un PR
- Améliorations de la pagination des tableaux (#14242)
- Améliorations de la V4.3.7 : 
  - Correction du problème d'import des PGD publics (#14355)
  - Correction du problème de mise à jour/suppression des commentaires dans les plans en lecture seule (#13879)
  - Ajout de taches de correction des champs `idType` dans les fragments Person, Funder, Partner (ROR & ORCID) (#13773)

## 05/01/2026

- Amélioration de l'interface de sélection des recommandations (#14391)
- Correction d'un problème d'édition et suppression des commentaires dans les plans en lecture seule (#13879)

## 09/12/2025

- Refonte de l'interface de sélection des recommandations (#14052)

## 04/12/2025

- Ajout du support de la déclaration des référentiels soit par la catégorie sous par une liste fixe (#14281)
- Amélioration de l'affichage des groupes de recommandations disponible dans le choix des recommandations, désormais seul le nom de l'organisme est affiché lorsqu'il n'a qu'un group publié

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
