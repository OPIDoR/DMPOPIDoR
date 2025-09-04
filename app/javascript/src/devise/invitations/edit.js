import { initAutocomplete } from '../../utils/autoComplete';

document.addEventListener('turbo:load', () => {
  initAutocomplete('#invite-org-controls .autocomplete');
});
