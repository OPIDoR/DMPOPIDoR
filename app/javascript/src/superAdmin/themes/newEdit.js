import { Tinymce } from '../../utils/tinymce.js';

$(() => {
  Tinymce.init({ selector: '#theme_description' });

  const sortableThemes = () => {
    $('#themes').sortable({
      items: '.theme',
      handle: '.theme-actions .handle',
      update: () => {
        const updatedOrder = [];
        $('#themes .theme').each(function callback() {
          updatedOrder.push($(this).find('.handle').data('theme-id'));
        });
        $.ajax({
          url: '/super_admin/themes/sort',
          method: 'post',
          data: {
            updated_order: updatedOrder,
          },
        });
      }
    });
  };
  
  // Needs to re-apply sortable function after ajax paginable call
  $('body').on('ajax:success',
    'a.paginable-action[data-remote="true"]',
    sortableThemes);
  sortableThemes();
});
