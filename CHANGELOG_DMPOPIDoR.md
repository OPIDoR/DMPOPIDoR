# Liste des changements

**Attention** Cette liste de changements concerne les déploiements sur nos serveurs de test en interne.


# 21/06/2024

- Correction du format des données retournées par l'API api/v1/madmp/schemas (#11319)
- Correction du problème d'édition des contributeurs lors de l'utilisation de la pagination (#11346)
- Correction du problème de vérification de l'unicité lors de la création d'un nouveau contributeur

# 18/06/2024

- Correction du problème d'accès à l'API api/v1/madmp/fragments/{id} (#11318)
- Correction du problème d'affichage des recommandations sur les plans en lecture seule (#11324)
- Retrait de la zone de choix des recommandations des plans en lecture seule (#11324)

# 12/06/2024

- Les sous-fragments constants sont désormais supprimables (#10910)
- Ajout de la description des sections dans l'onglet Rédiger (#10903)
- Retrait des modèles structurés de la liste des modèles personnalisables (#11039)
- Retrait des organismes non gérés de la création de compte et modification de profil (hors super admin) (#11056)
- La vérification d'unicité d'un élément ne prend plus en compte les propriétés vides (#10435)

# 18/04/2024

- Correction du problème de suppression des valeurs dans les référentiels simples à choix multiples, ex: DocumentationQualityStandard.documentationSoftware (#10831)
- Augmentation du nombre de caractères (100 caractères) des titres des DMP affichés en visibilité Privé, Organisme & Administrateur
- Augmentation de la durée de la session de connexion de 90 minutes à 24h.

# 16/04/2024

- Correction du problème d'affichage de l'onglet Informations Générales
- Correction du problème de copie des plans classiques (#10815)
- Export PDF/DOCX : Ajout d'une vérification du format des données utilisées lors de l'affichage d'un tableau de chaines de caractère (problème d'affichage de documentationSoftware dans DocumentationQualityStandard suite à une incompatibilité entre les schemas V3 et V4) (#10818)
- Mise à jour de TinyMCE (éditeur de texte)

# 12/04/2024

- Désactivation de la création d'organisme depuis RoR dans la création de compte (#10798)
- Les liens des pages statiques sont désormais soulignés (#10797)
- Ajout du mode lecture seule dans l'onglet contributeurs (#10800)
- Correction du problème d'affichage des icones Commentaires/Recommandations (#10794)
- Correction du démarrage automatique de la visite guidée, attente du rendu des composants de la page avant de la lancer.
