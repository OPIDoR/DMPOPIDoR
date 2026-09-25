import { Controller } from "@hotwired/stimulus";
import { drawHorizontalBar } from "../src/utils/charts";

export default class extends Controller {
  static values = { data: Object };

  static targets = ["canvas"];

  connect() {
    this.destroyChart();
    this.drawChart();
  }

  disconnect() {
    this.destroyChart();
  }

  destroyChart() {
    if (this.chart) {
      this.chart.clear();
      this.chart.destroy();
      this.chart = null;
    }
  }

  drawChart() {
    this.chart = drawHorizontalBar(this.canvasTarget, this.dataValue);
  }
}
