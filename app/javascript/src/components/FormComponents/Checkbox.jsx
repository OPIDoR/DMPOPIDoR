import { Controller, useFormContext } from "react-hook-form";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";

import * as styles from "../assets/css/form.module.css";
import TooltipInfoIcon from "./TooltipInfoIcon.jsx";
import { FormCheck } from "react-bootstrap";

/**
 * It's a function that takes in a bunch of props and returns
 * a div with a label, an input, and a small tag.
 * @returns A React Component
 */
function Checkbox({
  label,
  propName,
  tooltip,
  hidden = false,
  readonly = false,
}) {
  const { control } = useFormContext();
  const inputId = uniqueId("checkbox_id_");
  const tooltipedLabelId = uniqueId("checkbox_tooltip_id_");

  return (
    <div className="form-group">
      {hidden === false && (
        <div className={styles.label_form}>
          <label
            htmlFor={inputId}
            aria-labelledby={inputId}
            data-testid="checkbox-label"
            data-tooltip-id={tooltipedLabelId}
          >
            {label}
            {tooltip && <TooltipInfoIcon />}
          </label>
          {tooltip && (
            <ReactTooltip
              id={tooltipedLabelId}
              place="bottom"
              effect="solid"
              variant="info"
              style={{ width: "300px", textAlign: "center" }}
              content={tooltip}
            />
          )}
        </div>
      )}
      <Controller
        name={propName}
        control={control}
        render={({ field }) => (
          <FormCheck
            data-testid="switch"
            key={propName}
            type="switch"
            id={propName}
            name={field.name}
            checked={field.value || false}
            onChange={(e) => field.onChange(e.target.checked)}
            disabled={readonly === true}
          />
        )}
      />
    </div>
  );
}
export default Checkbox;
