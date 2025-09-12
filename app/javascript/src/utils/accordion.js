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
    parentTarget.each((i, parent) => {
      $(parent).find('.accordion-item').each((j, el) => {
        // We use $() to get Jquery HTML element from native Dom element
        const accordionItem = $(el);
        // Not these are Jquery HTML elements, again using $()
        const accordionHeader = $(accordionItem.children('.accordion-header').get(0));
        const accordionButton = $(accordionHeader.children('.accordion-button').get(0));
        const accordionCollapse = accordionItem.find('.accordion-collapse').first();
        // Expands or collapses according to the
        // direction passed (e.g. show --> expands, hide --> collapses)
        if (direction === 'show') {
          // To check if element with class .accordion-body has attribute data-loaded
          // we use the native Dom element so we can use hasAttribute()
          // and getAttribute() methods.
          const accordionBodyNativeDomEl = accordionCollapse.find('.accordion-body').get(0);
          if (accordionBodyNativeDomEl &&
            accordionBodyNativeDomEl.hasAttribute('data-loaded') &&
            accordionBodyNativeDomEl.getAttribute('data-loaded') === 'false') {
            // We need the native om element of the button to
            // to trigger click as the jquery trigger('click')
            // does not work for rails-ujs
            const accordionButtonNativeDomEl = accordionHeader.children('.accordion-button').get(0);
            accordionButtonNativeDomEl.click();
          }
          accordionButton.removeClass('collapsed');
          accordionCollapse.addClass('show');
        }

        if (direction === 'hide') {
          accordionButton.addClass('collapsed');
          accordionCollapse.removeClass('show');
        }
      });
    });
  }
}));
