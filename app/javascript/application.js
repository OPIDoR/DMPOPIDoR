/* eslint no-console:0 */

import 'core-js/stable';
import 'regenerator-runtime/runtime';

// Pull in Bootstrap JS functionality
import * as bootstrap from 'bootstrap';
import '@hotwired/turbo-rails';

// Utilities
import './src/utils/accordion';
import './src/utils/autoComplete';
import './src/utils/externalLink';
import './src/utils/modalSearch';
import './src/utils/outOfFocus';
import './src/utils/paginable';
import './src/utils/panelHeading';
import './src/utils/requiredField';
import './src/utils/tabHelper';
import './src/utils/tooltipHelper';
// import './src/utils/cookiebanner';
import './src/utils/autoNumericHelper';

// Specific functions from the Utilities files that will be made available to
// the js.erb templates in the `window.x` statements below
import { renderAlert, renderNotice } from './src/utils/notificationHelper';
import toggleSpinner from './src/utils/spinner';

// View specific JS
import './src/answers/conditions';
import './src/answers/edit';
import './src/devise/invitations/edit';
import './src/devise/passwords/edit';
import './src/devise/registrations/edit';
import './src/devise/registrations/new';
import './src/orgs/adminEdit';
import './src/orgs/shibbolethDs';
import './src/plans/download';
import './src/plans/index';
import './src/plans/researchOutputs';
import './src/plans/share';
import './src/publicTemplates/show';
import './src/roles/edit';
import './src/shared/createAccountForm';
import './src/shared/signInForm';
import './src/usage/index';
import './src/users/adminGrantPermissions';
import './src/users/notificationPreferences';
import './src/shared/navigation.js';

// OrgAdmin view specific JS
import './src/orgAdmin/conditions/updateConditions';
import './src/orgAdmin/phases/newEdit';
import './src/orgAdmin/phases/preview';
import './src/orgAdmin/phases/show';
import './src/orgAdmin/questionOptions/index';
import './src/orgAdmin/questions/sharedEventHandlers';
import './src/orgAdmin/sections/index';
import './src/orgAdmin/templates/edit';
import './src/orgAdmin/templates/index';
import './src/orgAdmin/templates/new';

// SuperAdmin view specific JS
import './src/superAdmin/apiClients/form';
import './src/superAdmin/notifications/edit';
import './src/superAdmin/themes/newEdit';
import './src/superAdmin/users/edit';

import './jquery.js';
import './controllers/index.js';

window.renderAlert = renderAlert;
window.renderNotice = renderNotice;
window.toggleSpinner = toggleSpinner;

window.bootstrap = bootstrap;
