import { Controller } from '@hotwired/stimulus';
import * as notifier from '../src/utils/notificationHelper';

export default class extends Controller {
  static targets = ['checkbox'];

  toggle() {
    const checked = this.checkboxTarget.checked;

    // Envoi de la requête POST avec l'état de la checkbox
    fetch(this.data.get('url'), {
      method: this.data.get('method') || 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content,
      },
      body: JSON.stringify({ checked }),
    })
      .then((response) => response.json())
      .then((data) => {
        notifier.renderNotice(data.msg);
      })
      .catch((error) => notifier.renderAlert(error.msg));
  }
}
