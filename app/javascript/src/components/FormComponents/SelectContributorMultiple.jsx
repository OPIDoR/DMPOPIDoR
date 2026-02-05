import { useContext, useEffect, useState } from "react";
import { useFormContext, useFieldArray } from "react-hook-form";
import Swal from "sweetalert2";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";
import { FaPlus } from "react-icons/fa6";

import {
  createOptions,
  createRegistryPlaceholder,
  parsePattern,
} from "../../utils/GeneratorUtils.js";
import {
  checkFragmentExists,
  createPersonsOptions,
} from "../../utils/JsonFragmentsUtils.js";
import { GlobalContext } from "../context/Global.jsx";
import { service } from "../../services/index.js";
import * as styles from "../assets/css/form.module.css";
import CustomSelect from "../Shared/CustomSelect.jsx";
import PersonsList from "./PersonsList.jsx";
import ModalForm from "../Forms/ModalForm.jsx";
import swalUtils from "../../utils/swalUtils.js";
import { getErrorMessage } from "../../utils/utils.js";
import TooltipInfoIcon from "./TooltipInfoIcon.jsx";

function SelectContributorMultiple({
  label,
  propName,
  tooltip,
  header,
  templateName,
  dataType,
  topic,
  defaultRole = null,
  readonly = false,
}) {
  const { t } = useTranslation();
  const { control } = useFormContext();
  const { fields, append, update } = useFieldArray({
    control,
    name: propName,
    keyName: "_id",
  });
  const [show, setShow] = useState(false);
  const [error, setError] = useState(null);
  const [options, setOptions] = useState(null);
  const {
    locale,
    dmpId,
    persons,
    setPersons,
    loadedTemplates,
    setLoadedTemplates,
    loadedRegistries,
    setLoadedRegistries,
  } = useContext(GlobalContext);
  const [index, setIndex] = useState(null);
  const [template, setTemplate] = useState(null);
  const [roleCategory, setRoleCategory] = useState(null);
  const [editedPerson, setEditedPerson] = useState({});
  const [roleOptions, setRoleOptions] = useState(null);
  const [overridableRole, setOverridableRole] = useState(false);
  const [isRoleConst, setIsRoleConst] = useState(false);
  const tooltipId = uniqueId("select_contributor_multiple_tooltip_id_");

  /* A hook that is called when the component is mounted. */
  useEffect(() => {
    if (roleCategory && !isRoleConst) {
      fetchRoles();
    }
  }, [roleCategory, isRoleConst]);

  useEffect(() => {
    if (persons.length > 0) {
      setOptions(createPersonsOptions(persons));
    } else {
      fetchPersons();
      setOptions(null);
    }
  }, [persons]);

  const fetchPersons = () => {
    service.getPersons(dmpId).then((res) => {
      setPersons(res.data.results);
    });
  };

  const fetchRoles = () => {
    service.suggestRegistry(roleCategory, dataType).then((res) => {
      setLoadedRegistries({
        ...loadedRegistries,
        [res.data.name]: res.data.values,
      });
      const options = createOptions(res.data.values, locale);
      setRoleOptions(options);
    });
  };

  /* A hook that is called when the component is mounted. */
  useEffect(() => {
    if (!loadedTemplates[templateName]) {
      service
        .getSchemaByName(templateName)
        .then((res) => {
          const contributorTemplate = res.data;
          setLoadedTemplates({
            ...loadedTemplates,
            [templateName]: contributorTemplate,
          });
          const contributorProps =
            contributorTemplate?.schema?.properties || {};
          const personTemplateName = contributorProps.person.template_name;
          setOverridableRole(contributorProps.role.overridable || false);
          setIsRoleConst(contributorProps.role.isConst || false);
          setRoleCategory(contributorProps.role.registryCategory || null);
          service
            .getSchemaByName(personTemplateName)
            .then((resSchema) => {
              const personTemplate = resSchema.data;
              setTemplate(personTemplate);
              setLoadedTemplates({
                ...loadedTemplates,
                [personTemplateName]: personTemplate,
              });
            })
            .catch((error) => {
              setError(getErrorMessage(error));
            });
        })
        .catch((error) => {
          setError(getErrorMessage(error));
        });
    } else {
      const contributorTemplate = loadedTemplates[templateName];
      const contributorProps = contributorTemplate?.schema?.properties || {};
      const personTemplateName = contributorProps.person.template_name;
      setOverridableRole(contributorProps.role.overridable || false);
      setTemplate(loadedTemplates[personTemplateName]);
    }
  }, [templateName]);

  /**
   * It closes the modal and resets the state of the modal.
   */
  const handleClose = () => {
    setShow(false);
    setEditedPerson(null);
    setIndex(null);
  };

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleSelectContributor = (e) => {
    append({
      person: { ...e.object, action: "update" },
      role: defaultRole,
      action: "create",
    });
    setError(null);
  };

  /**
   * The handleSelectRole function updates the role property of an object in the form state based on the selected value from a dropdown menu.
   */
  const handleSelectRole = (e, index) => {
    const updatedContributor = {
      ...fields[index],
      role: e.value,
      action: fields[index].action || "update",
    };
    update(index, updatedContributor);
  };

  /**
   * If the index is not null, then delete the item at the index,
   * add the modalData item to the end of the array,
   * and then splice the item from the list array.
   * If the index is null, then just save the item.
   */
  const handleSave = (data) => {
    if (checkFragmentExists(persons, data, template.schema.unicity)) {
      setError(t("recordAlreadyExists"));
    } else {
      if (index !== null) {
        service
          .saveFragment(editedPerson.id, data)
          .then((res) => {
            const updatedPersons = [...persons];
            const savedFragment = res.data.fragment;
            savedFragment.action = "update";
            const updatedContributor = {
              ...fields[index],
              person: savedFragment,
              action: fields[index].action || "update",
            };
            update(index, updatedContributor);

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
        handleSaveNew(data);
      }
      toast.success("Save was successful !");
    }
    setEditedPerson({});
    handleClose();
  };

  /**
   * When the user clicks the save button, the function will take the
   * temporary person object and add it to the form object, then it will parse the
   * temporary person object and add it to the list array, then it will close the
   * modal and set the temporary person object to null.
   */
  const handleSaveNew = (data) => {
    service
      .createFragment(data, template.id, dmpId)
      .then((res) => {
        const savedFragment = res.data.fragment;
        savedFragment.action = "update";
        append({ person: savedFragment, role: defaultRole, action: "create" });
        setPersons([
          ...persons,
          {
            ...savedFragment,
            to_string: parsePattern(savedFragment, template?.schema?.to_string),
          },
        ]);
      })
      .catch((error) => setError(error));

    handleClose();
    setEditedPerson({});
  };

  /**
   * I want to delete an item from a list and then update the state of the list.
   */
  const handleDelete = (e, idx) => {
    e.preventDefault();
    e.stopPropagation();
    Swal.fire(swalUtils.defaultConfirmConfig(t)).then((result) => {
      if (result.isConfirmed) {
        update(idx, { ...fields[idx], action: "delete" });
      }
    });
  };

  /**
   * It sets the state of the modalData variable to the value of the form[propName][idx] variable.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (e, idx) => {
    e.preventDefault();
    e.stopPropagation();
    setIndex(idx);
    setEditedPerson(fields[idx].person);
    setShow(true);
  };

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
        <div className="row">
          <div className={`col-md-11 ${styles.select_wrapper}`}>
            <CustomSelect
              onSelectChange={handleSelectContributor}
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
                id="select-contributor-multiple-add-button"
                place="bottom"
                effect="solid"
                variant="info"
                content={t("add")}
              />
              <FaPlus
                data-tooltip-id="select-contributor-multiple-add-button"
                onClick={() => setShow(true)}
                className={styles.icon}
              />
            </div>
          )}
        </div>
        <span className={styles.errorMessage}>{error}</span>
        {template && fields.length > 0 && (
          <PersonsList
            personsList={fields}
            handleEdit={handleEdit}
            handleDelete={handleDelete}
            roleOptions={roleOptions}
            handleSelectRole={handleSelectRole}
            defaultRole={defaultRole}
            templateToString={template?.schema?.to_string}
            tableHeader={header}
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
            template={template}
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

export default SelectContributorMultiple;
