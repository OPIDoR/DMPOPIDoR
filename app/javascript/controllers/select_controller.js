import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  update(event) {
    fetch(this.element.dataset.url, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'text/vnd.turbo-stream.html',
      },
      body: JSON.stringify({ role: { access: event.target.value } }),
    });
  }
}
