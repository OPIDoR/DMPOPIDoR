import { useCallback, useContext, useEffect, useMemo, useState } from "react";
import { useFormContext, useController } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";
import { FaPenToSquare, FaPlus, FaEye, FaXmark } from "react-icons/fa6";
import Swal from "sweetalert2";

import { madmpFragment } from "../../../services/index.js";
import {
  createRegistryOptions,
  createRegistryPlaceholder,
  parsePattern,
} from "../../../utils/GeneratorUtils.js";
import { GlobalContext } from "../../context/GlobalContext.jsx";
import * as styles from "../../assets/css/form.module.css";
import CustomSelect from "../../Shared/CustomSelect.jsx";
import { ASYNC_SELECT_OPTION_THRESHOLD } from "../../../config.js";
import NestedForm from "../../Forms/NestedForm.jsx";
import {
  except,
  fragmentEmpty,
  getErrorMessage,
} from "../../../utils/utils.js";
import swalUtils from "../../../utils/swalUtils.js";
import TooltipInfoIcon from "../TooltipInfoIcon.jsx";
import useLoadTemplate from "../../../hooks/useLoadTemplate.js";
import useLoadRegistry from "../../../hooks/useLoadRegistry.js";

/* This is a functional component in JavaScript React that renders a select list with options fetched from a registry. It takes in several props such as
label, name, changeValue, tooltip, registry, and schemaId. It uses the useState and useEffect hooks to manage the state of the options and to fetch
the options from the registry when the component mounts. It also defines a handleChangeList function that is called when an option is selected from
the list, and it updates the value of the input field accordingly. Finally, it returns the JSX code that renders the select list with the options. */
function SelectSingleObject({
  label,
  propName,
  tooltip,
  category = null,
  dataType,
  topic,
  registries = [],
  templateName,
  overridable = false,
  readonly = false,
}) {
  const { t } = useTranslation();
  const { control } = useFormContext();
  const { field } = useController({ control, name: propName });
  const { locale } = useContext(GlobalContext);
  const [error, setError] = useState(null);
  const [editedFragment, setEditedFragment] = useState({});
  const [availableRegistries, setAvailableRegistries] = useState(registries);
  const [selectedRegistry, setSelectedRegistry] = useState(
    availableRegistries[0],
  );
  const [showNestedForm, setShowNestedForm] = useState(false);
  /**
   * Memoized values
   */
  const registryValues = useLoadRegistry(selectedRegistry);
  const template = useLoadTemplate(templateName);
  const tooltipId = useMemo(
    () => uniqueId("select_single_object_tooltip_id_"),
    [],
  );
  const inputId = useMemo(() => uniqueId("select_single_object_id_"), []);

  const selectedValue = useMemo(
    () => except(field.value, ["template_name", "id", "schema_id"]) || null,
    [field.value],
  );
  const options = useMemo(
    () =>
      registryValues
        ? createRegistryOptions(registryValues, locale)
        : [{ value: "", label: "" }],
    [registryValues, locale],
  );

  /**
   * Refs
   */
  // const loadingRegistriesRef = useRef(new Set());

  const ViewEditComponent = readonly ? FaEye : FaPenToSquare;

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */

  const handleSelectRegistryValue = useCallback(
    (e) => {
      if (!e) return { target: { name: propName, value: "" } };
      const action = field.value?.id ? "update" : "create";
      const value = { ...field.value, ...e.object, action };
      field.onChange(value);
    },
    [field, propName],
  );

  /**
   * The handleChange function updates the registry name based on the value of the input field.
   */
  const handleSelectRegistry = useCallback((e) => {
    setSelectedRegistry(e.value);
  }, []);

  const handleSaveNestedForm = useCallback(
    (data) => {
      if (!data) return setShowNestedForm(false);

      const newFragment = {
        ...field.value,
        ...data,
        action: data.action || "create",
      };
      field.onChange(newFragment);

      setEditedFragment({});
      setShowNestedForm(false);
    },
    [field],
  );

  const handleDeleteList = useCallback(
    (e) => {
      e.preventDefault();
      e.stopPropagation();
      Swal.fire(swalUtils.defaultConfirmConfig(t)).then((result) => {
        if (result.isConfirmed) {
          field.onChange({ id: field.value.id, action: "delete" });

          setEditedFragment({});
          setShowNestedForm(false);
        }
      });
    },
    [t, field],
  );

  const handleCloseNestedForm = useCallback(() => {
    setEditedFragment({});
    setShowNestedForm(false);
  }, []);

  const handleEditFragment = useCallback(() => {
    setEditedFragment({ ...field.value, action: "update" });
    setShowNestedForm(true);
  }, [field.value]);

  const handleAddFragment = useCallback(() => {
    setShowNestedForm(true);
    setEditedFragment({
      action: field.value?.id ? "update" : "create",
    });
  }, [field.value]);

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    if (category) {
      madmpFragment
        .getAvailableRegistries(category, dataType, topic)
        .then((res) => {
          const registriesData = Array?.isArray(res.data)
            ? res.data.map((r) => r.name)
            : [res.data.name];
          setAvailableRegistries(registriesData);
          if (registriesData.length === 1) {
            const registry = res.data[0];
            setSelectedRegistry(registry.name);
          }
        })
        .catch((error) => {
          setError(getErrorMessage(error));
        });
    }
  }, [category, dataType, topic]);

  /**
   * RENDERING
   */

  return (
    <div>
      <div className="form-group">
        <div className={styles.label_form}>
          <label
            htmlFor={inputId}
            data-testid="select-single-object-label"
            data-tooltip-id={tooltipId}
          >
            {label}
            {tooltip && <TooltipInfoIcon />}
          </label>
          {tooltip && (
            <ReactTooltip
              id={tooltipId}
              place="bottom"
              effect="solid"
              variant="info"
              style={{ width: "300px", textAlign: "center" }}
              content={tooltip}
            />
          )}
        </div>

        <span className={styles.errorMessage}>{error}</span>
        {/* ************Select registry************** */}
        <div className="row">
          {availableRegistries && availableRegistries.length > 1 && (
            <div
              data-testid="select-single-object-registry-selector"
              className="col-md-6"
            >
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
                      selectedRegistry
                        ? { value: selectedRegistry, label: selectedRegistry }
                        : null
                    }
                    isDisabled={readonly}
                    placeholder={t("selectRegistry")}
                  />
                </div>
              </div>
            </div>
          )}

          <div
            className={
              availableRegistries && availableRegistries.length > 1
                ? "col-md-6"
                : "col-md-12"
            }
            data-testid="select-single-object-div"
          >
            <div className="row">
              <div className={`col-md-11 ${styles.select_wrapper}`}>
                {options && (
                  <CustomSelect
                    inputId={inputId}
                    onSelectChange={handleSelectRegistryValue}
                    options={options}
                    selectedOption={{ value: "", label: "" }}
                    isDisabled={showNestedForm || readonly || !selectedRegistry}
                    async={options.length > ASYNC_SELECT_OPTION_THRESHOLD}
                    placeholder={createRegistryPlaceholder(
                      availableRegistries.length,
                      false,
                      overridable,
                      "complex",
                      t,
                    )}
                    overridable={false}
                  />
                )}
              </div>
              {!readonly && overridable && !showNestedForm && (
                <div className="col-md-1">
                  <ReactTooltip
                    id="select-single-list-add-button"
                    place="bottom"
                    effect="solid"
                    variant="info"
                    content={t("add")}
                  />
                  <FaPlus
                    data-tooltip-id="select-single-list-add-button"
                    onClick={handleAddFragment}
                    className={styles.icon}
                  />
                </div>
              )}
            </div>
          </div>
        </div>
        <div
          id={`nested-form-${propName}`}
          className={styles.nestedForm}
          style={{ display: showNestedForm ? "block" : "none" }}
        ></div>
        {showNestedForm && (
          <NestedForm
            propName={propName}
            data={editedFragment}
            template={template}
            mainFormDataType={dataType}
            mainFormTopic={topic}
            readonly={readonly}
            handleSave={handleSaveNestedForm}
            handleClose={handleCloseNestedForm}
          />
        )}

        {!fragmentEmpty(selectedValue) && !showNestedForm && (
          <table style={{ marginTop: "20px" }} className="table">
            <thead>
              <tr>
                <th scope="col">{t("selectedValue")}</th>
                <th scope="col"></th>
              </tr>
            </thead>
            <tbody>
              {[selectedValue].map((el, idx) => (
                <tr key={idx}>
                  <td style={{ width: "90%" }}>
                    {parsePattern(el, template?.schema?.to_string)}
                  </td>
                  <td style={{ width: "10%" }}>
                    <ViewEditComponent
                      onClick={handleEditFragment}
                      className={styles.icon}
                    />
                    <FaXmark
                      onClick={(e) => handleDeleteList(e)}
                      className={styles.icon}
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        {/* *************Select registry************* */}
      </div>
    </div>
  );
}

export default SelectSingleObject;
