import React from 'react';
import { useFormContext, useFieldArray } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import uniqueId from 'lodash.uniqueid';
import { FaXmark } from 'react-icons/fa6';
import TooltipInfoIcon from './TooltipInfoIcon.jsx';

import * as styles from '../assets/css/form.module.css';
import CustomButton from '../Styled/CustomButton';

/* A React component that renders a form with a text input and a button.
When the button is clicked, a new text input is added to the form. When the text
input is changed, the form is updated. */
function InputTextArray({
  label, propName, tooltip, placeholder, readonly = false,
}) {
  const { t } = useTranslation();
  const { control, register } = useFormContext();
  const { fields, append, remove } = useFieldArray({ control, name: propName, keyName: '_id' });
  const inputTextTooltipId = uniqueId('input_text_dynamicaly_tooltip_id_');
  return (
    <div>
      <div className={styles.label_form}>
        <label data-testid="input-text-array-label" data-tooltip-id={inputTextTooltipId}>
          {label}
          {tooltip && (<TooltipInfoIcon />)}
        </label>
        {
          tooltip && (
            <ReactTooltip
              id={inputTextTooltipId}
              place="bottom"
              effect="solid"
              variant="info"
              style={{ width: '300px', textAlign: 'center' }}
              content={tooltip}
            />
          )
        }
      </div>

      {fields.map((item, index) => (
        <div data-testid={`input-text-array-div-${index}`} className="row" style={{ marginBottom: '10px' }} key={`row-${index}`}>
          <div className="col-md-11">
            <div style={{ display: 'flex', alignItems: 'space-between' }}>
              <input
                key={item.id}
                data-testid={`input-text-array-${index}`}
                {...register(`${propName}.${index}`, { value: '' })}
                type="text"
                className="form-control"
                style={{ border: '1px solid var(--dark-blue)', borderRadius: '8px', flex: 1 }}
                placeholder={placeholder ? `${t('eg')} ${placeholder}` : null}
                readOnly={readonly === true}
              />
            </div>
          </div>
          {!readonly && (
            <div className="col-md-1" key={`col-md-1-input-text-array-${index}`}>
              <ReactTooltip
                id={`input-text-array-del-button-${index}`}
                place="bottom"
                effect="solid"
                variant="info"
                content={t('delete')}
              />
              <FaXmark
                data-tooltip-id={`input-text-array-del-button-${index}`}
                data-testid={`input-text-array-delete-icon-${index}`}
                onClick={() => remove(index)}
                variant="info"
                size={24}
                className={styles.icon}
              />
            </div>
          )}
        </div>
      ))}

      {!readonly && (
        <CustomButton
          handleClick={() => append('')}
          title={t('addElement')}
          buttonColor="rust"
          position="start"
        ></CustomButton>
      )}
    </div>
  );
}

export default InputTextArray;
