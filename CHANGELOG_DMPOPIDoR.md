# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.

## 06/08/2026
- Correction d'un problème d'édition des phases des modules (#15960)
- Correction d'un problème d'affichage de la coche "réponses communes" dans les modèles classiques après la suppression du premier produit de recherche (#15941)
- Correction d'un problème d'affichage des référentiels lorsque la propriété `registries` est renseignée.
- Correction d'un problème d'affichage de l'info Derniere Activité dans la liste des utilisateurs (#15950)

## 09/07/2026
- Correction de l'édition de modèle suite à la migration vers Turbo (#15094)
- Correction du problème de mise à jour du profil utilisateur par un Org Admin (#15484)
- Retrait des utilisateurs inactifs du téléchargement CSV de la liste des utilisateurs dans l'espace Admin  (#15483)

## 09/07/2026
- Correction d'un problème de copie des plans entité (#15609)
- Ajout de la génération json du plan dans la base lorsqu'un plan est mis en visibilité publique
- Retrait du lien "Voir tout" de la liste des plans publics
- Amélioration de la tache de nettoyage des comptes utilisateurs
- Correction du problème de téléchargement de la liste des utilisateurs dans l'espace Admin (#15483)
- Correction du problème de création et de mise à jour des Structures (#15484)
- Correction du problème d'affichage de l'éditeur après la mise à jour d'un organisme (#15608)

## 01/07/2026
- Migration de reCaptcha vers [https://altcha.org/](Altcha)  (#15110)
  - Mot de passe oublié ? (formulaire de demande et formulaire de choix du mot de passe)
  - Page: "Contacter le support technique"
    - Désactivation de la vérification captcha si l'utilisateur est connecté
  - Page de création de compte
- Mise en place d'une variable d'environnement **ALTCHA_ENABLED** (par défaut ``true``)
- Mise en place d'une variable d'environnement **ALTCHA_HMAC_KEY** pour définir la signature Altcha
- Homogénéisation des libellés des sous formulaires (#15448)

## 25/06/2026
- Mises à jour du forulaire Produit de Recherche des plans classiques (#15396 & #15395)
- Mise à jour du référentiel utilisé par l'import Metadore
- Correction d'un problème de mise à jour des organismes affichés dans l'import Ror lors du choix d'un pays
- Amélioration de la requête utilisée par l'import RoR

## 24/06/2026
- Ajout d'un tache de génération du JSON de tous les plans structurés
- Correction de l'édition de modèle suite à la migration vers Turbo (#15094)
- Correction du problème de mise à jour des contributeurs (#15356)
- Migration de la fusion de compte vers Turbo (#15345)
- Retrait de l'affichage de la thématique dans l'infobox des PR

## 22/06/2026
- Mise à jour vers Ruby 4
- Correction de l'édition de modèle suite à la migration vers Turbo (#15094)
- Correction du problème d'affichage des valeurs sélectionnées dans un référentiel complexe avant l'enregistrement du formulaire principal (#15256)
- Mise à jour du formulaire des Groupes de Recommandations
- Amélioration des performances d'affichage des plans publics (#14752)
- Le type Jeu de Données est sélectionné par défaut dans la description d'un PR Données (#15276)
- Ajout des icones entité/projet dans la liste des plans en visibilité Organisme (#15318)
- Redirection vers parcours de création de plan après avoir créé un compte  (#15317)
