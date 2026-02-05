export default {
  root: 'body',
  autoShow: true,
  // disablePageInteraction: true,
  hideFromBots: true,
  mode: 'opt-in',
  revision: 0,

  cookie: {
    name: 'dmp_cc_cookie',
    domain: location.hostname,
    path: '/',
    sameSite: 'Lax',
    expiresAfterDays: 7,
  },

  // https://cookieconsent.orestbida.com/reference/configuration-reference.html#guioptions
  guiOptions: {
    consentModal: {
      layout: 'cloud',
      position: 'bottom center',
      flipButtons: false,
      equalWeightButtons: false,
    },
    preferencesModal: {
      layout: 'box',
      flipButtons: false,
      equalWeightButtons: false,
    },
  },

  categories: {
    necessary: {
      enabled: true,
      readOnly: true,

      services: {
        dmp: {
          label: 'DMPOPIDoR',
          cookies: [
            {
              name: '_dmp_opidor_session',
            },
          ],
        },
      },
    },

    functionality: {
      enable: true,
      readOnly: true,

      services: {
        directus: {
          label: 'Directus',
          cookies: [
            {
              name: 'directus_session_token',
            },
          ],
        },
        cookie: {
          label: 'Paramètres des cookies',
          cookies: [
            {
              name: 'dmp_cc_cookie',
            },
          ],
        },
      },
    },

    analytics: {
      enable: true,
      readOnly: false,

      autoClear: {
        cookies: [
          {
            name: /^(_pk_id.*)/,
          },
          {
            name: /^(_pk_ses.*)/,
          },
        ],
      },

      // https://cookieconsent.orestbida.com/reference/configuration-reference.html#category-services
      services: {},
    },
  },

  language: {
    default: 'fr',
    autoDetect: 'browser',
    translations: {
      fr: {
        consentModal: {
          title: 'Cookies',
          description: 'Nous utilisons des cookies pour améliorer votre expérience et analyser notre site. Vous pouvez accepter tous les cookies, les refuser, ou gérer vos préférences.',
          acceptAllBtn: 'Tout accepter',
          acceptNecessaryBtn: 'Tout rejeter',
          showPreferencesBtn: 'Gérer les préférences',
          footer: `
            <a href="/privacy" target="_blank">Politique de confidentialité</a>
          `,
        },
        preferencesModal: {
          title: 'Préférences de cookies',
          acceptAllBtn: 'Tout accepter',
          acceptNecessaryBtn: 'Tout rejeter',
          savePreferencesBtn: 'Accepter la sélection',
          closeIconLabel: 'Fermer la modale',
          sections: [
            {
              title: 'Utilisation des Cookies',
              description: 'Nous utilisons des cookies pour améliorer votre expérience et analyser notre site. Vous pouvez accepter tous les cookies, les refuser, ou gérer vos préférences.',
            },
            {
              title: 'Cookies Strictement Nécessaires <span class="pm__badge">Toujours Activé</span>',
              description: 'Ces cookies sont essentiels pour vous permettre de naviguer sur notre site et d\'utiliser ses fonctionnalités. Ils ne peuvent pas être désactivés dans nos systèmes. Ils sont généralement définis en réponse à des actions de votre part, telles que la définition de vos préférences en matière de confidentialité, la connexion ou le remplissage de formulaires.',
              linkedCategory: 'necessary',
              cookieTable: {
                caption: 'Liste des cookies',
                headers: {
                  name: 'Cookie',
                  domain: 'Domain',
                  desc: 'Description',
                  duration: 'Durée',
                },
                body: [
                  {
                    name: '_dmp_opidor_session',
                    domain: location.hostname,
                    desc: 'Ce cookie est utilisé pour maintenir votre session ouverte lorsque vous naviguez sur le site.',
                    duration: 'Fin de la session / 24 heures',
                  },
                ],
              },
            },
            {
              title: 'Cookies de fonctionnalités <span class="pm__badge">Toujours Activé</span>',
              description: 'Ces cookies permettent d’améliorer la performance et les fonctionnalités du site.',
              linkedCategory: 'functionality',
              cookieTable: {
                caption: 'Liste des cookies',
                headers: {
                  name: 'Cookie',
                  domain: 'Domain',
                  desc: 'Description',
                  duration: 'Durée',
                },
                body: [
                  {
                    name: 'directus_session_token',
                    domain: location.hostname,
                    desc: 'Ce cookie est utilisé pour assurer la connexion avec le service "Directus" qui permet la gestion de certaines pages du site.',
                    duration: 'Fin de la session / 15 minutes',
                  },
                  {
                    name: 'dmp_cc_cookie',
                    domain: location.hostname,
                    desc: 'Ce cookie est utilisé pour enregistrer vos préférences en terme de cookies.',
                    duration: '7 jours',
                  },
                ],
              },
            },
            {
              title: 'Cookies d\'analyse',
              description: 'Ces cookies nous permettent de suivre et d\'analyser l\'audience du site de manière anonyme afin d\'améliorer la performance et l\'expérience utilisateur. Toutes les informations collectées par ces cookies sont agrégées et donc anonymisées. Si vous n\'autorisez pas ces cookies, nous ne saurons pas quand vous avez visité notre site et ne pourrons pas surveiller sa performance.',
              linkedCategory: 'analytics',
              cookieTable: {
                caption: 'Listes des cookies',
                headers: {
                  name: 'Cookie',
                  domain: 'Domain',
                  desc: 'Description',
                },
                body: [
                  {
                    name: '_pk_id.*',
                    domain: location.hostname,
                    desc: 'Ces cookies sont utilisés par Matomo pour distinguer les utilisateurs uniques en attribuant un identifiant unique généré aléatoirement et permet de traquer la navigation.',
                    duration: '13 mois',
                  },
                  {
                    name: '_pk_ses.*',
                    domain: location.hostname,
                    desc: 'Ces cookies sont utilisés par Matomo pour distinguer les utilisateurs uniques en attribuant une session unique générée aléatoirement.',
                    duration: '13 mois',
                  },
                ],
              },
            },
            {
              title: 'Vos choix concernant les cookies',
              description: 'Vous pouvez choisir d\'accepter uniquement les cookies nécessaires ou d\'accepter tous les cookies, y compris ceux d\'analyse. Vous pouvez également personnaliser vos préférences en matière de cookies à tout moment en accédant aux paramètres des cookies sur notre site.',
            },
          ],
        },
      },
      en: {
        footer: `
          <a href="/privacy" target="_blank">Terms of use</a>
        `,
        consentModal: {
          title: 'Cookies',
          description: 'We use cookies to improve your experience and analyse our site. You can accept all cookies, reject them, or manage your preferences.',
          acceptAllBtn: 'Accept all',
          acceptNecessaryBtn: 'Reject all',
          showPreferencesBtn: 'Manage Individual preferences',
        },
        preferencesModal: {
          title: 'Cookie preferences',
          acceptAllBtn: 'Accept all',
          acceptNecessaryBtn: 'Reject all',
          savePreferencesBtn: 'Accept current selection',
          closeIconLabel: 'Close modal',
          sections: [
            {
              title: 'Cookies',
              description: 'We use cookies to improve your experience and analyse our site. You can accept all cookies, reject them, or manage your preferences.',
            },
            {
              title: 'Cookies Strictement Nécessaires <span class="pm__badge">Always enabled</span>',
              description: 'These cookies are essential to enable you to browse our site and use its features. They cannot be deactivated in our systems. They are generally set in response to actions on your part, such as defining your confidentiality preferences, logging in or filling in forms.',
              linkedCategory: 'necessary',
              cookieTable: {
                caption: 'Cookies list',
                headers: {
                  name: 'Cookie',
                  domain: 'Domain',
                  desc: 'Description',
                  duration: 'Duration',
                },
                body: [
                  {
                    name: '_dmp_opidor_session',
                    domain: location.hostname,
                    desc: 'This cookie is used to keep your session open when you browse the site.',
                    duration: 'Session ends / 24 hours',
                  },
                ],
              },
            },
            {
              title: 'Functionality cookies <span class="pm__badge">Always enabled</span>',
              description: 'These cookies are used to improve the site\'s performance and functionality.',
              linkedCategory: 'functionality',
              cookieTable: {
                caption: 'Cookies list',
                headers: {
                  name: 'Cookie',
                  domain: 'Domain',
                  desc: 'Description',
                  duration: 'Durée',
                },
                body: [
                  {
                    name: 'directus_session_token',
                    domain: location.hostname,
                    desc: 'This cookie is used to connect to the ‘Directus’ service, which enables certain pages of the site to be managed.',
                    duration: 'Session ends / 15 minutes',
                  },
                  {
                    name: 'dmp_cc_cookie',
                    domain: location.hostname,
                    desc: 'This cookie is used to save your cookie preferences.',
                    duration: '7 days',
                  },
                ],
              },
            },
            {
              title: 'Analytics cookies',
              description: 'These cookies enable us to track and analyse the site\'s audience anonymously in order to improve performance and the user experience. All information collected by these cookies is aggregated and therefore anonymised. If you do not allow these cookies, we will not know when you have visited our site and will not be able to monitor its performance.',
              linkedCategory: 'analytics',
              cookieTable: {
                caption: 'Cookies list',
                headers: {
                  name: 'Cookie',
                  domain: 'Domain',
                  desc: 'Description',
                  duration: 'Duration',
                },
                body: [
                  {
                    name: '_pk_id.*',
                    domain: location.hostname,
                    desc: 'These cookies are used by Matomo to distinguish unique users by assigning a randomly generated unique identifier and to track browsing behaviour.',
                    duration: '13 mounths',
                  },
                  {
                    name: '_pk_ses.*',
                    domain: location.hostname,
                    desc: 'These cookies are used by Matomo to distinguish unique users by assigning a randomly generated unique session.',
                    duration: '13 mounths',
                  },
                ],
              },
            },
            {
              title: 'Your choices concerning cookies',
              description: 'You can choose to accept only necessary cookies or to accept all cookies, including analysis cookies. You can also personalise your cookie preferences at any time by accessing the cookie settings on our website..',
            },
          ],
        },
      },
    },
  },
};
