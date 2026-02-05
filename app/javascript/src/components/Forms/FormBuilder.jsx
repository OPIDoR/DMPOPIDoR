import React, { useContext, useMemo } from 'react';

import { GlobalContext } from '../context/Global.jsx';
import InputText from '../FormComponents/InputText.jsx';
import InputTextArray from '../FormComponents/InputTextArray.jsx';
import ModalTemplate from '../FormComponents/ModalTemplate';
import SelectContributorMultiple from '../FormComponents/SelectContributorMultiple.jsx';
import SelectContributorSingle from '../FormComponents/SelectContributorSingle.jsx';
import SelectMultipleString from '../FormComponents/registries/SelectMultipleString.jsx';
import SelectSingleString from '../FormComponents/registries/SelectSingleString.jsx';
import SelectSingleObject from '../FormComponents/registries/SelectSingleObject.jsx';
import SelectMultipleObject from '../FormComponents/registries/SelectMultipleObject.jsx';
import TinyArea from '../FormComponents/TinyArea';
import SubForm from '../FormComponents/SubForm.jsx';
import { createFormLabel } from '../../utils/GeneratorUtils.js';

function FormBuilder({
  template, dataType, topic, readonly,
}) {
  const { locale } = useContext(GlobalContext);
  if (!template) return false;
  const properties = template.properties;
  const defaults = template.default?.[locale];
  const formFields = [];

  // si type shema is an object
  // retun est code html
  if (template.type === 'object') {
    for (const [key, prop] of Object.entries(properties)) {
      const formLabel = createFormLabel(prop, locale);
      const tooltip = prop[`tooltip@${locale}`];
      const isConst = prop.isConst;
      const example = prop[`example@${locale}`];
      /**
       * REGISTRIES
       */
      if (prop.inputType === 'dropdown'
        && (Object.prototype.hasOwnProperty.call(prop, 'registryCategory') || Object.prototype.hasOwnProperty.call(prop, 'registries'))
      ) {
        const registries = useMemo(() => prop?.registries ?? [], [prop?.registries]);

        // COMPLEX REGISTRY, ONE VALUE SELECTABLE
        if (prop.template_name && prop.type === 'object') {
          formFields.push(
            <SelectSingleObject
              key={key}
              label={formLabel}
              propName={key}
              tooltip={tooltip}
              category={prop.registryCategory}
              dataType={dataType}
              topic={topic}
              registries={registries}
              templateName={prop.template_name}
              overridable={prop.overridable}
              readonly={readonly || isConst}
            ></SelectSingleObject>,
          );
          continue;
        }
        // COMPLEX REGISTRY, MULTIPLE VALUES SELECTABLE
        if (prop.items?.template_name && prop.type === 'array') {
          formFields.push(
            <SelectMultipleObject
              key={key}
              label={prop[`label@${locale}`] || 'No label defined'}
              formLabel={formLabel}
              propName={key}
              tooltip={tooltip}
              header={prop[`table_header@${locale}`]}
              templateName={prop.items.template_name}
              category={prop.registryCategory}
              dataType={dataType}
              topic={topic}
              registries={registries}
              overridable={prop.overridable}
              readonly={readonly}
              isConst={isConst}
            ></SelectMultipleObject>,
          );
          continue;
        }
        // SIMPLE REGISTRY, ONE VALUE SELECTABLE
        if (prop.type === 'string') {
          formFields.push(
            <SelectSingleString
              key={key}
              label={formLabel}
              propName={key}
              tooltip={tooltip}
              category={prop.registryCategory}
              dataType={dataType}
              topic={topic}
              registries={registries}
              overridable={prop.overridable}
              readonly={readonly || isConst}
            ></SelectSingleString>,
          );
          continue;
        }
        // MULTIPLE VALUES SELECTABLE
        if (prop.type === 'array') {
          formFields.push(
            <SelectMultipleString
              key={key}
              label={formLabel}
              propName={key}
              tooltip={tooltip}
              category={prop.registryCategory}
              dataType={dataType}
              topic={topic}
              registries={registries}
              overridable={prop.overridable}
              readonly={readonly || isConst}
            ></SelectMultipleString>,
          );
          continue;
        }
      }
      /**
       * SUB FRAGMENTS
       */

      // CONTRIBUTOR
      if (prop.class === 'Contributor' || prop.class === 'ContributorStandard') {
        const defaultRole = defaults?.[key]?.role;
        formFields.push(
          <SelectContributorSingle
            key={key}
            propName={key}
            label={formLabel}
            tooltip={tooltip}
            templateName={prop.template_name}
            dataType={dataType}
            topic={topic}
            defaultRole={defaultRole}
            readonly={readonly || isConst}
          ></SelectContributorSingle>,
        );
        continue;
      }
      if (prop.template_name && prop.type === 'object') {
        formFields.push(
          <SubForm
            key={key}
            label={formLabel}
            propName={key}
            tooltip={tooltip}
            templateName={prop.template_name}
            dataType={dataType}
            topic={topic}
            readonly={readonly || isConst}
          />,
        );
        continue;
      }

      /**
       * SUB FRAGMENTS LIST
       */
      if (prop.type === 'array' && prop.items.type === 'object' && prop.items.template_name) {
        if (prop.items.class === 'Contributor' || prop.items.class === 'ContributorStandard') {
          const defaultRole = defaults?.[key]?.role;
          formFields.push(
            <SelectContributorMultiple
              key={key}
              label={formLabel}
              propName={key}
              header={prop[`table_header@${locale}`]}
              tooltip={tooltip}
              templateName={prop.items.template_name}
              dataType={dataType}
              topic={topic}
              defaultRole={defaultRole}
              readonly={readonly || isConst}
            ></SelectContributorMultiple>,
          );
        } else {
          // FRAGMENT LIST EDITABLE WITH MODAL
          formFields.push(
            <ModalTemplate
              key={key}
              propName={key}
              dataType={dataType}
              topic={topic}
              label={prop[`label@${locale}`] || 'No label defined'}
              formLabel={formLabel}
              tooltip={tooltip}
              header={prop[`table_header@${locale}`]}
              templateName={prop.items.template_name}
              readonly={readonly}
              isConst={isConst}
            ></ModalTemplate>,
          );
        }
        continue;
      }

      /**
       * ARRAY FIELDS
       */
      if (prop.type === 'array' && prop.items.type === 'string') {
        formFields.push(
          <InputTextArray
            key={key}
            label={formLabel}
            propName={key}
            tooltip={tooltip}
            placeholder={example}
            readonly={readonly || isConst}
          ></InputTextArray>,
        );
        continue;
      }

      /**
       * TEXT FIELDS
       * TEXT & TEXTAREA
       */
      if (prop.type === 'string' || prop.type === 'number') {
        //   TEXTAREA
        if (prop.inputType === 'textarea') {
          formFields.push(
            <TinyArea
              key={key}
              label={formLabel}
              propName={key}
              tooltip={tooltip}
              placeholder={example}
              readonly={readonly || isConst}
            ></TinyArea>,
          );
          continue;
        } else {
          // TEXT FIELDS
          formFields.push(
            <InputText
              key={key}
              label={formLabel}
              type={prop.format || prop.type}
              placeholder={example}
              propName={key}
              tooltip={tooltip}
              hidden={prop.hidden}
              readonly={readonly || isConst}
              min={prop.type === 'number' ? 0 : undefined}
            ></InputText>,
          );
        }
        continue;
      }
    }
  }
  return formFields;
}

export default FormBuilder;
