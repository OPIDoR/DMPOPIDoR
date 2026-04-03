import { eachLinks } from '../../utils/links';
import { isObject, isString } from '../../utils/isType';
import { renderNotice, renderAlert } from '../../utils/notificationHelper';
import { scrollTo } from '../../utils/scrollTo';

document.addEventListener('turbo:load', () => {
  $('.edit_template').on('ajax:before', () => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
  });
  $('.edit_template').on('ajax:success', (e) => {
    const data = e.detail[0];
    if (isObject(data) && isString(data.msg)) {
      if (data.status === 200) {
        renderNotice(data.msg);
      } else {
        renderAlert(data.msg);
      }
      scrollTo('#notification-area');
    }
  });
  $('.edit_template').on('ajax:error', (e) => {
    const xhr = e.detail[2];
    const error = xhr.responseJSON;
    if (isObject(error) && isString(error)) {
      renderAlert(error.msg);
      scrollTo('#notification-area');
    }
  });
});
