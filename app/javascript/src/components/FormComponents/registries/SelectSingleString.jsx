import { useContext, useEffect, useMemo, useState } from "react";
import { useFormContext, useController } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";
import { FaXmark } from "react-icons/fa6";

import { service } from "../../../services/index.js";
import {
  createRegistryOptions,
  createRegistryPlaceholder,
} from "../../../utils/GeneratorUtils.js";
import { GlobalContext } from "../../context/GlobalContext.jsx";
import * as styles from "../../assets/css/form.module.css";
import CustomSelect from "../../Shared/CustomSelect.jsx";
import { ASYNC_SELECT_OPTION_THRESHOLD } from "../../../config.js";
import TooltipInfoIcon from "../TooltipInfoIcon.jsx";
import { getErrorMessage } from "../../../utils/utils.js";
import useLoadRegistry from "../../../hooks/useLoadRegistry.js";

/* This is a functional component in JavaScript React that renders a select list with options fetched from a registry. It takes in several props such as
label, name, changeValue, tooltip, registry, and schemaId. It uses the useState and useEffect hooks to manage the state of the options and to fetch
the options from the registry when the component mounts. It also defines a handleChangeList function that is called when an option is selected from
the list, and it updates the value of the input field accordingly. Finally, it returns the JSX code that renders the select list with the options. */
function SelectSingleString({
  label,
  propName,
  tooltip,
  category = null,
  dataType,
  topic,
  registries = [],
  overridable = false,
  readonly = false,
}) {
  const { t } = useTranslation();
  const { control } = useFormContext();
  const { field } = useController({ control, name: propName });
  const { locale } = useContext(GlobalContext);
  const [error, setError] = useState(null);
  const [selectedRegistry, setSelectedRegistry] = useState(null);
  const [availableRegistries, setAvailableRegistries] = useState(registries);

  /**
   * Memoized values
   */
  const registryValues = useLoadRegistry(selectedRegistry);
  const tooltipId = useMemo(
    () => uniqueId("select_single_list_tooltip_id_"),
    [],
  );
  const inputId = useMemo(() => uniqueId("select_single_list_id_"), []);
  const options = useMemo(
    () =>
      registryValues.length > 0
        ? createRegistryOptions(registryValues, locale)
        : [{ value: "", label: "" }],
    [registryValues, locale],
  );

  const selectedOption = useMemo(() => {
    if (!field.value) return null;
    if (!options) return null;

    const selectedOpt = options.find((o) => o.value === field.value) || null;
    if (selectedOpt === null && overridable === true) {
      return { value: field.value, label: field.value };
    } else {
      return selectedOpt;
    }
  }, [field.value, options, overridable]);

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleSelectRegistryValue = (e) => {
    if (!e) return { target: { name: propName, value: "" } };

    return field.onChange(e.value);
  };

  /**
   * The handleChange function updates the registry name based on the value of the input field.
   */
  const handleSelectRegistry = (e) => {
    setSelectedRegistry(e.value);
  };

  /**
   * USE EFFECTS
   */
  useEffect(() => {
    if (category) {
      service
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
            data-testid="select-single-string-label"
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
              data-testid="select-single-string-registry-selector"
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
            data-testid="select-single-string-div"
          >
            <div className="row">
              <div className={`col-md-11 ${styles.select_wrapper}`}>
                {options && (
                  <CustomSelect
                    inputId={inputId}
                    propName={propName}
                    onSelectChange={handleSelectRegistryValue}
                    options={options}
                    selectedOption={selectedOption}
                    isDisabled={readonly || !selectedRegistry}
                    async={options.length > ASYNC_SELECT_OPTION_THRESHOLD}
                    placeholder={createRegistryPlaceholder(
                      availableRegistries.length,
                      false,
                      overridable,
                      "simple",
                      t,
                    )}
                    overridable={overridable}
                  />
                )}
              </div>
              {!readonly && selectedOption && (
                <div className="col-md-1">
                  <FaXmark
                    onClick={() => field.onChange(null)}
                    className={styles.icon}
                  />
                </div>
              )}
            </div>
          </div>
        </div>
        {/* *************Select registry************* */}
      </div>
    </div>
  );
}

export default SelectSingleString;
