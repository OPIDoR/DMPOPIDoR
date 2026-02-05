import React, { useState } from 'react';
import { useFormContext } from 'react-hook-form';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import { useTranslation } from 'react-i18next';
import uniqueId from 'lodash.uniqueid';

import * as styles from '../assets/css/form.module.css';
import TooltipInfoIcon from './TooltipInfoIcon.jsx';

/**
 * It's a function that takes in a bunch of props and returns
 * a div with a label, an input, and a small tag.
 * @returns A React Component
 */
function InputText({
  label,
  type,
  placeholder,
  propName,
  tooltip,
  hidden = false,
  readonly = false,
  min,
}) {
  const { t } = useTranslation();
  const { register } = useFormContext();
  const [isRequired] = useState(false);
  const inputId = uniqueId('input_text_id_');
  const tooltipedLabelId = uniqueId('input_text_tooltip_id_');

  return (
    <div className="form-group">
      {hidden === false && (
        <div className={styles.label_form}>
          <label htmlFor={inputId} aria-labelledby={inputId} data-testid="input-text-label" data-tooltip-id={tooltipedLabelId}>
            {label}
            {tooltip && (<TooltipInfoIcon />)}
          </label>
          {tooltip && (
            <ReactTooltip
              id={tooltipedLabelId}
              place="bottom"
              effect="solid"
              variant="info"
              style={{ width: '300px', textAlign: 'center' }}
              content={tooltip}
            />
          )}
        </div>
      )}
      <input
        id={inputId}
        data-testid="input-text"
        {...register(propName, {
          valueAsNumber: type === 'number',
          value: '',
        })}
        type={hidden ? 'hidden' : type}
        className={isRequired ? `form-control ${styles.input_text} ${styles.outline_red}` : `form-control ${styles.input_text}`}
        placeholder={placeholder ? `${t('eg')} ${placeholder}` : null}
        readOnly={readonly === true}
        disabled={readonly === true}
        min={min}
      />
    </div>
  );
}
export default InputText;
