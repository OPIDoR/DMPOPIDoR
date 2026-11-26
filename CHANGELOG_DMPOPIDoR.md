# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

## 26/11/2026
- Correction d'un problème de filtrage des produits de recherche lors de l'import de réponse
- Suppression des options de formatage pour l'export PDF (#18887)
- Correction du problème de choix des produits de recherche lors de l'export JSON (#18901)
- Correction du problème d'ouverture de la question lorsque l'utilisateur clique sur l'icone de commentaire dans une question fermée (#18903)
- Correction du problème de téléchargement des PDF pré-générés pour les plans publics 

## 23/11/2026
- Retrait de la thématique des critères de tri de l'import de réponse (#18807)
- Mise à jour vers devise_invitable V3 (librairie gérant les invitations de comptes) (#18776)
- Retrait de la création par défaut du contact d'un produit de recherche Collections d'objets physique (#18754)
- Suppression des colonnes archived & archived_by de la table des commentaires (#18658)
- Correction de l'affichage des marges dans les export PDF (#18848)
- Correction d'un problème de rafraichissement du formulaire après la création d'un commentaire sur une question non répondue (#18860)
- Amélioration de l'attribution du formulaire utilisé lors de l'import d'une réponse dans une question non répondue ou la création d'un commentaire sur une question non répondue : 
  - Attribution du formulaire lié à la question (Formulaire Standard) pour un produit de recherche dataset/generic
  - Attribution d'un formulaire correspondont au questionnaire et à la thématique choisie autrement

## 16/11/2026
- Ajout de la licence dans les critères nécessaires au changement de visibilité d'un plan
- Ajout d'une checklist indiquant les raisons du blocage de changement de visibilité
- Mise à jour des textes en lien avec le changement de visibilité

## 12/11/2026
- Correction du problème de suppression de la licence (#18821)
- Mise à jour du texte des droits d'auteur dans les plans sans licence dans le pied de page de l'export PDF (#18822)
- Ajout de la licence dans le pied de page de l'export PDF des plans classiques (#18823)
- Correction du problème d'ouverture de la zone recommandations/commentaires dans les plans classiques (#18824)

## 06/11/2026
- Refonte de l'affichage du pied de page, ajout d'une licence par défaut pour les plans publics et organismes (#18811)

## 29/10/2026
- Changement de l'icône d'import de réponse
- Changement des textes de l'import de réponse (#18783)
- Correction du chargement des éditeurs dans les plans classiques (#18757)

## 28/10/2026
- Correction d'un problème autorisant la suppression de tous les produits de recherche dans les plans classiques (#18758)
- Correction de l'ordre des produits de recherche dans l'onglet Télécharger

## 19/10/2026
- Mise à jour de changement de plan en visibilité publique (#18739)
- Correction d'un problème empéchant l'affichage de la liste des produits de recherche lors de l'import d'une réponse.
- Améliorations de l'import de réponse et de produits de recherche : 
  - exclusion des plans sans produit de recherche
  - ajout d'un message lorsqu'aucun produit de recherche ne correspond aux critères d'import dans le plan sélectionné"

## 15/10/2026
- Correction d'un problème avec le script de génération des PDF (#18650)
- Retrait de la création des contributeurs dans l'onglet Contributeurs des plans structurés (#18652)
- Correction d'un problème de génération du contact du plan

## 12/10/2026
- Correction d'un problème d'affichage des symboles HTML dans les titres et corps des actualités (#18700)
- Retrait de la création et modification des contributeurs dans l'onglet Contributeurs des plans structurés (#18652)
- Ajout de la licence Etalab par défaut lors de la création d'un plan (#18659)
- Ajout du support de la thématique pour filtrer les plans et les produits de recherche lors de l'import de réponses et de produits

## 09/10/2026
- Amélioration du chargement des plans et des produits de recherche dans l'import de produits et de réponses. 
- Ajout de l'exclusion du plan actuel dans l'import de produit de recherche

## 08/10/2026
- Ajout du bouton Voir tout sur la liste des plans publics (#18651)
- Ajout de la tache de conversion des grandId ANR en DOI (#18695)
- Retrait du message de copyright dans les PDF des plans publics (#18618)
- Refonte de l'archivage des commentaires : les commentaires sont désormais supprimés et ajout d'un script de supression des commentaires archivés (#18616)

## 06/10/2026
- Ajout d'un script d'initialisation de la table des commentaires lus afin d'éviter un trop grand nombre de notifications sur les plans comportant des commentaires présents avant la mise à jour.
- Exclusion des commentaires archivés de la notification des commentaires non lus

## 01/10/2026
- Ajout de l'import d'un réponse depuis un plan et un produit de recherche choisi
- Ajout d'indicateurs de commentaires non lus au niveau des questions et des produits de recherche
