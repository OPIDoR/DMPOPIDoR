import { isObject, isUndefined } from '../utils/isType';
import { initializeCharts, createChart, drawHorizontalBar } from '../utils/charts';

document.addEventListener('turbo:load', () => {
  // handles the checkbox for filtered-plans
  $('#filter_plans_form').on('click, change', 'input[type="checkbox"]', (e) => {
    const form = $(e.target).closest('form');
    form.trigger('submit');
  });

  // fns to handle the separator character menu
  // for CSV download
  const changeStatFnGen = (str) => {
    const fn = (item) => {
      /* eslint no-param-reassign: ["error", { "props": false }] */
      item.href = item.href.replace(/sep=.*/, str);
    };
    return fn;
  };

  // attach listener to separator select menu
  // on change look for "stat" elements and chnage their query param
  const fieldSep = document.getElementById('csv-field-sep');
  if (fieldSep !== null) {
    fieldSep.addEventListener('click', (e) => {
      const statElems = document.getElementsByClassName('stat');
      const newSep = 'sep='.concat(encodeURIComponent(e.target.value));
      const changeStatFn = changeStatFnGen(newSep);
      Array.from(statElems).forEach(changeStatFn);
    });
  }

  initializeCharts();

  const labelToUrl = (label) => {
    const parts = label.split('-');
    return `search=${parts[0]} 20${parts[1]}&commit=Search&click_through=true`;
  };

  // Create the Users joined chart
  if (!isUndefined($('#users_joined').val())) {
    const usersData = JSON.parse($('#users_joined').val());
    if (isObject(usersData)) {
      const chart = createChart('#yearly_users', usersData, '', (event) => {
        const segment = chart.getElementAtEvent(event)[0];
        if (!isUndefined(segment)) {
          const target = $('#users_click_target').val();
          /* eslint-disable no-underscore-dangle, no-restricted-globals */
          const label = chart.data.labels[segment._index];
          $(location).attr('href', `${target}?${labelToUrl(label)}`);
          /* eslint-enable no-underscore-dangle, no-restricted-globals */
        }
      });
    }
  }

  // Create the Plans created chart
  if (!isUndefined($('#plans_created').val())) {
    const plansData = JSON.parse($('#plans_created').val());
    if (isObject(plansData)) {
      const chart = createChart('#yearly_plans', plansData, '', (event) => {
        const segment = chart.getElementAtEvent(event)[0];
        if (!isUndefined(segment)) {
          const target = $('#plans_click_target').val();
          /* eslint-disable no-underscore-dangle, no-restricted-globals */
          const label = chart.data.labels[segment._index];
          $(location).attr('href', `${target}?${labelToUrl(label)}`);
          /* eslint-enable no-underscore-dangle, no-restricted-globals */
        }
      });
    }
  }
});
