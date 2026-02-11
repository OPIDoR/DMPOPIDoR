import { useContext, useEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";
import { useForm, FormProvider } from "react-hook-form";
import unionBy from "lodash.unionby";

import FormBuilder from "./FormBuilder.jsx";
import { GlobalContext } from "../context/Global.jsx";
import { service } from "../../services/index.js";
import CustomSpinner from "../Shared/CustomSpinner.jsx";
import CustomButton from "../Styled/CustomButton.jsx";
import FormSelector from "./FormSelector";
import { ExternalImport } from "../ExternalImport";
import { getErrorMessage } from "../../utils/utils.js";
import {
  formatDefaultValues,
  generateEmptyDefaults,
} from "../../utils/GeneratorUtils.js";

function DynamicForm({
  fragmentId,
  className,
  setScriptsData = null,
  questionId = null,
  madmpSchemaId = null,
  setAnswer = null,
  formSelector = {},
  readonly,
}) {
  const { t } = useTranslation();
  const {
    formData,
    setFormData,
    dmpId,
    locale,
    displayedResearchOutput,
    researchOutputs,
    setResearchOutputs,
    loadedTemplates,
    setLoadedTemplates,
  } = useContext(GlobalContext);
  const methods = useForm({ defaultValues: {} });
  const [loading, setLoading] = useState(true);
  const [error] = useState(null);
  const [template, setTemplate] = useState(null);
  const [templateId, setTemplateId] = useState(madmpSchemaId);

  /**
   * Memoized values
   */
  const dataType = useMemo(
    () => displayedResearchOutput?.configuration?.dataType || "none",
    [displayedResearchOutput],
  );
  const topic = useMemo(
    () => displayedResearchOutput?.topic || "generic",
    [displayedResearchOutput],
  );

  const externalImports = useMemo(() => {
    return template?.schema?.externalImports || {};
  }, [template]);

  const emptyDefaults = useMemo(
    () => (template ? generateEmptyDefaults(template.schema.properties) : {}),
    [template],
  );

  /**
   * It checks if the form is filled in correctly.
   * @param e - the event object
   */
  const handleSaveForm = async (data) => {
    setLoading(true);
    if (fragmentId) {
      let response;
      try {
        response = await service.saveFragment(fragmentId, data);
      } catch (error) {
        toast.error(getErrorMessage(error));
        return setLoading(false);
      }
      if (response?.data?.meta_fragment) {
        document.getElementById("plan-title").innerHTML =
          response?.data?.meta_fragment?.title;
        setFormData({
          [response?.data?.meta_fragment?.id]: response.data.meta_fragment,
        });
      }
      setFormData({ [fragmentId]: response.data.fragment });
      setLoading(false);
    } else {
      handleSaveNew(data);
    }
  };

  const handleSaveNew = (data) => {
    service
      .createFragment(
        data,
        templateId,
        dmpId,
        questionId,
        displayedResearchOutput.id,
      )
      .then((res) => {
        const updatedResearchOutput = { ...displayedResearchOutput };
        const fragment = res.data.fragment;
        const tplt = res.data.template;
        const answerId = res.data.answer_id;
        setLoadedTemplates({ ...loadedTemplates, [tplt.name]: tplt });
        setTemplate(tplt);
        setFormData({ [fragment.id]: fragment });
        setAnswer({
          id: answerId,
          question_id: questionId,
          fragment_id: fragment.id,
          madmp_schema_id: templateId,
        });
        updatedResearchOutput.answers.push({
          answer_id: answerId,
          question_id: questionId,
          fragment_id: fragment.id,
        });
        setResearchOutputs(
          unionBy(researchOutputs, [updatedResearchOutput], "id"),
        );
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  const setValues = (data) =>
    Object.keys(data).forEach((k) =>
      methods.setValue(k, data[k], { shouldDirty: true }),
    );

  const handleFragmentData = (data) => {
    setFormData({ [fragmentId]: data.fragment });
    if (data.answer_id) {
      const {
        answer_id,
        fragment: { id: fragment_id, schema_id: madmp_schema_id },
      } = data;
      setAnswer({
        id: answer_id,
        question_id: questionId,
        fragment_id,
        madmp_schema_id,
      });
    }
    methods.reset(data.fragment);
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    if (fragmentId) {
      if (formData[fragmentId]) {
        if (loadedTemplates[formData[fragmentId].template_name]) {
          setTemplate(loadedTemplates[formData[fragmentId].template_name]);
        } else {
          service
            .getSchema(formData[fragmentId].schema_id)
            .then((res) => {
              setTemplate(res.data);
              setLoadedTemplates({
                ...loadedTemplates,
                [res.data.name]: res.data,
              });
            })
            .catch(console.error)
            .finally(() => setLoading(false));
        }
        methods.reset({ ...emptyDefaults, ...formData[fragmentId] });
      } else {
        service
          .getFragment(fragmentId)
          .then((res) => {
            setTemplate(res.data.template);
            setLoadedTemplates({
              ...loadedTemplates,
              [res.data.template.name]: res.data.template,
            });
            handleFragmentData(res.data);
          })
          .catch(console.error)
          .finally(() => setLoading(false));
      }
    } else {
      service
        .getNewForm(questionId, displayedResearchOutput.id)
        .then((res) => {
          const tplt = res.data.template;
          setTemplate(tplt);
          setTemplateId(tplt.id);
          setLoadedTemplates({ ...loadedTemplates, [tplt.name]: tplt });
          if (res.data.fragment) handleFragmentData(res.data);
        })
        .catch(console.error)
        .finally(() => setLoading(false));
    }
  }, [fragmentId]);

  useEffect(() => {
    methods.reset({ ...emptyDefaults, ...formData[fragmentId] });
  }, [formData[fragmentId]]);

  useEffect(() => {
    if (
      setScriptsData &&
      template?.schema?.run &&
      template.schema.run.length > 0
    ) {
      setScriptsData({
        scripts: template.schema.run,
        apiClient: template.api_client,
      });
    } else if (setScriptsData) {
      setScriptsData({ scripts: [] });
    }
  }, [template]);

  useEffect(() => {
    if (!fragmentId && template) {
      const defaults = formatDefaultValues(template.schema.default?.[locale]);
      Object.keys(defaults).length > 0
        ? methods.reset(defaults)
        : methods.reset(generateEmptyDefaults(template.schema.properties));
    }
  }, [template, fragmentId]);

  /**
   * RENDERING
   */

  return (
    <>
      {loading && <CustomSpinner isOverlay={true} />}
      {error && <p>error</p>}
      {!error && template && (
        <>
          {!readonly && Object.keys(externalImports)?.length > 0 && (
            <ExternalImport
              fragment={methods}
              setFragment={setValues}
              externalImports={externalImports}
              locale={locale}
            />
          )}
          {!readonly && !fragmentId && template.topics.includes("generic") && (
            <FormSelector
              classname={className}
              dataType={dataType}
              topic={topic}
              displayedTemplate={template}
              setTemplateId={setTemplateId}
              setTemplate={setTemplate}
              formSelector={formSelector}
            />
          )}
          <FormProvider {...methods}>
            <form
              style={{ margin: "15px" }}
              onSubmit={methods.handleSubmit((data) => handleSaveForm(data))}
            >
              <div className="m-4">
                <FormBuilder
                  template={template.schema}
                  dataType={dataType}
                  topic={topic}
                  readonly={readonly}
                />
              </div>
              {!readonly && (
                <CustomButton
                  handleClick={null}
                  title={t("save")}
                  buttonType="submit"
                  position="center"
                  sticky={true}
                />
              )}
            </form>
          </FormProvider>
        </>
      )}
    </>
  );
}

export default DynamicForm;
