# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

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
