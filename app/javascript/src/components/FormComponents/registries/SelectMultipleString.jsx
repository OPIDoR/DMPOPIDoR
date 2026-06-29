import { useContext, useEffect, useMemo, useState } from "react";
import { useFormContext, useController } from "react-hook-form";
import Swal from "sweetalert2";
import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";
import { FaXmark } from "react-icons/fa6";

import { GlobalContext } from "../../context/GlobalContext.jsx";
import { madmpFragment } from "../../../services/index.js";
import {
  createOptions,
  createRegistryPlaceholder,
} from "../../../utils/GeneratorUtils.js";
import * as styles from "../../assets/css/form.module.css";
import CustomSelect from "../../Shared/CustomSelect.jsx";
import { ASYNC_SELECT_OPTION_THRESHOLD } from "../../../config.js";
import swalUtils from "../../../utils/swalUtils.js";
import TooltipInfoIcon from "../TooltipInfoIcon.jsx";
import { getErrorMessage } from "../../../utils/utils.js";
import useLoadRegistry from "../../../hooks/useLoadRegistry.js";

function SelectMultipleString({
  label,
  propName,
  tooltip,
  header,
  category = null,
  dataType,
  topic,
  registries = [],
  overridable = false,
  readonly = false,
}) {
  const { t } = useTranslation();
  const { locale } = useContext(GlobalContext);
  const { control } = useFormContext();
  const { field } = useController({ control, name: propName });
  const [error, setError] = useState(null);
  const [selectedRegistry, setSelectedRegistry] = useState(null);
  const [availableRegistries, setAvailableRegistries] = useState(registries);

  /**
   * Memoized values
   */
  const registryValues = useLoadRegistry(selectedRegistry);
  const tooltipId = useMemo(
    () => uniqueId("select_multiple_list_tooltip_id_"),
    [],
  );
  const inputId = useMemo(() => uniqueId("select_multiple_list_id_"), []);

  const options = useMemo(
    () =>
      registryValues
        ? createOptions(registryValues, locale)
        : [{ value: "", label: "" }],
    [registryValues, locale],
  );

  const selectedValues = useMemo(
    () =>
      field.value
        ? Array.isArray(field.value)
          ? field.value
          : [field.value]
        : [],
    [field.value],
  );
  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleSelectRegistryValue = (e) => {
    const newList = [...(selectedValues || []), e.value];
    field.onChange(newList);
  };

  /**
   * This function handles the deletion of an element from a list and displays a confirmation message using the Swal library.
   */
  const handleDeleteList = (e, idx) => {
    e.preventDefault();
    e.stopPropagation();
    Swal.fire(swalUtils.defaultConfirmConfig(t)).then((result) => {
      if (result.isConfirmed) {
        const newList = [...selectedValues];
        // only splice array when item is found
        if (idx > -1) {
          newList.splice(idx, 1); // 2nd parameter means remove one item only
        }
        field.onChange(newList);
      }
    });
  };

  /**
   * The handleSelectRegistry function updates the registry name based on the value of the input field.
   */
  const handleSelectRegistry = (e) => {
    setSelectedRegistry(e.value);
  };

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
            data-testid="select-multiple-string-label"
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
              data-testid="select-multiple-string-registry-selector"
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
            data-testid="select-multiple-string-div"
          >
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
                    placeholder={createRegistryPlaceholder(
                      availableRegistries.length,
                      true,
                      overridable,
                      "simple",
                      t,
                    )}
                    overridable={overridable}
                  />
                )}
              </div>
            </div>
          </div>
        </div>
        {/* *************Select registry************* */}

        <div style={{ margin: "20px 2px 20px 2px" }}>
          {selectedValues && (
            <table style={{ marginTop: "0px" }} className="table">
              {header && (
                <thead>
                  <tr>
                    <th scope="col">{header}</th>
                  </tr>
                </thead>
              )}
              <tbody>
                {selectedValues.map((el, idx) => (
                  <tr key={idx}>
                    <td style={{ width: "100%" }}>
                      <div className={styles.cell_content}>
                        <div>{el} </div>
                        <div className={styles.table_container}>
                          {!readonly && (
                            <FaXmark
                              onClick={(e) => handleDeleteList(e, idx)}
                              size={18}
                              className={styles.icon}
                            />
                          )}
                        </div>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}

export default SelectMultipleString;
