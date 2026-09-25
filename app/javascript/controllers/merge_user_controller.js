import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["userSelect", "submitButton", "editingUserEmail"];

  connect() {
    // Appelé automatiquement quand le DOM est injecté par Turbo Stream
    this.updateConfirmation();
  }

  updateConfirmation() {
    if (!this.hasUserSelectTarget || !this.hasSubmitButtonTarget) return;

    const editingUserEmail = this.editingUserEmailTarget.value;
    const chosenUserEmail =
      this.userSelectTarget.options[this.userSelectTarget.selectedIndex]?.text;

    this.submitButtonTarget.dataset.turboConfirm =
      `Confirm Account Merge: The account for ${editingUserEmail} will be merged with ${chosenUserEmail}. ` +
      `All plans and account information for ${chosenUserEmail} will now be accessible via ${editingUserEmail}. ` +
      `The account for ${chosenUserEmail} will then be destroyed.`;
  }
}
