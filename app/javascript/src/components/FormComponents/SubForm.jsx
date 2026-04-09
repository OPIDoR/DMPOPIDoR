import { useCallback, useMemo, useState } from "react";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";
import { FaPenToSquare, FaEye, FaXmark } from "react-icons/fa6";
import Swal from "sweetalert2";

import { useTranslation } from "react-i18next";
import { useController, useFormContext } from "react-hook-form";
import * as styles from "../assets/css/form.module.css";
import NestedForm from "../Forms/NestedForm.jsx";
import { fragmentEmpty } from "../../utils/utils.js";
import { parsePattern } from "../../utils/GeneratorUtils.js";
import CustomButton from "../Styled/CustomButton.jsx";
import swalUtils from "../../utils/swalUtils.js";
import TooltipInfoIcon from "./TooltipInfoIcon.jsx";
import useLoadTemplate from "../../hooks/useLoadTemplate.js";

function SubForm({
  label,
  propName,
  tooltip,
  templateName,
  dataType,
  topic,
  readonly = false,
}) {
  const { t } = useTranslation();
  const { control } = useFormContext();
  const { field } = useController({ control, name: propName });
  const [showNestedForm, setShowNestedForm] = useState(false);
  const [editedFragment, setEditedFragment] = useState({});

  const ViewEditComponent = readonly ? FaEye : FaPenToSquare;

  /** Memoized values */
  const template = useLoadTemplate(templateName);
  const tooltipId = useMemo(() => uniqueId("sub_form_tooltip_id_"), []);

  /**
   * Callback functions
   */

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

  /**
   * RENDERING
   */

  return (
    <div>
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
            readonly={readonly}
            mainFormDataType={dataType}
            mainFormTopic={topic}
            handleSave={handleSaveNestedForm}
            handleClose={handleCloseNestedForm}
          />
        )}

        {!fragmentEmpty(editedFragment) && !showNestedForm && (
          <table style={{ marginTop: "20px" }} className="table">
            <thead>
              <tr>
                <th scope="col"></th>
                <th scope="col"></th>
              </tr>
            </thead>
            <tbody>
              {[editedFragment].map((el, idx) => (
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

        {!readonly && fragmentEmpty(editedFragment) && (
          <CustomButton
            handleClick={() => {
              setEditedFragment(null);
              setShowNestedForm(true);
            }}
            title={t("addElement")}
            buttonColor="rust"
            position="start"
          ></CustomButton>
        )}
      </div>
    </div>
  );
}

export default SubForm;
