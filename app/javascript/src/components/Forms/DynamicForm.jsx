import { useContext, useEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";
import { useForm, FormProvider } from "react-hook-form";
import unionBy from "lodash.unionby";

import FormBuilder from "./FormBuilder.jsx";
import { GlobalContext } from "../context/GlobalContext.jsx";
import { FormsContext } from "../context/FormsContext.jsx";
import { SectionsContext } from "../context/SectionsContext.jsx";
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
  const { dmpId, locale } = useContext(GlobalContext);
  const { formData, setFormData, loadedTemplates, setLoadedTemplates } =
    useContext(FormsContext);
  const { displayedResearchOutput, researchOutputs, setResearchOutputs } =
    useContext(SectionsContext);
  const methods = useForm({ defaultValues: {} });
  const [loading, setLoading] = useState(true);
  const [templateName, setTemplateName] = useState(null);
  const [newFragmentSaved, setNewFragmentSaved] = useState(false);

  /**
   * Memoized values
   */
  const template = useMemo(() => {
    if (fragmentId && formData[fragmentId]) {
      return loadedTemplates[formData[fragmentId].template_name] ?? null;
    }
    if (!fragmentId && templateName) {
      return loadedTemplates[templateName] ?? null;
    }
    return null;
  }, [fragmentId, formData, loadedTemplates, templateName]);

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

  const templateId = template?.id || madmpSchemaId;
  const topics = template?.topics || [];

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
        handleError(error);
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
        setTemplateName(tplt.name);
        setLoadedTemplates((prev) => ({ ...prev, [tplt.name]: tplt }));
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
        setNewFragmentSaved(true);
        methods.reset(fragment);
      })
      .catch((error) => handleError(error))
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

  const handleError = (error) => toast.error(getErrorMessage(error));
  /**
   * USE EFFECTS
   */

  /*#################FORM DATA LOADING#####################*/
  // Case 1 : new form (fragmentId is null)
  useEffect(() => {
    if (fragmentId) return;

    service
      .getNewForm(questionId, displayedResearchOutput.id)
      .then((res) => {
        const tplt = res.data.template;
        setTemplateName(tplt.name);
        setLoadedTemplates((prev) => ({ ...prev, [tplt.name]: tplt }));
        if (res.data.fragment) handleFragmentData(res.data);
      })
      .catch((error) => handleError(error))
      .finally(() => setLoading(false));
  }, [fragmentId, questionId, displayedResearchOutput.id]);

  // Case 2 : fragmentId is present but form data is not loaded, fetching fragment
  useEffect(() => {
    if (!fragmentId || formData[fragmentId]) return;

    service
      .getFragment(fragmentId)
      .then((res) => {
        setTemplateName(res.data.template.name);
        setLoadedTemplates((prev) => ({
          ...prev,
          [res.data.template.name]: res.data.template,
        }));
        handleFragmentData(res.data);
      })
      .catch((error) => toast.error(getErrorMessage(error)))
      .finally(() => setLoading(false));
  }, [fragmentId, formData]);

  // Case 3 : formData is loaded but template is not, fetching template
  useEffect(() => {
    if (!fragmentId) return;
    if (!formData[fragmentId]) return;
    if (loadedTemplates[formData[fragmentId].template_name]) return;

    service
      .getSchema(formData[fragmentId].schema_id)
      .then((res) => {
        setTemplateName(res.data.name);
        setLoadedTemplates((prev) => ({ ...prev, [res.data.name]: res.data }));
      })
      .catch((error) => toast.error(getErrorMessage(error)))
      .finally(() => setLoading(false));
  }, [fragmentId, formData, loadedTemplates]);

  // Case 4 : everything if loaded but we need to set loading to false
  useEffect(() => {
    if (!fragmentId) return;
    if (!formData[fragmentId]) return;
    if (!loadedTemplates[formData[fragmentId].template_name]) return;

    Promise.resolve().then(() => setLoading(false));
  }, [fragmentId, formData, loadedTemplates]);
  /*#################FORM DATA LOADING#####################*/

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
    methods.reset({ ...emptyDefaults, ...formData[fragmentId] });
  }, [formData[fragmentId]]);

  useEffect(() => {
    if (!fragmentId && template && !newFragmentSaved) {
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
      {template && (
        <>
          {!readonly && Object.keys(externalImports)?.length > 0 && (
            <ExternalImport
              fragment={methods}
              setFragment={setValues}
              externalImports={externalImports}
              locale={locale}
            />
          )}
          {!readonly && !fragmentId && topics.includes("generic") && (
            <FormSelector
              classname={className}
              dataType={dataType}
              topic={topic}
              displayedTemplate={template}
              setTemplateName={setTemplateName}
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
