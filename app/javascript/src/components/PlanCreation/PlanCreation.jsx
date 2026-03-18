import React, { useContext, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Step, Stepper } from './BootstrapStepper.jsx';
import { Toaster } from 'react-hot-toast';

import { CustomButton } from '../Styled';
import {
  ActionSelection,
  ContextSelection,
  TemplateSelection,
  FormatSelection,
  LangSelection,
  Import,
} from './Steps';
import * as stepperStyles from '../assets/css/stepper.module.css';
import { GlobalContext } from '../context/Global';

const toastOptions = {
  duration: 5000,
};

function PlanCreation({ locale = 'en_GB' }) {
  const { t, i18n } = useTranslation();
  const { setLocale, setUrlParams } = useContext(GlobalContext);

  const [params, setParams] = useState({
    action: null,
    researchContext: null,
    templateLanguage: null,
    selectedTemplate: null,
    format: null,
    templateName: null,
    isStructured: false,
  });

  const [currentStep, setCurrentStep] = useState(0);

  const actions = {
    import: t('importAnExistingPlan'),
    create: t('createNewPlan'),
  };

  const formats = {
    standard: t('dmpOpidorFormat'),
    rda: t('rdaDmpCommonStandardFormat'),
  };

  const context = {
    research_project: t('forProject'),
    research_entity: t('forEntity'),
  };

  const languages = {
    'fr-FR': 'Français',
    'en-GB': 'English (UK)',
  };

  const [currentAction, setCurrentAction] = useState('create');

  const [steps, setSteps] = useState([]);
  const dataSteps = [
    {
      label: t('actionSelection'),
      component: <ActionSelection />,
      value: actions[params.action],
      set: (action) => setParams({
        ...params,
        action,
      }),
      actions: ['create', 'import'],
    },
    {
      label: t('contextSelection'),
      component: <ContextSelection />,
      value: context[params.researchContext],
      set: (researchContext) => setParams({
        ...params,
        researchContext,
      }),
      actions: ['create', 'import'],
    },
    {
      label: t('languageSelection'),
      component: <LangSelection />,
      value: languages[params.templateLanguage],
      set: (templateLanguage) => setParams({
        ...params,
        templateLanguage,
      }),
      actions: ['create', 'import'],
    },
    {
      label: t('templateSelection'),
      component: <TemplateSelection />,
      value: params.templateName,
      set: (selectedTemplate, templateName) => setParams({
        ...params,
        selectedTemplate,
        templateName,
      }),
      actions: ['create'],
    },
    {
      label: t('formatSelection'),
      component: <FormatSelection />,
      value: formats[params.format],
      set: (format) => setParams({
        ...params,
        format,
      }),
      actions: ['import'],
    },
    {
      label: t('templateSelection'),
      component: <Import />,
      value: params.templateName,
      set: (selectedTemplate, templateName) => setParams({
        ...params,
        selectedTemplate,
        templateName,
      }),
      actions: ['import'],
    },
  ];

  useEffect(() => {
    setLocale(locale);
    i18n.changeLanguage(locale.substring(0, 2));

    setSteps(dataSteps);

    const isStructuredValue = localStorage.getItem('isStructured');

    const researchContext = params.researchContext || localStorage.getItem('researchContext') || null;

    const action = localStorage.getItem('action');
    setCurrentAction(action);

    setParams({
      ...params,
      action,
      format: localStorage.getItem('format'),
      researchContext,
      templateLanguage: localStorage.getItem('templateLanguage'),
      selectedTemplate: params.selectedTemplate || Number.parseInt(localStorage.getItem('templateId'), 10) || null,
      templateName: params.templateName || localStorage.getItem('templateName'),
      isStructured: params.isStructured || isStructuredValue ? isStructuredValue === 'true' : null,
    });

    const queryParameters = new URLSearchParams(window.location.search);
    let step = Number.parseInt(queryParameters.get('step') || 0, 10);

    if (!action) {
      setCurrentAction('create');
      step = 0;
    }

    setCurrentStep(step);
    setUrlParams({ step: `${step || 0}` });
  }, [locale, currentStep, currentAction, params.templateName]);

  const prevStep = (<CustomButton
    handleClick={() => handleStep(currentStep - 1)}
    title={t('goBackToPreviousStep')}
    position="start"
  />);

  const nextStep = () => {
    handleStep(currentStep + 1);
  };

  const handleStep = (index) => {
    if (index < 0 || index > steps.length) { return; }

    setCurrentStep(index);
    setUrlParams({ step: index });
  };

  return (
    <div className="container">
      <div className="row justify-content-center">
        <div className="col-12">
          <h1>{t('createPlan')}</h1>
          <div className={`${stepperStyles.main}`}>
            <Stepper activeStep={currentStep}>
              {
                steps.filter(({ actions }) => actions.includes(currentAction)).map(({ label, value }, index) => (
                  <Step
                    key={`step-${index}`}
                    label={<>{label}<br /><small><i>{value && `(${value})`}</i></small></>}
                    onClick={() => handleStep(index)}
                  />
                ))
              }
            </Stepper>
            <div style={{ padding: '20px', boxSizing: 'border-box' }}>
              {
                steps.filter(({ actions }) => actions.includes(currentAction)).map(({ component, set }, index) => currentStep === index && React.cloneElement(component, {
                  key: `step-${index}-component`,
                  nextStep,
                  prevStep: index > 0 ? prevStep : undefined,
                  set,
                  params,
                  setUrlParams,
                }))
              }
            </div>
          </div>
        </div>
      </div>
      <Toaster position="bottom-right" toastOptions={toastOptions} reverseOrder={false} />
    </div>
  );
}

export default PlanCreation;
