import React from 'react';
import { useTranslation } from 'react-i18next';

import * as styles from '../../assets/css/steps.module.css';

function ActionSelection({ nextStep, set, params }) {
  const { t } = useTranslation();

  const actions = [
    {
      id: 'create',
      title: t('createNewPlan'),
      description: t('createNewPlanFromTemplate'),
    },
    {
      id: 'import',
      title: <>{t('importAnExistingPlan')} <span style={{ fontSize: '14px', fontWeight: 200 }}>({t('onlyAvailableForStructuredManagementPlans')})</span></>,
      description: t('reuseInfoFromExistingPlanUsingJson'),
    },
  ];

  return (
    <div>
      <h2>{t('selectModalityToCreatePlan')}</h2>
      {
        actions.map(({ id, title, description }) => (
          <div
            key={`first-step-${id}-container`}
            className={`${styles.step_list}  ${params.action === id ? styles.checked : ''}`}
            onClick={() => {
              localStorage.setItem('action', id);
              set(id);
              return nextStep();
            }}
          >
            <div
              id={`first-step-${id}-label`}
              key={`first-step-${id}-label`}
              className={styles.step_title}
            >
              {title}
            </div>
            <div key={`first-step-${id}-description`}>{description}</div>
          </div>
        ))
      }
    </div>
  );
}

export default ActionSelection;
