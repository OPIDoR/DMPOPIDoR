# Envrionnments variables

## Summary

- [Action Cable](#action-cable)
- [Action Controller](#action-controller)
- [Action Dispatch](#action-dispatch)
- [Action Mailer](#action-mailer)
- [Action View](#action-view)
- [Active Job / Record / Support](#active-job--record--support)
- [Application](#application)
- [Assets](#assets)
- [AWS](#aws)
- [Bullet](#bullet)
- [Cache](#cache)
- [Request](#request)
- [Database](#database)
- [Devise (OminiAuth)](#devise-ominiauth)
- [DMP OPIDoR](#dmp-opidor)
- [DMP Roadmap](#dmp-roadmap)
- [DOI](#doi)
- [Shibboleth](#shibboleth)
- [Locale & Internationalisation (i18n)](#locale--internationalisation-i18n)
- [MADMP Codebase](#madmp-codebase)
- [Piwik](#piwik)
- [OpenAire](#openaire)
- [ORCID](#orcid)
- [Organisation](#organisation)
- [Pagination](#pagination)
- [Plans](#plans)
- [Public files](#public-files)
- [Rails](#rails)
- [RDAMSC](#rdamsc)
- [Re3data](#re3data)
- [Recaptcha](#recaptcha)
- [Redis](#redis)
- [Rollbar](#rollbar)
- [Ror](#ror)
- [Rswag](#rswag)
- [SPDX](#spdx)

### Action Cable

| Name | Type | Description |
| ---- | ---- | ----------- |
| ACTION_CABLE_ALLOWED_REQUEST_ORIGINS | Array | Allows requests from allowed origins ``(default: [ 'http://example.com', /http:\/\/example.*/ ])`` |
| ACTION_CABLE_DISABLE_REQUEST_FORGERY_PROTECTION | Boolean | Disables request forgery protection ``(default: true)`` |
| ACTION_CABLE_MOUNT_PATH | String | Action cable mount path ``(default: nil)`` |
| ACTION_CABLE_URL | String | Action cable URL ``(default: wss://example.com/cable)`` |

### Action Controller

| Name | Type | Description |
| ---- | ---- | ----------- |
| ACTION_CONTROLLER_ALLOW_FORGERY_PROTECTION | Boolean | Enables forgery protection ``(default: false)`` |
| ACTION_CONTROLLER_ASSET_HOST | String | Action controller asset host ``(default: http://assets.example.com)`` |
| ACTION_CONTROLLER_ENABLE_FRAGMENT_CACHE_LOGGING | Boolean | Enables fragment cache logging ``(default: true)`` |
| ACTION_CONTROLLER_PERFORM_CACHING | Boolean | Enables controller caching ``(default: true (dev) / false)`` |

### Action Dispatch

| Name | Type | Description |
| ---- | ---- | ----------- |
| ACTION_DISPACTH_X_SENDFILE_HEADER | String | Action dispatch X-Sendfile header ``(default: X-Sendfile)`` |
| ACTION_DISPATCH_SHOW_EXCEPTIONS | Boolean | Shows action dispatch exceptions ``(default: false)`` |

### Action Mailer

| Name | Type | Description |
| ---- | ---- | ----------- |
| ACTION_MAILER_PERFORM_CACHING | Boolean | Enables action mailer caching ``(default: false)`` |
| ACTION_MAILER_RAISE_DELIVERY_ERRORS | Boolean | Enables action mailer delivery error raising ``(default: false)`` |
| ACTION_MAILER_SMTP_HOST | String | Action mailer SMTP host ``(default: mailcatcher)`` |
| ACTION_MAILER_SMTP_PORT | Integer | Action mailer SMTP port ``(default: 1025)`` |
| ACTION_MAILER_DEFAULT_URL_OPTIONS_PROTOCOL | String | Action mailer protocol ``(default https)`` |
| MAILER_FROM | String | Email address of the email sender ``(default: dmp.opidor@inist.fr)`` |
| MAILER_REQUIRE_NAME | Boolean | Require sender name in emails ``(default: true)`` |
| MAILER_REQUIRE_SUBJECT | Boolean | Require subject in emails ``(default: true)`` |
| MAILER_SENDER | String | Default sender email address ``(default: dmp.opidor@inist.fr)`` |
| MAILER_TO | String | Default destination email address ``(default: example@email.address)`` |
| MAILER_LOCALIZE_ROUTES | Boolean | Localize routes ``(default: true)`` |

### Action View

| Name | Type | Description |
| ---- | ---- | ----------- |
| ACTION_VIEW_ANNOTATE_RENDERED_VIEW_WITH_FILENAMES | Boolean | Annotate the rendered view with filenames ``(default: true)`` |
| ACTION_VIEW_CACHE_TEMPLATE_LOADING | Boolean | Cache the loading of view templates ``(default: true)`` |

### Active Job / Record / Support

| Name | Type | Description |
| ---- | ---- | ----------- |
| ACTIVE_JOB_QUEUE_NAME_PREFIX | String | Active job queue name prefix ``(default: dmp_roadmap_#{Rails.env})`` |
| ACTIVE_RECORD_DATABSE_SELECTOR | Hash | Active record database selector ``(default: { delay: 2.seconds })`` |
| ACTIVE_RECORD_DUMP_SCHEMA_AFTER_MIGRATION | Boolean | Dump schema after active record migration ``(default: false)`` |
| ACTIVE_RECORD_VERBOSE_QUERY_LOGS | Boolean | Enable verbose active record query logs ``(default: true)`` |
| ACTIVE_SUPPORT_DISALLOWED_DEPRECATION_WARNINGS | Array | Disallowed active support deprecation warnings ``(default: [])`` |

### Application

| Name | Type | Description |
| ---- | ---- | ----------- |
| APPLICATION_ADMIN_DOC | String | Application administrative documentation URL ``(default: 'https://github.com/OPIDoR/DMPOPIDoR/wiki/Guide-Administrateur')`` |
| APPLICATION_API_DOCUMENTATIONS_URLS | Hash | Application API documentation URLs ``(default: { v0: 'https://github.com/DMPRoadmap/roadmap/wiki/API-V0-Documentation', v1: 'https://github.com/OPIDoR/DMPOPIDoR/wiki/API-DMP-OPIDoR' })`` |
| APPLICATION_API_MAX_PAGE_SIZE | Integer | Maximum page size for the application's API ``(default: 100)`` |
| APPLICATION_ARCHIVED_ACCOUNTS_EMAIL_SUFFIX | String | Email suffix for archived accounts of the application ``(default: @removed_accounts-opidor.fr)`` |
| APPLICATION_GUIDANCE_COMMENTS_OPENED_BY_DEFAULT | Boolean | Guidance comments opened by default for the application ``(default: false)`` |
| APPLICATION_GUIDANCE_COMMENTS_TOGGLEABLE | Boolean | Guidance comments toggleable for the application ``(default: true)`` |
| APPLICATION_ISSUE_LIST_URL | String | Application issue list URL ``(default: 'https://github.com/OPIDoR/DMPOPIDoR/issues')`` |
| APPLICATION_NAME | String | Application name ``(default: 'DMP OPIDoR')`` |
| APPLICATION_PREFERENCES | Hash | Application preferences ``(default: { email: { users: { new_comment: false, admin_privileges: true, added_as_coowner: true, feedback_requested: true, feedback_provided: true }, owners_and_coowners: { visibility_changed: true }, admins: { feedback_requested: true } } })`` |
| APPLICATION_RELEASE_NOTES_URL | String | Application release notes URL ``(default: https://github.com/OPIDoR/DMPOPIDoR/wiki/Releases)`` |
| APPLICATION_RESTRICT_ORGS | Boolean | Restrict organizations for the application ``(default: false)`` |
| APPLICATION_ROUTES_DEFAULT_URL_OPTIONS | String | Default URL options for the application routes ``(default: example.org)`` |
| APPLICATION_TWITTER_URL | String | Application Twitter URL ``(default: https://twitter.com/OPIDoR_INIST)`` |
| APPLICATION_URL | String | Application URL ``(default: https://github.com/OPIDoR/DMPOPIDoR)`` |
| APPLICATION_USER_GROUP_SUBSCRIPTION_LIST | String | Application user group subscription list ``(default: https://listes.services.cnrs.fr/wws/info/dmpopidor)`` |
| APPLICATION_VERSION | String | Application version ``(default: V4.0.0)`` |
| APPLICATION_ACTION_DISPATCH_COOKIES_SERIZLIZER | Symbol | Application Action Dispatch cookies serializer ``(default: :json)`` |
| PORT | Integer | Application port ``(default: 3000)`` |
| WEB_CONCURRENCY | Integer | Application web concurrency ``(default: 2)`` |
| WICKED_PDF_PATH | String | Application Wicked PDF path ``(default: /usr/local/bin/wkhtmltopdf)`` |
| SERVER_TIMING | Boolean | Server timing for the application ``(default: true)`` |
| SESSION_STORE_KEY | String | Session store key for the application ``(default: _dmp_roadmap_session)`` |
| EAGER_LOAD | Boolean | Eager load for the application ``(default: false)`` |
| ESCAPE_HTML_ENTITIES_IN_JSON | Boolean | Escape HTML entities in JSON for the application ``(default: true)`` |
| FORCE_SSL | Boolean | Force SSL for the application ``(default: true)`` |
| GOOGLE_ANALYTICS_TRACKET_ROOT | String | Google Analytics tracker root for the application ``(default: '')`` |
| HTTP_AUTHENTICATABLE_ON_XHR | Boolean | HTTP authentication on XHR for the application ``(default: false)`` |
| RENCONFIRMABLE | Boolean | Renconfirmable for the application ``(default: false)`` |
| REQUIRE_MASTER_KEY | Boolean | Require master key for the application ``(default: true)`` |
| RESULTS_PER_PAGE | Integer | Results per page for the application ``(default: 5)`` |
| KAMINARI_PARAMS_ON_FIRST_PAGE | Boolean | Kaminari params on the first page for the application ``(default: true)`` |
| RACK_ATTACK_ENABLED | Boolean | Rack Attack enabled for the application ``(default: true)`` |
| MAX_NUMBER_LINKS_FUNDER | Integer | Maximum number of links per funder ``(default: 5)`` |
| MAX_NUMBER_SAMPLE_PLAN | Integer | Maximum number of samples per plan ``(default: 5)`` |
| MAX_NUMBER_THEMES_PER_COLUMN | Integer | Maximum number of themes per column ``(default: 5)`` |
| SECRET_KEY_BASE | String | Secret key base ``(default: my_secret_key)`` |
| SECRET_KEY | String | Secret key ``(default: my_secret_key)`` |

### Assets

| Name | Type | Description |
| ---- | ---- | ----------- |
| ASSETS_COMPILE | Boolean | Assets compilation for the application ``(default: false)`` |
| ASSETS_DEBUG | Boolean | Assets debugging for the application ``(default: false)`` |
| ASSETS_QUIET | Boolean | Assets quiet mode for the application ``(default: true)`` |

### AWS

| Name | Type | Description |
| ---- | ---- | ----------- |
| AWS_ACCESS_KEY_ID | String | AWS access key ID for the application ``(default: Rails.application.credentials.aws.access_key_id)`` |
| AWS_ACCESS_KEY_ID | Hash | AWS access key for the application ``(default: {})`` |
| AWS_BUCKET_NAME | String | AWS bucket name for the application ``(default: nil)`` |
| AWS_BUCKET_NAME | String | AWS bucket name for the application ``(default: nil)`` |
| AWS_REGION | String | AWS region for the application ``(default: nil)`` |
| AWS_SECRET_ACCESS_KEY | String | AWS secret access key for the application ``(default: Rails.application.credentials.aws.secret_access_key)`` |
| AWS_SECRET_ACCESS_KEY | Hash | AWS secret access key for the application ``(default: {})`` |

### Dragonfly

| Name | Type | Description |
| ---- | ---- | ----------- |
| DRAGONFLY_AWS | Boolean | Enable Dragonfly AWS |
| DRAGON_FLY_SECRET | String | Dragonfly secret key ``(default: my_secret_key)`` |

### Devise (OminiAuth)

| Name | Type | Description |
| ---- | ---- | ----------- |
| DEVISE_PEPPER | String | Devise pepper ``(default: my_pepper)`` |
| DEVISE_SIGN_OUT_VIA | Symbol | The default HTTP method used to sign out a resource ``(default: :delete)`` |
| DEVISE_FULL_HOST | String | OmniAuth host URL``(default: https://my_service.hostname)`` |
| DEVISE_ALLOWED_REQUEST_METHODS | Symbol | OmniAuth allowed request methods ``(default: :post)`` |
| DEVISE_OMNIAUTH_PATH_PREFIX | String | OmniAuth path prefix``(default: /users/auth)`` |
| DEVISE_ORCID_CLIENT_ID | String | OminiAuth ORCID Client id ``(default: client_id)`` |
| DEVISE_ORCID_CLIENT_SECRET | String | OminiAuth ORCID Client secret ``(default: client_secret)`` |
| DEVISE_ORCID_CONFIG | Hash | OmniAuth ORCID configuration ``(default: {})`` |
| DEVISE_SHIBBOLETH_REQUEST_TYPE | Smymbol | OmniAuth shibboleth request type``(default: :header)`` |
| DEVISE_SHIBBOLETH_CONFIG | Hash | OmniAuth shibboleth config ``(default: {})`` |
| DEVISE_SHIBBOLETH_EXTRA_FIELDS | Array<Symbol> | OmniAuth shibboleth extra fields ``(default: [:schacHomeOrganization])`` |

### Bullet

| Name | Type | Description |
| ---- | ---- | ----------- |
| BULLET_ADD_FOOTER | Boolean | Add footer for Bullet ``(default: true)`` |
| BULLET_CONSOLE | Boolean | Bullet console ``(default: true)`` |
| BULLET_LOGGER | Boolean | Bullet logger ``(default: true)`` |
| BULLET_RAILS_LOGGER | Boolean | Bullet Rails logger ``(default: true)`` |

### Cache

| Name | Type | Description |
| ---- | ---- | ----------- |
| CACHE_CLASSES | Boolean | Cache classes ``(default: false)`` |
| CACHE_ORG_SELECTION_EXPIRATION | Integer | Cache expiration time for organization selection ``(default: 86400)`` |
| CACHE_RESEARCH_PROJECTS_EXPIRATION | Integer | Cache expiration time for research projects ``(default: 86400)``|

### Request

| Name | Type | Description |
| ---- | ---- | ----------- |
| CONSIDER_ALL_REQUESTS_LOCAL | Boolean | Consider all requests as local ``(default: false)`` |
| CONSIDER_ALL_REQUESTS_LOCAL | Boolean | Consider all requests as local ``(default: true)`` |

### Database

| Name | Type | Description |
| ---- | ---- | ----------- |
| DB_ADAPTER | String | Database adapter ``(default: postgresql)`` |
| DB_HOST | String | Database host ``(default: localhost)`` |
| DB_NAME | String | Database name ``(default: roadmap)`` |
| DB_PASSWORD | String | Database password ``(default: Rails.application.credentials.db_password)`` |
| DB_POOL_SIZE | Integer | Database pool size ``(default: 16)`` |
| DB_PORT | String | Database port ``(default: 5432)`` |
| DB_USERNAME | String | Database username ``(default: Rails.application.credentials.db_username)`` |

### DMP OPIDoR

| Name | Type | Description |
| ---- | ---- | ----------- |
| DMPOPIDOR_ENABLE_RESEARCH_OUTPUTS_UUID | Boolean | Enable research outputs UUID for DMP OPIDoR ``(default: true)`` |
| DMPOPIDOR_ENABLE_RESEARCH_STRUCTURE_TEMPLATE | Boolean | Enable research structure template for DMP OPIDoR ``(default: true)`` |

### DMP Roadmap

| Name | Type | Description |
| ---- | ---- | ----------- |
| DMPROADMAP_HOST | String | DMP Roadmap host ``(default: dmpopidor)`` |

### DOI

| Name | Type | Description |
| ---- | ---- | ----------- |
| DOI_ACTIVE | Boolean | DOI activated (default: false) |
| DOI_API_BASE_URL | String | DOI API base URL ``(default: https://my.doi.org/api/)`` |
| DOI_AUTH_PATH | String | DOI authentication path ``(default: auth_path)`` |
| DOI_HEARTBEAT_PATH | String | DOI heartbeat path ``(default: heartbeat)`` |
| DOI_LANDING_PAGE_URL | String | DOI landing page URL ``(default: https://my.doi.org/)`` |
| DOI_MINT_PATH | String | DOI mint path ``(default: doi)`` |

### Shibboleth

| Name | Type | Description |
| ---- | ---- | ----------- |
| ENABLE_SHIBBOLETH | Boolean | Enable Shibboleth ``(default: false)`` |
| SHIBBOLETH_LOGIN_URL | String | Shibboleth login URL ``(default: /Shibboleth.sso/Login)`` |
| SHIBBOLETH_LOGOUT_URL | String | Shibboleth logout URL ``(default: /Shibboleth.sso/Logout?return=)`` |
| SHIBBOLETH_USE_FILTERED_DISCOVERY_SERVICE | Boolean | Use filtered discovery service Shibboleth ``(default: false)`` |

### Locale & Internationalisation (i18n)

| Name | Type | Description |
| ---- | ---- | ----------- |
| DEFAULT_LOCALE | String | Default locale ``(default: fr-FR)`` |
| I18N_ENFORCE_AVAILABLE_LOCALES | Boolean | Enforce available locales ``(default: false)`` |
| I18N_RAISE_ON_MISSING_TRANSLATIONS | Boolean | Raise on missing translations ``(default: true)`` |
| LOCALES_DEFAULT | String | Default locale ``(default: fr-FR)`` |
| LOCALES_GETTEXT_JOINT_CHARACTER | String | Gettext join character for locales ``(default: _)`` |
| LOCALES_I18N_JOIN_CHARACTER | String | i18n join character for locales ``(default: -)`` |
| TRANSLATION_API_CLIENT | Object | Translation API client ``(default: nil)`` |
| TRANSLATION_API_ROADMAP | Object | Roadmap translation API ``(default: nil)`` |

### MADMP Codebase

| Name | Type | Description |
| ---- | ---- | ----------- |
| MADMP_CODEBASE_ACTIVE | Boolean | MADMP codebase activation ``(default: true)`` |
| MADMP_CODEBASE_API_BASE_URL | String | MADMP Codebase API base URL ``(default: http://codebase_api:50000/)`` |
| MADMP_CODEBASE_RUN_PATH | String | MADMP Codebase script execution path ``(default: scripts/%s/run)`` |
| MADMP_CODEBASE_SCRIPTS_PATH | String | MADMP Codebase scripts path ``(default: scripts)`` |
| MADMP_ENABLE_ETHICAL_ISSUES | Boolean | MADMP ethical issues activation ``(default: true)`` |
| MADMP_EXTRACT_DATA_QUALITY_STATEMENTS_FROM_THEMED_QUESTIONS | Boolean | MADMP data quality statements extraction from themed questions ``(default: false)`` |
| MADMP_EXTRACT_PRESERVATION_STATEMENTS_FROM_THEMED_QUESTIONS | Boolean | MADMP preservation statements extraction from themed questions ``(default: false)`` |
| MADMP_EXTRACT_SECURITY_PRIVACY_STATEMENTS_FROM_THEMED_QUESTIONS | Boolean | MADMP security and privacy statements extraction from themed questions ``(default: false)`` |
| MADMP_PREFERRED_LICENSES | Array | MADMP preferred licenses ``(default: [CC-BY-%{latest}, CC-BY-SA-%{latest}, CC-BY-NC-%{latest}, CC-BY-NC-SA-%{latest}, CC-BY-ND-%{latest}, CC-BY-NC-ND-%{latest}, CC0-%{latest}])`` |
| MADMP_PREFERRED_LICENSES_GUIDANCE_URL | String | MADMP preferred licenses guidance URL ``(default: https://creativecommons.org/about/cclicenses/)`` |

### Piwik

| Name | Type | Description |
| ---- | ---- | ----------- |
| PIWIK_ENABLED | Boolean | Enable Piwik ``(default: false)`` |
| PIWIK_BASE_URL | String | Piwik base URL ``(default: ')`` |
| PIWIK_SITE_ID | Integer | Piwik base URL ``(default: 0)`` |

### OpenAire

| Name | Type | Description |
| ---- | ---- | ----------- |
| OPEN_AIRE_ACTIVE | Boolean | OpenAIRE activated ``(default: true)`` |
| OPEN_AIRE_API_BASE_URL | String | OpenAIRE API base URL ``(default: https://api.openaire.eu/)`` |
| OPEN_AIRE_DEFAULT_FUNDER | String | Default OpenAIRE funder ``(default: H2020)`` |
| OPEN_AIRE_SEARCH_PATH | String | OpenAIRE search path ``(default: projects/dspace/%s/ALL/ALL)`` |

### ORCID

| Name | Type | Description |
| ---- | ---- | ----------- |
| ORCID_ACTIVE | Boolean | ORCID activated ``(default: true)`` |
| ORCID_API_BASE_URL | String | ORCID API base URL ``(default: https://pub.orcid.org/v3.0/)`` |
| ORCID_DEFAULT_ROWS | Integer | Default ORCID rows ``(default: 1000)`` |
| ORCID_LANDIG_PAGE_URL | String | ORCID landing page URL ``(default: https://orcid.org/)`` |

### Organisation

| ORGANISATION_ABBREVIATION | String | Organisation abbreviation ``(default: 'Inist-CNRS')`` |
| ORGANISATION_ADDRESS | Object | Organisation address ``(default: { line_1: 'Equipe Valorisation Données de la recherche', line_2: '2, rue Jean Zay', line_3: '54519 Vandoeuvre-lès-Nancy', country: 'FRANCE' })`` |
| ORGANISATION_COPYWRITE_NAME | String | Organisation copyright name ``(default: 'CNRS')`` |
| ORGANISATION_EMAIL | String | Organisation email address ``(default: 'dmp.opidor@inist.fr')`` |
| ORGANISATION_GOOGLE_MAPS_LINK | String | Organisation Google Maps link ``(default: https://www.openstreetmap.org/export/embed.html?bbox=6.141743659973145%2C48.65246743623988%2C6.155905723571778%2C48.658775124887654&layer=mapnik&marker=48.655621379213805%2C6.148824691772461)`` |
| ORGANISATION_HELPDESK_EMAIL | String | Organisation helpdesk email address ``(default: dmp.opidor@inist.fr)`` |
| ORGANISATION_NAME | String | Organisation name ``(default: Inist-CNRS Institut de l'Information Scientifique et Technique)`` |
| ORGANISATION_SAFE_EMAIL | String | Organisation secure email address ``(default: dmp.opidor<span style="display: none;">REMOVE</span>@inist.fr)`` |
| ORGANISATION_URL | String | Organisation URL ``(default: http://www.inist.fr/)`` |

### Pagination

| Name | Type | Description |
| ---- | ---- | ----------- |
| PAGINATION_INCLUDE_TOTAL | Boolean | Include total in pagination ``(default: true)`` |
| PAGINATION_PAGE_HEADER | String | Page header for pagination ``(default: X-Page)`` |
| PAGINATION_PER_PAGE_HEADER | String | Per page header for pagination ``(default: X-Per-Page)`` |
| PAGINATION_RESPONSE_FORMATS | Symbol | Response format ``(default: :json)`` |
| PAGINATION_PAGE_PARAM | Symbol | What parameter should be used to set the page option ``(default: :page)`` |
| PAGINATION_PER_PAGE_PARAM | Symbol | What parameter should be used to set the per page option ``(default: :per_page)`` |

### Plans

| Name | Type | Description |
| ---- | ---- | ----------- |
| PAGINATION_TOTAL_HEADER | String | Total header for pagination ``(default: X-Total)`` |
| PLANS_DEFAULT_PERCENTAGE_ANSWERED | Integer | Default percentage answered in plans ``(default: 0)`` |
| PLANS_DEFAULT_VISIBLITY | String | Default visibility of plans ``(default: privately_visible)`` |
| PLANS_ORG_ADMIN_READ_ALL | Boolean | Organization administrators can read everything in plans ``(default: true)`` |
| PLANS_SUPER_ADMINS_READ_ALL | Boolean | Super administrators can read everything in plans ``(default: true)`` |
| PLANS_DOWNLOAD_COVERSHEET_TICKBOX_CHECKED | Boolean | Download coversheet checkbox checked by default in plans ``(default: false)`` |

### Public files

| Name | Type | Description |
| ---- | ---- | ----------- |
| PUBLIC_FILE_SERVER_ENABLED | Boolean | Public file server enabled ``(default: true)`` |
| PUBLIC_FILE_SERVER_HEADERS | Object | Public file server headers ``(default: {'Cache-Control' => 'public, max-age=#{1.hour.to_i}'})`` |
| PUBLIC_FILE_SERVER_HEADERS | Object | Public file server headers ``(default: {'Cache-Control' => 'public, max-age=#{2.days.to_i}'})`` |

### Rails

| Name | Type | Description |
| ---- | ---- | ----------- |
| RAILS_ENV | String | Rails Environment ``(default: development)`` |
| RAILS_LOAD_DEFAULTS | Float | Rails default loading ``(default: 7.0)`` |
| RAILS_MAX_THREADS | Integer | Maximum Rails threads ``(default: 5)`` |
| RAILS_RELATIVE_URL_ROOT | String | Rails relative URL root ``(default: /)`` |
| RAILS_SERVE_STATIC_FILES | Boolean | Serve Rails static files ``(default: false)`` |
| RAILS_LOG_TO_STDOUT | Boolean | Rails logging to STDOUT ``(default: true)`` |
| RAILS_LOG_LEVEL | Symbol | Rails logging level ``(default: :info)`` |

### Recaptcha

| Name | Type | Description |
| ---- | ---- | ----------- |
| RECAPTCHA_ENABLED | Boolean | Recaptcha enabled ``(default: true)`` |
| RECAPTCHA_SITE_KEY | String | Recaptcha site key ``(default: 11111)`` |
| RECAPTCHA_SECRET_KEY | String | Recaptcha secret key ``(default: 22222)`` |
| RECAPTCHA_PROXY | String | Recaptcha proxy ``(default: '')`` |

### Redis

| Name | Type | Description |
| ---- | ---- | ----------- |
| REDIS_HOST | String | Redis host ``(default: localhost)`` |
| REDIS_PORT | Integer | Redis port ``(default: 6379)`` |
| REDIS_USERNAME | String | Redis username ``(default: default)`` |
| REDIS_PASSWORD | String | Redis password ``(default: changeme)`` |

### Rollbar

| Name | Type | Description |
| ---- | ---- | ----------- |
| ROLLBAR_ACCESS_TOKEN | Object | Rollbar access token ``(default: nil)`` |
| ROLLBAR_ANONYMIZE_USER_IP | Boolean | Anonymize user IP for Rollbar ``(default: true)`` |
| ROLLBAR_COLLECT_USER_IP | Boolean | Collect user IP for Rollbar ``(default: true)`` |
| ROLLBAR_PERSON_ID_METHOD | String | Person ID method for Rollbar ``(default: id)`` |
| ROLLBAR_PERSON_METHOD | String | Person method for Rollbar ``(default: current_user)`` |
| ROLLBAR_PERSON_USERNALE_METHOD | String | Username method for Rollbar ``(default: name)`` |

### Ror

| Name | Type | Description |
| ---- | ---- | ----------- |
| ROR_ACTIVE | Boolean | ROR active ``(default: true)`` |
| ROR_API_BASE_URL | String | ROR API base URL ``(default: https://api.ror.org/)`` |
| ROR_HEARTBEAT_PATH | String | ROR heartbeat path ``(default: heartbeat)`` |
| ROR_LANDING_PAGE_URL | String | ROR landing page URL ``(default: https://ror.org/)`` |
| ROR_MAX_PAGES | Integer | ROR maximum pages ``(default: 2)`` |
| ROR_MAX_REDIRECTS | Integer | ROR maximum redirects ``(default: 3)`` |
| ROR_RESULTS_PER_PAGE | Integer | ROR results per page ``(default: 20)`` |
| ROR_SEARCH_PATH | String | ROR search path ``(default: organizations)`` |

### Rswag

| Name | Type | Description |
| ---- | ---- | ----------- |
| RSWAG_SWAGGER_ENDPOINT_FILE_PATH | String | Rswag Swagger endpoint file path ``(default: /api-docs/v1/swagger.json)`` |
| RSWAG_SWAGGER_ROOT | String | Rswag Swagger root ``(default: #{Rails.root}/swagger)`` |
| RSWAG_SWAGGER_TITLE | String | Rswag Swagger title ``(default: API V1 Docs)`` |

### SPDX

| Name | Type | Description |
| ---- | ---- | ----------- |
| SPDX_ACTIVE | Boolean | SPDX active ``(default: true)`` |
| SPDX_API_BASE_URL | String | SPDX API base URL ``(default: https://raw.githubusercontent.com/spdx/license-list-data/)`` |
| SPDX_LANDING_PAGE_URL | String | SPDX landing page URL ``(default: http://spdx.org/licenses/)`` |
| SPDX_LIST_PATH | String | SPDX list path ``(default: master/json/licenses.json)`` |
