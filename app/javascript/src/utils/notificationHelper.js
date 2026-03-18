import { isString } from './isType';

/*
  Helpers that will display the specified message in in the notification
  area at the top of the page
*/

export function hideNotifications() {
  $('#notification-area')
    .addClass('d-none')
    .removeClass('notification-area--floating');
}

function renderMessage(options = {}) {
  const notificationArea = $('#notification-area');

  if (!isString(options.message) || notificationArea.length === 0) return;
  notificationArea
    .removeClass('alert-info alert-warning')
    .addClass(options.className);

  if (options.floating) {
    notificationArea.addClass('notification-area--floating');
  }

  notificationArea.find('i, span').remove();
  notificationArea.append(`
      <i class="fas fa-${options.icon}" aria-hidden="true"></i>
      <span>${options.message}</span>
    `);

  notificationArea.removeClass('d-none');

  if (options.autoDismiss) {
    setTimeout(() => { hideNotifications(); }, 5000);
  }
}

export function renderNotice(msg, options = {}) {
  renderMessage({
    message: msg,
    icon: 'circle-check',
    className: 'alert-info',
    floating: options.floating === true,
    autoDismiss: options.autoDismiss === true,
  });
}

export function renderAlert(msg, options = {}) {
  renderMessage({
    message: msg,
    icon: 'circle-xmark',
    className: 'alert-warning',
    floating: options.floating === true,
    autoDismiss: options.autoDismiss === true,
  });
}
