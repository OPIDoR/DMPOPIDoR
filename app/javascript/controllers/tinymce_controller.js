import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input'];

  static values = {
    callback: Boolean,
    selector: String,
  };

  initialize() {
    this.defaults = {
      license_key: 'gpl',
      selector: this.hasSelectorValue ? this.selectorValue : '.tinymce',
      statusbar: true,
      menubar: false,
      toolbar: 'bold italic underline | fontfamily fontsize | fontsizeselect forecolor | alignleft aligncenter alignright alignjustify | subscript superscript | bullist numlist indent outdent | link | table | charmap',
      plugins: 'table autoresize link advlist lists autolink charmap',
      browser_spellcheck: true,
      advlist_bullet_styles: 'circle,disc,square', // Only disc bullets display on htmltoword
      target_list: false,
      elementpath: false,
      resize: true,
      min_height: 230,
      width: '100%',
      autoresize_bottom_margin: 10,
      branding: false,
      extended_valid_elements: 'iframe[tooltip] , a[href|target=_blank]',
      invalid_elements: 'pre',
      paste_as_text: false,
      paste_block_drop: true,
      paste_merge_formats: true,
      paste_tab_spaces: 4,
      smart_paste: true,
      paste_data_images: true,
      paste_remove_styles_if_webkit: true,
      paste_webkit_styles: 'none',
      table_default_attributes: {
        border: 1,
      },
      // editorManager.baseURL is not resolved properly for IE since document.currentScript
      // is not supported, see issue https://github.com/tinymce/tinymce/issues/358
      skin_url: '/tinymce/skins/oxide',
      content_css: [],
    };
  }

  connect() {
    const config = {
      target: this.inputTarget,
      setup: (editor) => {
        editor.on('Change', () => {
          if (this.callbackValue) {
            this.handleChange(editor);
          }
        });
      },
      ...this.defaults,
    };
    tinymce.init(config);
  }

  disconnect() {
    if (!this.preview) tinymce.remove();
  }

  handleChange(editor) {
    const textEditor = editor.targetElm;
    // Remonte jusqu'au fieldset parent
    const fieldset = textEditor.closest('fieldset');
    if (!fieldset) return;
    // Trouve le champ caché dont l'ID se termine par "_destroy"
    const hiddenField = Array.from(fieldset.querySelectorAll('input[type="hidden"]'))
      .find(input => input.id.endsWith('_destroy'));
    if (hiddenField) {
      hiddenField.value = editor.getContent() === '' ? '1' : '0';
    }
  }

  get preview() {
    return (
      document.documentElement.hasAttribute('data-turbolinks-preview') ||
      document.documentElement.hasAttribute('data-turbo-preview')
    );
  }

}
