import { eachLinks } from '../../utils/links';

document.addEventListener('turbo:load', () => {
  $('.new_template').on('submit', () => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
  });
});
