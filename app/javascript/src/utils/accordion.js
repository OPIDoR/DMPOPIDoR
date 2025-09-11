document.addEventListener('turbo:load', () => {
  $('body').on('click', '.accordion-controls a[data-toggle-direction]', (e) => {
    e.preventDefault();

    const $link = $(this);
    const direction = $link.attr('data-toggle-direction');
    const parentAccordionId = $link.closest('.accordion-controls').attr('data-bs-parent');

    if (!direction || !parentAccordionId) return;

    const $parentAccordion = $(`#${parentAccordionId}`);
    if (!$parentAccordion.length) return;

    $parentAccordion.find('.accordion-item').each(() => {
      const $item = $(this);
      const $button = $item.find('.accordion-button').first();
      const $collapse = $item.find('.accordion-collapse').first();
      const accordionBody = $collapse.find('.accordion-body').get(0);

      if (direction === 'show') {
        if (accordionBody && accordionBody.getAttribute('data-loaded') === 'false') {
          $button.get(0).click();
        }
        $button.removeClass('collapsed');
        $collapse.addClass('show');
      }

      if (direction === 'hide') {
        $button.addClass('collapsed');
        $collapse.removeClass('show');
      }
    });
  });
});
