import { useContext, useEffect, useMemo, useState } from "react";
import { useFormContext, useController } from "react-hook-form";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";
import { FaPlus } from "react-icons/fa6";
import Swal from "sweetalert2";

import {
  createOptions,
  createRegistryPlaceholder,
  parsePattern,
} from "../../utils/GeneratorUtils.js";
import {
  checkFragmentExists,
  createPersonsOptions,
} from "../../utils/JsonFragmentsUtils.js";
import { GlobalContext } from "../context/GlobalContext.jsx";
import { service } from "../../services/index.js";
import * as styles from "../assets/css/form.module.css";
import CustomSelect from "../Shared/CustomSelect.jsx";
import PersonsList from "./PersonsList.jsx";
import ModalForm from "../Forms/ModalForm.jsx";
import swalUtils from "../../utils/swalUtils.js";
import TooltipInfoIcon from "./TooltipInfoIcon.jsx";
import useLoadTemplate from "../../hooks/useLoadTemplate.js";
import { FormsContext } from "../context/FormsContext.jsx";

function SelectContributorSingle({
  propName,
  label,
  tooltip,
  templateName,
  dataType,
  topic,
  defaultRole = null,
  readonly = false,
}) {
  const { t } = useTranslation();
  const { control } = useFormContext();
  const { field } = useController({ control, name: propName });
  const [show, setShow] = useState(false);
  const [error, setError] = useState(null);
  const { locale, dmpId } = useContext(GlobalContext);
  const { loadedRegistries, setLoadedRegistries, setPersons, persons } =
    useContext(FormsContext);
  const [index, setIndex] = useState(null);
  const [editedPerson, setEditedPerson] = useState({});
  const [roleOptions, setRoleOptions] = useState(null);
  const tooltipId = useMemo(
    () => uniqueId("select_contributor_single_tooltip_id_"),
    [],
  );
  const options = persons.length > 0 ? createPersonsOptions(persons) : null;
  const contributor = field.value.action === "delete" ? {} : field.value;

  /**
   * Memoized values
   */
  const template = useLoadTemplate(templateName);
  const personTemplate = useLoadTemplate("PersonStandard");
  const overridableRole = useMemo(() => {
    return template?.schema?.properties?.role?.overridable || false;
  }, [template]);
  const isRoleConst = useMemo(() => {
    return template?.schema?.properties?.role?.isConst || false;
  }, [template]);
  const roleCategory = useMemo(() => {
    return template?.schema?.properties?.role?.registryCategory || null;
  }, [template]);

  /**
   * It closes the modal and resets the state of the modal.
   */
  const handleClose = () => {
    setShow(false);
    setEditedPerson(null);
    setIndex(null);
  };

  /**
   * This function handles the deletion of an element from a list and displays a confirmation message using the Swal library.
   */
  const handleDelete = (e) => {
    e.preventDefault();
    e.stopPropagation();
    Swal.fire(swalUtils.defaultConfirmConfig(t)).then((result) => {
      if (result.isConfirmed) {
        field.onChange({ ...contributor, action: "delete" });
      }
    });
  };

  const handleSelectContributor = (e) => {
    const { object } = e;
    const contributorAction = contributor?.id ? "update" : "create";
    field.onChange({
      ...contributor,
      person: { ...object, action: "update" },
      role: defaultRole,
      action: contributorAction,
    });
  };

  /**
   * The handleChangeRole function updates the role property of an object in the form state based on the selected value from a dropdown menu.
   */
  const handleSelectRole = (e) => {
    field.onChange({ ...field.value, role: e.value, action: "update" });
  };

  /**
   * If the index is not null, then delete the item at the index,
   * add the modalData item to the end of the array,
   * and then splice the item from the list array.
   * If the index is null, then just save the item.
   */
  const handleSave = (data) => {
    if (checkFragmentExists(persons, data, personTemplate.schema.unicity)) {
      setError(t("recordAlreadyExists"));
    } else {
      if (index !== null) {
        service
          .saveFragment(editedPerson.id, data)
          .then((res) => {
            const savedFragment = res.data.fragment;
            savedFragment.action = "update";
            const updatedPersons = [...persons];
            field.onChange({
              ...contributor,
              person: savedFragment,
              action: contributor.action || "update",
            });
            updatedPersons[
              updatedPersons.findIndex((el) => el.id === savedFragment.id)
            ] = {
              ...savedFragment,
              to_string: parsePattern(data, template?.schema?.to_string),
            };
            setPersons(updatedPersons);
          })
          .catch((error) => setError(error));
      } else {
        // save new
        handleSaveNew(data);
      }
      toast.success(t("saveSuccess"));
      setError(null);
    }
    setEditedPerson({});
    handleClose();
  };

  /**
   * When the user clicks the save button, the function will take the
   * temporary person object and add it to the form object, then it will parse the
   * temporary person object and add it to the list array, then it will close
   * the modal and set the temporary person object to null.
   */
  const handleSaveNew = (data) => {
    service
      .createFragment(data, personTemplate.id, dmpId)
      .then((res) => {
        const savedFragment = res.data.fragment;
        savedFragment.action = "update";
        field.onChange({
          ...contributor,
          person: savedFragment,
          role: defaultRole,
          action: contributor ? "update" : "create",
        });
        setPersons([
          ...persons,
          {
            ...savedFragment,
            to_string: parsePattern(
              savedFragment,
              personTemplate?.schema?.to_string,
            ),
          },
        ]);
      })
      .catch((error) => setError(error));
    handleClose();
    setEditedPerson({});
  };
  /**
   * It sets the state of the modalData variable to the value of the form[propName][idx] variable.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (e, idx) => {
    e.stopPropagation();
    e.preventDefault();
    setIndex(idx);
    setEditedPerson(contributor.person);
    setShow(true);
  };

  /**
   * USE EFFECTS
   */
  useEffect(() => {
    if (roleCategory && !isRoleConst) {
      service.suggestRegistry(roleCategory, dataType).then((res) => {
        setLoadedRegistries({
          ...loadedRegistries,
          [res.data.name]: res.data.values,
        });
        const options = createOptions(res.data.values, locale);
        setRoleOptions(options);
      });
    }
  }, [roleCategory, isRoleConst, dataType]);

  useEffect(() => {
    service.getPersons(dmpId).then((res) => {
      setPersons(res.data.results);
    });
  }, [dmpId, setPersons]);

  /**
   * RENDERING
   */

  return (
    <>
      <div className="form-group">
        <div className={styles.label_form}>
          <label data-tooltip-id={tooltipId}>
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
        <div className="row">
          <div className={`col-md-11 ${styles.select_wrapper}`}>
            <CustomSelect
              onSelectChange={(e) => handleSelectContributor(e)}
              options={options}
              name={propName}
              isDisabled={readonly}
              placeholder={createRegistryPlaceholder(
                1,
                false,
                true,
                "complex",
                t,
              )}
            />
          </div>
          {!readonly && (
            <div className="col-md-1">
              <ReactTooltip
                id="select-contributor-single-add-button"
                place="bottom"
                effect="solid"
                variant="info"
                content={t("add")}
              />
              <FaPlus
                data-tooltip-id="select-contributor-single-add-button"
                onClick={() => setShow(true)}
                className={styles.icon}
              />
            </div>
          )}
        </div>
        <span className={styles.errorMessage}>{error}</span>
        {template && (contributor ? [contributor] : []).length > 0 && (
          <PersonsList
            personsList={contributor ? [contributor] : []}
            handleEdit={handleEdit}
            handleDelete={handleDelete}
            roleOptions={roleOptions}
            handleSelectRole={handleSelectRole}
            defaultRole={defaultRole}
            templateToString={personTemplate?.schema?.to_string}
            tableHeader={t("selectedValue")}
            overridable={overridableRole}
            readonly={readonly}
            isRoleConst={isRoleConst}
          ></PersonsList>
        )}
      </div>
      <>
        {template && show && (
          <ModalForm
            data={editedPerson}
            template={personTemplate}
            mainFormDataType={dataType}
            mainFormTopic={topic}
            label={index !== null ? t("editPersonOrOrg") : t("addPersonOrOrg")}
            readonly={readonly}
            show={show}
            handleSave={handleSave}
            handleClose={handleClose}
            externalImport={["ror", "orcid"]}
          />
        )}
      </>
    </>
  );
}

export default SelectContributorSingle;
