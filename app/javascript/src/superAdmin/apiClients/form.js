import { initAutocomplete } from '../../utils/autoComplete';

document.addEventListener('turbo:load', () => {
  if ($('#api-client-org-controls').length > 0) {
    initAutocomplete('#api-client-org-controls .autocomplete');
  }
});
