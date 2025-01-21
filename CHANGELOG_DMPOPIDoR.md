# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

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
