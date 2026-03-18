import React, { useContext, useEffect } from 'react';
import { useForm, FormProvider } from 'react-hook-form';
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';
import { useTranslation } from 'react-i18next';

import { GlobalContext } from '../context/Global.jsx';
import FormBuilder from './FormBuilder';
import { ExternalImport } from '../ExternalImport';
import { formatDefaultValues } from '../../utils/GeneratorUtils';

function ModalForm({
  data, template, mainFormDataType, mainFormTopic, label, readonly, show, handleSave, handleClose,
}) {
  const { t } = useTranslation();
  const {
    locale,
  } = useContext(GlobalContext);
  const methods = useForm({ defaultValues: data });

  const externalImports = template?.schema?.externalImports || {};

  useEffect(() => {
    if (Object.keys(methods.formState.dirtyFields).length > 0) {
      methods.reset(methods.formState.dirtyFields);
    }
  }, [data]);

  useEffect(() => {
    if (!data?.id && template) {
      methods.reset(formatDefaultValues(template.schema.default?.[locale]));
    }
  }, [template, data]);

  const onValid = (formData) => {
    handleSave(formData);
    methods.reset();
  };

  const onInvalid = () => {
    console.log('Modal form errors', methods.errors);
  };

  const handleModalSubmit = (e) => {
    e.stopPropagation();
    methods.handleSubmit(onValid, onInvalid)(e);
  };

  const handleModalClose = () => {
    handleClose();
    methods.reset();
  };

  const setValues = (data) => Object.keys(data)
    .forEach((k) => methods.setValue(k, data[k], { shouldDirty: true }));

  return (
    <Modal enforceFocus={false} size="xl" className="dmpopidor-branding" show={show} backdrop={ 'static' } onHide={handleModalClose}>
      <Modal.Header>
        <Modal.Title style={{ color: 'var(--rust)', fontWeight: 'bold' }}>{label}</Modal.Title>
      </Modal.Header>
      <Modal.Body style={{ padding: '20px !important' }}>
        {Object.keys(externalImports)?.length > 0 && <ExternalImport fragment={methods} setFragment={setValues} externalImports={externalImports} locale={locale} />}
        <FormProvider {...methods}>
          <form name="modal-form" id="modal-form" style={{ margin: '15px' }} onSubmit={(e) => handleModalSubmit(e)}>
            <FormBuilder
              template={template.schema}
              dataType={mainFormDataType}
              topic={mainFormTopic}
              readonly={readonly}
            />
          </form>
        </FormProvider>
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={handleModalClose}>
          {t('close')}
        </Button>
        {!readonly && (
          <Button variant="primary" type="submit" form="modal-form" disabled={!methods.formState.isDirty}>
            {t('save')}
          </Button>
        )}
      </Modal.Footer>
    </Modal>
  );
}

export default ModalForm;
