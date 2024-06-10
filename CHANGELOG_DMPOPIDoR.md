# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

## 07/06/2024
- Correction du problème d'accès à l'onglet Rédiger.

## 06/06/2024
- Amélioration de l'affichage lors du changement entre différents types de produits de recherche.
- Retrait de l'initialisation des données d'un formulaire à la première ouverture d'une question: des données vides ne seront plus créées dans la base lorsque l'on ouvre une question pour la première fois. Un formulaire vide est affiché, les données sont initialisées dans la base lors de la première sauvegarde.
- Les Clients API ne peuvent désormais plus accéder au fragments liés au plans auquels ils n'ont pas accès.
- Retrait de la possibilité de mise à jour des fragments par les cliens API.
- Traduction des thèmes.

## 23/05/2024

- Ajout des traduction dans les groupes de recommendations (via un champs)
- Récupération des groupes de recommendations selon la locale du plan (par défaut: fr-FR)
- Ajout du support du Produit de Recherche Logiciel.


## 14/05/2024

- Ajout de la colonne (en base de données) ``locale`` dans la table ``guidances`` (par défaut ``fr-FR``)
- Ajout d'un select dans le formulaire d'édition/création d'une recommendation afin de sélectionner la langue (par défaut ``fr-FR``)
- Ajout d'une colonne dans l'affichage des recommendations pour afficher la langue
- Affichage des recommendations dans la langue du plan
- Correction d'un problème  provoquant le blocage de l'import ANR/CORDIS

## 29/04/2024

- Le produit de recherche par défaut n'est plus créé à la création du plan
  - Une variable d'environnement est mise en place pour réactiver la fonctionnalité
  - Après la création du plan, une fenêtre indique que le plan ne posséde pas de produit de recherche, un formulaire s'affiche pour en créer un
- Possibilité de supprimer le premier produit de recherche
- Le "type" de produit de recherche est rendu obligatoire
- Il est impossible de modifier le type de produit de recherche
- Creation d'une page de glossaire en ReactJS, les données sont gérées par Directus.
- Modification de la collection des pages statiques dans Directus pour afficher ou non les pages dans le menu.
  - Modification du router pour la redirection
- Ajout de variables d'environnement au service dmpopidor:
  - ``DIRECTUS_URL``: URL interne de directus (ex: conteneur Docker), utilisé par le backend
  - ``DIRECTUS_PUBLIC_URL``: URL externe de directus, utilisé par le frontend
- Ajout de variables d'environnement au service Directus:
  - ``CORS_ENABLED=true``
  - ``CORS_ORIGIN=true``
  - ``CORS_METHODS=GET,POST``


## 26/04/2024

- Correction de l'envoie d'un commentaire vide.
- Intégration d'un service ``metadore`` (miroir interne de DataCite, moissonnage automatique journalier)
- Création d'un composant ``metadore`` qui est à l'identique de ``ror`` et ``orcid`` sur le principe de fonctionnement.

### Modification de la création/ajout des modèles de DMP

- Le bouton Créer un modèle permet de créer un modèle structuré
- Ajout d'un bouton Créer un modèle classique
- Le type de modèle n'est plus modifiable
- Le contexte du modèle n'est plus modifiable après sa création
- Les modèles structurés ne peuvent désormais avoir qu'une seule phase

### Ajout d'un nouveau type de modèle de DMP, appelé Module.

Un module est un modèle ne comportant qu'une phase. On ne peut pas créer de plan à partir d'un module mais un plan peut utiliser les sections et les questions du module en fonction des paramètres d'un de ses produits de recherche.

- Ajout d'un champ data_type permettant de définir le type de produit de recherche utilisant ce module.
- Ajout du champ data_type à madmp_schemas
- On ne peut pas créer de phase (une seule présente)
- L'ajout de questions et de sections est identique à l'existant
- Les formulaires proposés dans l'ajout d'une question sont ceux qui concernent le data_type du modèle.
