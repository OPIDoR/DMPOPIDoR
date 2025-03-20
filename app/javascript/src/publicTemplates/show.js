$(() => {
  $('body').on('click', '.copy-link', (e) => {
    const link = $(e.currentTarget).siblings('.direct-link');
    $('#link').val(link.attr('href'));
    $('#link-modal').show();
  });

  $('body').on('click', '#copy-link-btn', () => {
    navigator.clipboard.writeText($('#link').val());
  });
});
