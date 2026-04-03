import { addMatchingPasswordValidator, togglisePasswords } from '../../utils/passwordHelper';

document.addEventListener('turbo:load', () => {
  addMatchingPasswordValidator({ selector: '#user_reset_password_form' });
  togglisePasswords({ selector: '#user_reset_password_form' });
});
