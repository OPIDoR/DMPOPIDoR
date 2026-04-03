import { Application } from "@hotwired/stimulus";

import CheckboxController from './checkbox_controller.js';
import ReactController from './react_controller.js';
import ResetFormController from './reset_form_controller.js';
import SelectController from './select_controller.js';
import TinyMceController from './tinymce_controller.js';
import TemplateController from './template_controller.js';
import UsageController from './usage_controller.js';

window.Stimulus = Application.start();

window.Stimulus.register('checkbox', CheckboxController);
window.Stimulus.register('react', ReactController);
window.Stimulus.register('resetForm', ResetFormController);
window.Stimulus.register('select', SelectController);
window.Stimulus.register('tinymce', TinyMceController);
window.Stimulus.register('template', TemplateController);
window.Stimulus.register('usage', UsageController);
