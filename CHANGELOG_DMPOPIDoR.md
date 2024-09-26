# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

## 26/09/2024

- Suppression des recommandations qui ne sont pas basées sur la langue du plan
- Amélioration du choix de formulaire personnalisé (KB #11872 #11873)

## 25/09/2024

- Sélection du type de produit de recherche par défaut (modal de création)

## 24/09/2024

- Ajout de l'import Metadore (KB #10078)
- Correction du problème d'actualisation des champs tableaux de chaine de caractères (ex: mots clés non controllés) lors d'un changement de produit de recherche (KB #11771)

## 20/09/2024

- Correction du problème de sauvegarde de l'enregistrement d'une valeur sélectionnée dans un référentiel complex (Licence, Financeur) (KB #11890)
- Correction du problème d'actualisation des champs texte lors d'un changement de produit de recherche (KB #11771)
- Correction du problème d'affichage des recommandations liées aux questions lors de l'ouverture de la modale des recommandations. 
- Amélioration de la fenêtre des cookies

## 18/09/2024

- Correction d'un problème d'affichage de la langue des recommendations dans l'espace Admin

## 13/09/2024

- Correction d'un problème d'actualisation des éditeurs de texte lors d'un changement de produit de recherche  (KB #11771)

## 12/09/2024

- Correction du problème d'affichage de la description d'une section dans les exports PDF/DOCX  (KB #11835)

## 11/09/2024

- Ajout de la description de la section à l'export PDF/DOCX d'un plan
- Suppression de la page blanche présente lors de l'export d'un modèle de plan.
- Les données personnelles sont désormais à "Oui" par défaut lors de la création d'un produit de recherche (KB #11817)
- Affichage des thèmes des recommandations dans la langue du plan (KB #11747)

## 09/09/2024

- Correction d'un problème d'affichage d'un référentiel complexe avec création lorsqu'aucune valeur n'a été sélectionnée
- Correction d'un problème d'affichage des référentiels complexes à choix uniques

## 06/09/2024

- Correction du problème de mise à jour de la valeur Données Personnelles dans l'infobox des produits de recherche (KB #11818)
- Correction du problème d'affichage de valeurs personnalisées dans les référentiels simples (KB #11720)
- Ajout d'une condition empêchant de sauvegarder une pop-up vide (KB #11545)

## 05/09/2024

- Correction du problème de changement de type lors de l'édition d'un produit de recherche
- Correction de conversion des données lors d'un changement de formulaire (plantage formulaires Masa)

## 04/09/2024

- Correction d'un problème d'affichage des commentaires et questions en mode Lecture Seule
- Ajout du support des exemples dans les formulaires structurés
- Ajout de l'affichage des tooltips pour les libellés des sous formulaires (ex: DataReuseMasa/archeoOperation/geoLocationBox)


## 30/08/2024
- Correction d'un problème d'affichage des sous fragments lors de la première sauvegarde d'un formulaire (KB #11750)
- Correction du problème d'affichage des commentaires ajoutés (KB #11752)

## 26/08/2024
- Désactivation du produit de recherche Logiciel (ajout d'une option de configuration)
- Activation de l'édition du type de produit de recherche (ajout d'une option de configuration) (KB #11749)


## 23/08/2024
- Ajout de la possibilité de laisser un commentaire dans une question non répondue (KB #11739)

## 22/08/2024
- Mise à jour des traductions
- Correction de l'import plan de gestion entité
  - Import des contributeurs, ils ne sont plus dupliqués dans l'onglet contributeur
    => La modification des contributeurs est fonctionnelle suite à la correction de l'import
  - Ajout/modification de tutelles, les données sont désormais bien sauvegardées

## 21/08/2024
- Mise en conformité RGPD des cookies
  - Ajout d'un bouton avec tooltip pour modifier les paramètres
  - Mise à jour de la view piwik pour utiliser des variables d'environnement et permettre de supprimer les cookies d'analyse
- Création du premier produit de recherche par défaut (activé par variable d'environnement)
- Uniformisation du bouton "back to top" avec celui des cookies
- Correction de traductions
- Affichage de la modale de recommendations pour une question non répondue

# 08/07/2024

- Correction du problème d'affichage du rôle choisi lors de la modification d'un contributeur dans l'onglet Rédiger (#11453)
- Correction du problème de la valeur enregistrée dans les référentiels simples contenant un attribut `value` et un libellé avec langue (#11466)

# 26/06/2024

- Ajout de l'option `name` utilisée par l'exécution de scripts à la route api/v1/madmp/schemas
- Correction d'un problème de mise à jour des contributeurs dans l'onglet Contributeurs

## 06/08/2024
- Correction de l'import du plan de gestion entité
- Affichage du choix du plan puis du produit de recherche quand un plan est sasie
- Retrait des plans avec produit de recherche sans titres

## 01/08/2024
- Correction de la question sur les données personnelles : modification possible via "Oui" ou "Non"
- L'import des produits de recherche n'affiche plus de plan par défaut. Les produits de recherche n'apparaissent que lorsqu'un plan est sélectionné.
- Réduction des espaces entre libéllés et le boutons "ajouter un élément"

## 31/07/2024
- Modification du nom abrégé et nom du produit de recheche (import/duplication) par ``PR X [Copie de Produit de recherche Y]``
- Ajout d'une validation de duplication du produit de recherche
- Suppression des plans sans produit de recherche à l'import
- Affichage du thème en anglais dans le tableau des recommandations
- Affichage de la langue hérité par la recommandation (création/édition recommandation)
- Import PGD Entité
- Ajout d'une phrase explicative pour la gestion des données personnelles dans l'infobox d'un produit de recherche
- Liens soulignés dans les pages statiques et dans les recommandations

## 30/07/2024
- Correction de l'affichage des recommandations dans la partie rédiger
- Correction du choix du thème pour une recommandation (annotation d'un template)
- Modification de l'emplacement du tooltip sur le nom des groupes de recommandations (choix des recommandations, partie rédiger)

## 24/07/2024
- Correction de l'affichage des thèmes dans l'édition des recommandations:
  - Le thème change de traduction et garde sa valeur cochée au changement de groupe
  - Le thème est traduit quand on édite la recommandation
- Duplication d'un produit de recherche via un bouton "Dupliquer" présent dans l'infobox
- Correction import ``ROR``, mapping: ``"ror": { "name.fr": "name", "ror": "orgId", "acronyms[0]": "acronym", "type": "idType" }``

## 18/07/2024
- Correction du problème d'accès  à la modification des phases, sections et questions dans les modèles "modules"
- Correction du problème survenant dans l'onglet Rédiger lors du clic sur le lien 'tout développer'. Ce problème était provoqué par l'affichage des recommandations lors de la création du premier produit de recherche.

## 03/07/2024
- Modification de la création de plan avec l'implémentation de l'import de plan.
- Affichage d'un message pour indiquer que le plan ne possède aucun produit de recherche et un bouton de redirection vers l'ongler rédiger.
- Correction de l'affichage des thèmes de la partie administration.
- Ajout de l'import dans l'onglet rédiger si le plan ne possède aucun produit de recherche

## 24/06/2024
- Ajout de l'import du produit de recherche
- Les modèles Module ne sont désormais plus reliés à un organisme.
- Ajout d'un onglet dédié aux Modules dans la liste des Modèles accessibles à l'org admin & super admin
- Intégration des corrections de la V4.0.3 (https://github.com/OPIDoR/DMPOPIDoR/blob/hotfix/4.0.3/CHANGELOG_DMPOPIDoR.md)

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
