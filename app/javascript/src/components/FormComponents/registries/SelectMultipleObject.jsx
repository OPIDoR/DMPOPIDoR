import React, { useContext, useEffect, useState } from 'react';
import { useFormContext, useFieldArray } from 'react-hook-form';
import Swal from 'sweetalert2';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import uniqueId from 'lodash.uniqueid';
import { FaPlus } from 'react-icons/fa6';

import { GlobalContext } from '../../context/Global.jsx';
import {
  createOptions,
  createRegistryPlaceholder,
} from '../../../utils/GeneratorUtils.js';
import { service } from '../../../services/index.js';
import * as styles from '../../assets/css/form.module.css';
import CustomSelect from '../../Shared/CustomSelect.jsx';
import FragmentList from '../FragmentList.jsx';
import { ASYNC_SELECT_OPTION_THRESHOLD } from '../../../config.js';
import ModalForm from '../../Forms/ModalForm.jsx';
import swalUtils from '../../../utils/swalUtils.js';
import { getErrorMessage } from '../../../utils/utils.js';
import { checkFragmentExists } from '../../../utils/JsonFragmentsUtils.js';
import TooltipInfoIcon from '../TooltipInfoIcon.jsx';

function SelectMultipleObject({
  label,
  formLabel,
  propName,
  tooltip,
  header,
  templateName,
  category = null,
  dataType,
  topic,
  registries = [],
  overridable = false,
  readonly = false,
  isConst = false,
}) {
  const { t } = useTranslation();
  const {
    locale,
    loadedRegistries, setLoadedRegistries,
    loadedTemplates, setLoadedTemplates,
  } = useContext(GlobalContext);
  const { control } = useFormContext();
  const { fields, append, update } = useFieldArray({ control, name: propName, keyName: '_id' });
  const [show, setShow] = useState(false);
  const [options, setOptions] = useState([]);
  const [index, setIndex] = useState(null);
  const [error, setError] = useState(null);
  const [template, setTemplate] = useState(null);
  const [editedFragment, setEditedFragment] = useState({});
  const [selectedRegistry, setSelectedRegistry] = useState(null);
  const [availableRegistries, setAvailableRegistries] = useState([]);
  const tooltipId = uniqueId('select_with_create_tooltip_id_');
  const inputId = uniqueId('select_multiple_object_id_');

  const filteredFragmentList = fields.filter((el) => el.action !== 'delete');

  useEffect(() => {
    if (category) {
      service.getAvailableRegistries(category, dataType, topic)
        .then((res) => {
          const registriesData = Array?.isArray(res.data) ? res.data.map((r) => r.name) : [res.data.name]; setAvailableRegistries(registriesData);
          if (registriesData.length === 1) {
            const registry = res.data[0];
            setSelectedRegistry(registry.name);
            setLoadedRegistries({ ...loadedRegistries, [registry.name]: registry.values });
            setOptions(createOptions(registry.values, locale));
          }
        })
        .catch((error) => {
          setError(getErrorMessage(error));
        });
    } else if (registries) {
      setAvailableRegistries(registries);
      if (registries.length === 1) {
        setSelectedRegistry(registries[0]);
      }
    }
  }, [category, dataType, topic, registries]);

  /* A hook that is called when the component is mounted.
  It is used to set the options of the select list. */
  useEffect(() => {
    if (!loadedTemplates[templateName]) {
      service.getSchemaByName(templateName).then((res) => {
        setTemplate(res.data);
        setLoadedTemplates({ ...loadedTemplates, [templateName]: res.data });
      }).catch((error) => {
        setError(getErrorMessage(error));
      });
    } else {
      setTemplate(loadedTemplates[templateName]);
    }
  }, [templateName]);

  /* A hook that is called when the component is mounted.
  It is used to set the options of the select list. */
  useEffect(() => {
    if (registries.length === 0 && availableRegistries.length === 1) return;

    if (selectedRegistry) {
      if (loadedRegistries[selectedRegistry]) {
        setOptions(createOptions(loadedRegistries[selectedRegistry], locale));
      } else if (selectedRegistry) {
        service.getRegistryByName(selectedRegistry)
          .then((res) => {
            setLoadedRegistries({ ...loadedRegistries, [selectedRegistry]: res.data });
            setOptions(createOptions(res.data, locale));
          })
          .catch((error) => {
            setError(getErrorMessage(error));
          });
      }
    }
  }, [selectedRegistry]);

  const handleClose = () => {
    setShow(false);
    setEditedFragment(null);
    setIndex(null);
  };

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleSelectRegistryValue = (e) => {
    const pattern = template?.schema?.to_string || [];
    if (pattern.length > 0) {
      append({ ...e.object, action: 'create' });
    }
  };

  /**
   * It creates a new array, then removes the item at the index specified by the parameter,
   * then sets the state to the new array.
   * @param idx - the index of the item in the array
   */
  const handleDelete = (idx) => {
    Swal.fire(swalUtils.defaultConfirmConfig(t)).then((result) => {
      if (result.isConfirmed) {
        update(idx, { ...fields[idx], action: 'delete' });
      }
    });
  };

  /**
   * If the index is not null, then delete the item at the index,
   * add the modalData item to the end of the array,
   * and then splice the item from the list array.
   * If the index is null, then just save the item.
   */
  const handleSave = (data) => {
    if (!data) return handleClose();

    if (checkFragmentExists(fields, data, template.schema.unicity)) {
      setError(t('recordAlreadyExists'));
    } else {
      if (index !== null) {
        const updatedFragment = {
          ...fields[index],
          ...data,
          action: fields[index].action || 'update',
        };
        update(index, updatedFragment);
      } else {
        // add in add
        handleSaveNew(data);
      }
      toast.success(t('saveSuccess'));
    }
    handleClose();
  };

  /**
   * I'm trying to add a new object to an array of objects, and then add that array to a new object.
   */
  const handleSaveNew = (data) => {
    append({ ...data, action: 'create' });
  };

  /**
   * It sets the state of the modalData variable to the value of the formData[propName][idx] variable.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (idx) => {
    setEditedFragment(fields[idx]);
    setShow(true);
    setIndex(idx);
  };

  /**
   * The handleChange function updates the registry name based on the value of the input field.
   */
  const handleSelectRegistry = (e) => {
    setSelectedRegistry(e.value);
  };

  return (
    <div>
      <div className="form-group">
        <div className={styles.label_form}>
          <label htmlFor={inputId} data-testid="select-multiple-object-label" data-tooltip-id={tooltipId}>
            {formLabel}
            {tooltip && (<TooltipInfoIcon />)}
          </label>
          {
            tooltip && (
              <ReactTooltip
                id={tooltipId}
                place="bottom"
                effect="solid"
                variant="info" style={{ width: '300px', textAlign: 'center' }}
                content={tooltip}
              />
            )
          }
        </div>
        <span className={styles.errorMessage}>{error}</span>
        {/* ************Select ref************** */}
        <div className="row">
          {availableRegistries && availableRegistries.length > 1 && (
            <div data-testid="select-multiple-object-registry-selector" className="col-md-6">
              <div className="row">
                <div className={`col-md-11 ${styles.select_wrapper}`}>
                  <CustomSelect
                    inputId={`${propName}-registry-selector`}
                    onSelectChange={handleSelectRegistry}
                    options={availableRegistries.map((registry) => ({
                      value: registry,
                      label: registry,
                    }))}
                    name={propName}
                    selectedOption={
                      selectedRegistry ? { value: selectedRegistry, label: selectedRegistry } : null
                    }
                    isDisabled={readonly}
                    placeholder={t('selectRegistry')}
                  />
                </div>
              </div>
            </div>
          )}

          <div className={availableRegistries && availableRegistries.length > 1 ? 'col-md-6' : 'col-md-12'} data-testid="select-multiple-object-div">
            <div className="row">
              <div className={`col-md-11 ${styles.select_wrapper}`}>
                {options && (
                  <CustomSelect
                    inputId={inputId}
                    onSelectChange={handleSelectRegistryValue}
                    options={options}
                    name={propName}
                    isDisabled={readonly || !selectedRegistry}
                    async={options.length > ASYNC_SELECT_OPTION_THRESHOLD}
                    placeholder={createRegistryPlaceholder(availableRegistries.length, true, overridable, 'complex', t)}
                    overridable={false}
                  />
                )}
              </div>
              {!readonly && overridable && (
                <div className="col-md-1">
                  <ReactTooltip
                    id="select-with-create-add-button"
                    place="bottom"
                    effect="solid"
                    variant="info"
                    content={t('add')}
                  />
                  <FaPlus
                    data-tooltip-id="select-with-create-add-button"
                    onClick={() => {
                      setShow(true);
                      setIndex(null);
                    }}
                    className={styles.icon}
                  />
                </div>
              )}
            </div>
          </div>
        </div>
        <span className={styles.errorMessage}>{error}</span>
        {template && filteredFragmentList.length > 0 && (
          <FragmentList
            fragmentsList={fields}
            handleEdit={handleEdit}
            handleDelete={handleDelete}
            templateToString={template?.schema?.to_string}
            tableHeader={header}
            readonly={readonly}
            isConst={isConst}
          />
        )}
      </div>

      {template && show && (
        <ModalForm
          data={editedFragment}
          template={template}
          mainFormDataType={dataType}
          mainFormTopic={topic}
          label={index !== null ? `${t('edit')} : ${label}` : `${t('add')} : ${label}`}
          readonly={readonly}
          show={show}
          handleSave={handleSave}
          handleClose={handleClose}
        />
      )}
    </div>
  );
}

export default SelectMultipleObject;
