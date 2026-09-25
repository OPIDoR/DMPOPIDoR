import {
  initAutocomplete,
  scrubOrgSelectionParamsOnSubmit,
} from "../../utils/autoComplete";

document.addEventListener("turbo:load", () => {
  if (document.querySelector("#super-admin-user-org-controls")) {
    initAutocomplete("#super-admin-user-org-controls .autocomplete");
    scrubOrgSelectionParamsOnSubmit("#super_admin_user_edit");
  }
});
