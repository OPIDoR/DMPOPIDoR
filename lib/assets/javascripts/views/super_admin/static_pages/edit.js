import ariatiseForm from '../../../utils/ariatiseForm';
import { Tinymce } from '../../../utils/tinymce';

$(() => {
  Tinymce.init({
    selector: '.content-editor',
    forced_root_block: '',
    toolbar: 'bold italic underline | formatselect | bullist numlist',
  });
  ariatiseForm({ selector: 'form.static_page' });
});
