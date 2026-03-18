import React, { useRef } from 'react';
import { useFormContext, useController } from 'react-hook-form';
import { Editor } from '@tinymce/tinymce-react';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import { useTranslation } from 'react-i18next';
import uniqueId from 'lodash.uniqueid';
import DOMPurify from 'dompurify';
import styled from 'styled-components';
import TooltipInfoIcon from './TooltipInfoIcon.jsx';

import * as styles from '../assets/css/form.module.css';

const ReadDiv = styled.div`
  border: solid;
  border-color: var(--dark-blue);
  border-width: 1px;
  padding: 20px;
  margin-bottom: 10px;
  color: var(--dark-blue);
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  background: #f2f2f2;
`;

/* This is a React functional component that renders a TinyMCE editor for text input. It receives several props including `label`, `name`, `changeValue`,
`tooltip` and `schemaId`. It uses the `useContext` hook to access the `form` and `temp` values from the `GlobalContext`. It also uses the
`useState` hook to set the initial state of the `text` variable to `<p></p>`. */
function TinyArea({
  label,
  propName,
  tooltip,
  placeholder,
  readonly = false,
}) {
  const { t } = useTranslation();
  const { control } = useFormContext();
  const { field } = useController({ control, name: propName, defaultValue: '' });
  const { onChange, ...newField } = field;
  const tinyAreaLabelId = uniqueId('tiny_area_tooltip_id_');
  const editorRef = useRef(null);

  return (
    <div className={'form-group ticket-summernote mr-4 ml-4'}>
      <div className="row">
        <div className={styles.label_form}>
          <label data-tooltip-id={tinyAreaLabelId}>
            {label}
            {tooltip && (<TooltipInfoIcon />)}
          </label>
          {
            tooltip && (
              <ReactTooltip
                id={tinyAreaLabelId}
                place="bottom"
                effect="solid"
                variant="info" style={{ width: '300px', textAlign: 'center' }}
                content={tooltip}
              />
            )
          }
        </div>

        <div style={{ marginTop: '10px' }} key={field.id} ref={editorRef}>
          {!readonly && (
            <Editor
              {...newField}
              onEditorChange={(newText) => onChange(newText)}
              licenseKey='gpl'
              init={{
                placeholder: placeholder ? `${t('eg')} ${placeholder}` : null,
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
              }}
            />
          )}
          {readonly && (
            <ReadDiv
              dangerouslySetInnerHTML={{
                __html: DOMPurify.sanitize([field.value]),
              }}
            />
          )}
        </div>
      </div>
    </div>
  );
}

export default TinyArea;
