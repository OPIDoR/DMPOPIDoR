import React from 'react';
import { useTranslation } from 'react-i18next';

import * as styles from '../../assets/css/steps.module.css';

function FormatSelection({
  prevStep, nextStep, set, params,
}) {
  const { t } = useTranslation();

  const formats = [
    {
      id: 'standard',
      title: t('dmpOpidorFormat'),
      description: t('jsonFileIsInDmpOpidorFormat'),
    },
    {
      id: 'rda',
      title: t('rdaDmpCommonStandardFormat'),
      description: t('jsonFileIsInRdaDmpFormat'),
    },
  ];

  const isEntity = params.researchContext === 'research_entity';

  const createStep = ({
    id, title, description, className, onClick, style,
  }) => (
    <div key={`first-step-${id}-container`} className={className} style={style} onClick={onClick}>
      <div id={`first-step-${id}-label`} style={style} className={styles.step_title}>
        {title}
      </div>
      <div key={`first-step-${id}-description`}>{description}</div>
    </div>
  );

  const stepsList = formats.map(({ id, title, description }) => {
    if (isEntity && id === formats[1].id) {
      return createStep({
        id,
        title,
        description,
        className: styles.disabled,
        onClick: undefined,
        style: {
          color: 'grey',
          backgroungColor: 'grey',
        },
      });
    }
    return createStep({
      id,
      title,
      description,
      className: `${styles.step_list} ${params.format === id ? styles.checked : ''}`,
      onClick: () => {
        localStorage.setItem('format', id);
        set(id);
        return nextStep();
      },
    });
  });

  return (
    <div>
      <h2>{t('selectPlanFormatToBeImported')}</h2>
      {stepsList}
      <div style={{ display: 'flex', justifyContent: 'space-between' }}>
        {prevStep}
      </div>
    </div>
  );
}

export default FormatSelection;
