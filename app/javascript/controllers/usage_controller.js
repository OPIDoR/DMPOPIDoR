import { Controller } from '@hotwired/stimulus';
import { drawHorizontalBar } from '../src/utils/charts';

export default class extends Controller {
  static values = { data: Object };

  static targets = ['canvas'];

  connect() {
    this.destroyChart();
    this.drawChart();
  }

  disconnect() {
    this.destroyChart();
  }

  destroyChart() {
    console.log('Destroying chart if it exists', this.chart);
    if (this.chart) {
      this.chart.clear();
      this.chart.destroy();
      this.chart = null;
    }
  }

  drawChart() {
    console.log('Drawing chart', this.chart);
    this.chart = drawHorizontalBar(
      this.canvasTarget,
      this.dataValue,
    );
  }
}
