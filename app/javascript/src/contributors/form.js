import { initAutocomplete } from '../utils/autoComplete';

document.addEventListener('turbo:load', () => {
  initAutocomplete('#contributor-org-controls .autocomplete');
});
