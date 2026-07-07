import { useFormContext } from "react-hook-form";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";

import * as styles from "../assets/css/form.module.css";
import TooltipInfoIcon from "./TooltipInfoIcon.jsx";
import { useTranslation } from "react-i18next";

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
  const { t } = useTranslation();
  const { register } = useFormContext();
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
      <div className="form-check">
        <label className={styles.switch}>
          <input
            type="checkbox"
            id={inputId}
            data-testid="checkbox"
            {...register(propName, { value: false })}
            readOnly={readonly === true}
            disabled={readonly === true}
          />
          <div className={`${styles.switchSlider} ${styles.switchRound}`}>
            <span className={styles.switchOn}>{t("yes")}</span>
            <span className={styles.switchOff}>{t("no")}</span>
          </div>
        </label>
      </div>
    </div>
  );
}
export default Checkbox;
