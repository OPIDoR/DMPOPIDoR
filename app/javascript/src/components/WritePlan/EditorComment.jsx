import React from 'react';
import { Editor } from '@tinymce/tinymce-react';

/**
 * A function that takes in an argument called content and then calls the updateParentText function with the content as the argument.
 */
const EditorComment = ({ initialValue, updateParentText }) => {
  const handleEditorChange = (content) => {
    updateParentText(content);
  };

  return (
    <Editor
      onEditorChange={handleEditorChange}
      initialValue={initialValue}
      licenseKey='gpl'
      init={{
        branding: false,
        height: 200,
        menubar: false,
        elementpath: false,
        plugins: 'table autoresize link advlist lists',
        toolbar: 'bold italic underline | fontsizeselect forecolor | bullist numlist | link | table',
        content_style: 'body { font-family:Helvetica,Arial,sans-serif; font-size:14px }',
        skin_url: '/tinymce/skins/oxide',
        forced_root_block: '\r',
        content_css: [],
      }}
    />
  );
};

export default React.memo(EditorComment);
