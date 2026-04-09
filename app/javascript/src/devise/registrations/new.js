import { initAutocomplete } from "../../utils/autoComplete";

document.addEventListener("turbo:load", () => {
  // Org selector on the /users/sign_up page that loads after a user
  // signs in via institutional credentials but has no matching user record
  initAutocomplete("#create-account-org-controls .autocomplete");
});
