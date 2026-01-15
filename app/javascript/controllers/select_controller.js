import { Controller } from "@hotwired/stimulus"
import * as notifier from '../src/utils/notificationHelper';

export default class extends Controller {
  static values = { url: String }

  update(event) {
    const value = event.target.value

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({ role: { access: value } })
    })
      .then(response => response.json())
      .then(data => {
        if (data.code === 1) {
          notifier.renderNotice(data.msg)
        } else {
          notifier.renderAlert(data.msg)
        }
      })
      .catch(() => {
        notifier.renderAlert("Erreur réseau")
      })
  }
}
