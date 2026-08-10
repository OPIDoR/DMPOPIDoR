import { FormCheck } from "react-bootstrap";
import { Controller, useFormContext } from "react-hook-form";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";

import * as styles from "../assets/css/form.module.css";
import TooltipInfoIcon from "./TooltipInfoIcon.jsx";

function RadioGroup({
  label,
  items = [],
  propName,
  tooltip,
  hidden = false,
  readonly = false,
}) {
  const { control } = useFormContext();
  const inputId = uniqueId("radio_group_id_");
  const tooltipedLabelId = uniqueId("radio_group_tooltip_id_");

  return (
    <div className="form-group">
      {hidden === false && (
        <div className={styles.label_form}>
          <label
            htmlFor={inputId}
            aria-labelledby={inputId}
            data-testid="radio-group-label"
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
          <div style={{ display: "flex", flexWrap: "wrap" }}>
            {items.map((item) => (
              <FormCheck
                data-testid="radio"
                style={{ width: "25%" }}
                key={item.id}
                type="radio"
                id={`item-${item.id}`}
                label={item.title}
                value={item.id}
                name={field.name}
                checked={field.value === item.id}
                onChange={() => field.onChange(item.id)}
                disabled={readonly === true}
                inline
              />
            ))}
          </div>
        )}
      />
    </div>
  );
}

export default RadioGroup;
