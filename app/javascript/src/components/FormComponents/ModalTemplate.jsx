import { useContext, useEffect, useState } from "react";
import { useFormContext, useFieldArray } from "react-hook-form";
import Swal from "sweetalert2";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";

import { GlobalContext } from "../context/Global.jsx";
import { service } from "../../services/index.js";
import CustomButton from "../Styled/CustomButton.jsx";
import * as styles from "../assets/css/form.module.css";
import FragmentList from "./FragmentList.jsx";
import ModalForm from "../Forms/ModalForm.jsx";
import swalUtils from "../../utils/swalUtils.js";
import { getErrorMessage } from "../../utils/utils.js";
import { checkFragmentExists } from "../../utils/JsonFragmentsUtils.js";
import TooltipInfoIcon from "./TooltipInfoIcon.jsx";

/**
 * It takes a template name as an argument, loads the template file, and then
 * renders a modal with the template file as a prop.
 * </code>
 * @returns A React component.
 */
function ModalTemplate({
  label,
  formLabel,
  propName,
  dataType,
  topic,
  tooltip,
  header,
  templateName,
  readonly = false,
  isConst = false,
}) {
  const { t } = useTranslation();
  const [show, setShow] = useState(false);
  const { loadedTemplates, setLoadedTemplates } = useContext(GlobalContext);
  const { control } = useFormContext();
  const { fields, append, update } = useFieldArray({
    control,
    name: propName,
    keyName: "_id",
  });
  const [editedFragment, setEditedFragment] = useState({});
  const [index, setIndex] = useState(null);
  const [error, setError] = useState(null);
  const tooltipId = uniqueId("modal_template_tooltip_id_");

  const [template, setTemplate] = useState(null);

  const filteredFragmentList = fields.filter((el) => el.action !== "delete");

  /**
   * The function sets the show state to false
   */
  const handleClose = () => {
    setShow(false);
    setEditedFragment(null);
    setIndex(null);
  };

  /**
   * If the modalData variable is not empty, check if the form is valid, if it is,
   * add the modalData variable to the form, if it's not, show an error message.
   */
  const handleSave = (data) => {
    if (!data) return handleClose();

    if (checkFragmentExists(fields, data, template.schema.unicity)) {
      setError(t("recordAlreadyExists"));
    } else {
      if (index !== null) {
        const updatedFragment = {
          ...fields[index],
          ...data,
          action: fields[index].action || "update",
        };
        update(index, updatedFragment);
      } else {
        handleSaveNew(data);
      }
      toast.success(t("saveSuccess"));
    }
    handleClose();
  };

  /**
   * When the user clicks the save button, the form is updated with the new data,
   * the modalData is set to null, and the modal is closed.
   */
  const handleSaveNew = (data) => {
    append({ ...data, action: "create" });
    handleClose();
  };

  /**
   * It creates a new array, then removes the item at the index specified
   * by the parameter, then sets the state to the new array.
   * @param idx - the index of the item in the array
   */
  const handleDelete = (idx) => {
    Swal.fire(swalUtils.defaultConfirmConfig(t)).then((result) => {
      if (result.isConfirmed) {
        update(idx, { ...fields[idx], action: "delete" });
      }
    });
  };

  /**
   * This function handles the edit functionality for a form element in a React component.
   */
  const handleEdit = (idx) => {
    setEditedFragment(fields[idx]);
    setShow(true);
    setIndex(idx);
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    if (!loadedTemplates[templateName]) {
      service
        .getSchemaByName(templateName)
        .then((res) => {
          setTemplate(res.data);
          setLoadedTemplates({ ...loadedTemplates, [templateName]: res.data });
        })
        .catch((error) => {
          setError(getErrorMessage(error));
        });
    } else {
      setTemplate(loadedTemplates[templateName]);
    }
  }, [templateName]);

  /**
   * RENDERING
   */

  return (
    <>
      <div className="form-group">
        <div className={styles.label_form}>
          <label data-tooltip-id={tooltipId}>
            {formLabel}
            {tooltip && <TooltipInfoIcon tooltipId={tooltipId} />}
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
        {template && filteredFragmentList.length > 0 && (
          <FragmentList
            fragmentsList={fields}
            handleEdit={handleEdit}
            handleDelete={handleDelete}
            templateToString={template?.schema?.to_string}
            tableHeader={header}
            readonly={readonly}
            isConst={isConst}
          ></FragmentList>
        )}
        {!readonly && (
          <CustomButton
            handleClick={() => {
              setEditedFragment(null);
              setShow(true);
              setIndex(null);
            }}
            title={t("addElement")}
            buttonColor="rust"
            position="start"
          ></CustomButton>
        )}
      </div>
      {template && show && (
        <ModalForm
          data={editedFragment}
          template={template}
          mainFormDataType={dataType}
          mainFormTopic={topic}
          label={
            index !== null
              ? `${t("edit")} : ${label}`
              : `${t("add")} : ${label}`
          }
          readonly={isConst ? true : readonly}
          show={show}
          handleSave={handleSave}
          handleClose={handleClose}
        />
      )}
    </>
  );
}

export default ModalTemplate;
