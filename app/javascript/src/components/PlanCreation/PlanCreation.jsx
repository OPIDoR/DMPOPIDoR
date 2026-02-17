import React, { useContext, useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import { Step, Stepper } from "./BootstrapStepper.jsx";
import { Toaster } from "react-hot-toast";

import { CustomButton } from "../Styled";
import {
  ActionSelection,
  ContextSelection,
  TemplateSelection,
  FormatSelection,
  LangSelection,
  Import,
} from "./Steps";
import * as stepperStyles from "../assets/css/stepper.module.css";
import { GlobalContext } from "../context/GlobalContext.jsx";

const toastOptions = {
  duration: 5000,
};

function PlanCreation({ locale = "en_GB" }) {
  const { t, i18n } = useTranslation();
  const { setLocale } = useContext(GlobalContext);

  /**
   * States
   */
  const [currentAction] = useState(
    () => localStorage.getItem("action") || "create",
  );
  const [params, setParams] = useState({
    action: currentAction,
    researchContext: null,
    templateLanguage: null,
    selectedTemplate: null,
    format: null,
    templateName: null,
    isStructured: null,
  });

  const [currentStep, setCurrentStep] = useState(0);

  /**
   * Memoized values
   */

  const actions = useMemo(
    () => ({
      import: t("importAnExistingPlan"),
      create: t("createNewPlan"),
    }),
    [t],
  );

  const formats = useMemo(
    () => ({
      standard: t("dmpOpidorFormat"),
      rda: t("rdaDmpCommonStandardFormat"),
    }),
    [t],
  );

  const context = useMemo(
    () => ({
      research_project: t("forProject"),
      research_entity: t("forEntity"),
    }),
    [t],
  );

  const languages = useMemo(
    () => ({
      "fr-FR": "Français",
      "en-GB": "English (UK)",
    }),
    [],
  );

  const stepComponents = useMemo(
    () => ({
      ActionSelection: <ActionSelection />,
      ContextSelection: <ContextSelection />,
      LangSelection: <LangSelection />,
      TemplateSelection: <TemplateSelection />,
      FormatSelection: <FormatSelection />,
      Import: <Import />,
    }),
    [],
  );

  const steps = useMemo(
    () => [
      {
        label: t("actionSelection"),
        component: stepComponents.ActionSelection,
        value: actions[params.action],
        set: (action) =>
          setParams((prev) => ({
            ...prev,
            action,
          })),
        actions: ["create", "import"],
      },
      {
        label: t("contextSelection"),
        component: stepComponents.ContextSelection,
        value: context[params.researchContext],
        set: (researchContext) =>
          setParams((prev) => ({
            ...prev,
            researchContext,
          })),
        actions: ["create", "import"],
      },
      {
        label: t("languageSelection"),
        component: stepComponents.LangSelection,
        value: languages[params.templateLanguage],
        set: (templateLanguage) =>
          setParams((prev) => ({
            ...prev,
            templateLanguage,
          })),
        actions: ["create", "import"],
      },
      {
        label: t("templateSelection"),
        component: stepComponents.TemplateSelection,
        value: params.templateName,
        set: (selectedTemplate, templateName) =>
          setParams((prev) => ({
            ...prev,
            selectedTemplate,
            templateName,
          })),
        actions: ["create"],
      },
      {
        label: t("formatSelection"),
        component: stepComponents.FormatSelection,
        value: formats[params.format],
        set: (format) =>
          setParams((prev) => ({
            ...prev,
            format,
          })),
        actions: ["import"],
      },
      {
        label: t("templateSelection"),
        component: stepComponents.Import,
        value: params.templateName,
        set: (selectedTemplate, templateName) =>
          setParams((prev) => ({
            ...prev,
            selectedTemplate,
            templateName,
          })),
        actions: ["import"],
      },
    ],
    [actions, context, formats, languages, params, t],
  );

  const visibleSteps = useMemo(
    () => steps.filter(({ actions }) => actions.includes(currentAction)),
    [steps, currentAction],
  );

  /**
   * Handlers
   */

  const nextStep = () => {
    handleStep(currentStep + 1);
  };

  const handleStep = (index) => {
    if (index < 0 || index > steps.length) {
      return;
    }

    setCurrentStep(index);
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    setLocale(locale);
    i18n.changeLanguage(locale.substring(0, 2));
  }, [locale]);

  /**
   * RENDERING
   */

  return (
    <div className="container">
      <div className="row justify-content-center">
        <div className="col-12">
          <h1>{t("createPlan")}</h1>
          <div className={`${stepperStyles.main}`}>
            <Stepper activeStep={currentStep}>
              {visibleSteps.map(({ label, value }, index) => (
                <Step
                  key={`step-${index}`}
                  label={
                    <>
                      {label}
                      <br />
                      <small>
                        <i>{value && `(${value})`}</i>
                      </small>
                    </>
                  }
                  onClick={() => handleStep(index)}
                />
              ))}
            </Stepper>
            <div style={{ padding: "20px", boxSizing: "border-box" }}>
              {visibleSteps.map(
                ({ component, set }, index) =>
                  currentStep === index &&
                  React.cloneElement(component, {
                    key: `step-${index}-component`,
                    nextStep,
                    prevStep:
                      index > 0 ? (
                        <CustomButton
                          handleClick={() => handleStep(currentStep - 1)}
                          title={t("goBackToPreviousStep")}
                          position="start"
                        />
                      ) : undefined,
                    set,
                    params,
                  }),
              )}
            </div>
          </div>
        </div>
      </div>
      <Toaster
        position="bottom-right"
        toastOptions={toastOptions}
        reverseOrder={false}
      />
    </div>
  );
}

export default PlanCreation;
