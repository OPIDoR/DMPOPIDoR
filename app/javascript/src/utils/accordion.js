document.addEventListener('turbo:load', () => $('body').on('click', '.accordion-controls a[data-toggle-direction]', (e) => {
  e.preventDefault();
  const currentTarget = $(e.currentTarget);
  const target = $(e.target);
  const direction = target.attr('data-toggle-direction');
  const parentTargetName = currentTarget.parent().attr('data-bs-parent');

  if (direction) {
    // Selects all .accordion-item elements where the parent is
    // currentTarget.attr('data-parent') and
    // after gets the immediate children whose class selector is accordion-item
    const parentTarget = $(`#${parentTargetName}`).length ? $(`#${parentTargetName}`) : $(`.${parentTargetName}`);
    parentTarget.find('.accordion-item').each((i, el) => {
      const accordionCollapse = $(el).children('.accordion-collapse').get(0);

      let bsCollapse = bootstrap.Collapse.getInstance(accordionCollapse);
      if (!bsCollapse) {
        bsCollapse = new bootstrap.Collapse(accordionCollapse, { toggle: false });
      }

      if (direction === 'show') {
        bsCollapse.show();
      } else if (direction === 'hide') {
        bsCollapse.hide();
      }
    });
  }
}));
