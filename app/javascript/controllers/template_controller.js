// controllers/accordion_loader_controller.js
import { Controller } from "@hotwired/stimulus";
import { Collapse } from "bootstrap";

export default class extends Controller {
  openSection(event) {
    // Laisse Turbo gérer la navigation
    // Mais déclenche manuellement le collapse
    const targetId = this.element.getAttribute("aria-controls");
    const collapseEl = document.getElementById(targetId);

    if (collapseEl) {
      new Collapse(collapseEl, { toggle: true });
    }
  }
}
