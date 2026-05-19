import { useContext, useEffect } from "react";
import { createPortal } from "react-dom";
import { useForm, FormProvider } from "react-hook-form";
import { useTranslation } from "react-i18next";
import Button from "react-bootstrap/Button";

import { GlobalContext } from "../context/GlobalContext.jsx";
import { ExternalImport } from "../ExternalImport";
import * as styles from "../assets/css/form.module.css";
import FormBuilder from "./FormBuilder";
import { formatDefaultValues } from "../../utils/GeneratorUtils";
import { useFormValues } from "../../hooks/useFormValues.js";

function NestedForm({
  propName,
  data,
  template,
  mainFormDataType,
  mainFormTopic,
  readonly,
  handleSave,
  handleClose,
}) {
  const { t } = useTranslation();
  const { locale } = useContext(GlobalContext);
  const methods = useForm({ defaultValues: data });
  const { setValues } = useFormValues(methods);

  const externalImports = template?.schema?.externalImports || {};

  const onValid = (formData) => {
    handleSave(formData);
  };

  const onInvalid = () => {
    console.log("Modal form errors", methods.errors);
  };

  const handleNestedFormSubmit = (e) => {
    e.stopPropagation();
    methods.handleSubmit(onValid, onInvalid)(e);
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    if (!data && template) {
      methods.reset(formatDefaultValues(template.schema.default?.[locale]));
    } else {
      methods.reset(data);
    }
  }, [template, data]);

  /**
   * RENDERING
   */

  return createPortal(
    <>
      {Object.keys(externalImports)?.length > 0 && (
        <div style={{ marginTop: "20px" }}>
          <ExternalImport
            fragment={methods}
            setFragment={setValues}
            externalImports={externalImports}
            locale={locale}
          />
        </div>
      )}
      <FormProvider {...methods}>
        <form
          name="nested-form"
          id="nested-form"
          style={{ margin: "15px" }}
          onSubmit={(e) => handleNestedFormSubmit(e)}
        >
          <FormBuilder
            template={template.schema}
            dataType={mainFormDataType}
            topic={mainFormTopic}
            readonly={readonly}
          />
        </form>
        <div className={styles.nestedFormFooter}>
          <Button onClick={handleClose} style={{ margin: "0 5px 0 5px" }}>
            {t("cancel")}
          </Button>
          {!readonly && (
            <Button
              variant="primary"
              type="submit"
              form="nested-form"
              style={{ margin: "0 5px 0 5px" }}
              disabled={!methods.formState.isDirty}
            >
              {t("save")}
            </Button>
          )}
        </div>
      </FormProvider>
    </>,
    document.getElementById(`nested-form-${propName}`),
  );
}

export default NestedForm;
