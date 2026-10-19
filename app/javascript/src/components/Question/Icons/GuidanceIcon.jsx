import { Fragment } from "react";
import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";

import * as styles from "../../assets/css/write_plan.module.css";
import { TbBulbFilled } from "react-icons/tb";

function GuidanceIcon({ isQuestionOpened, fillColor, setModalOpened }) {
  const { t } = useTranslation();

  return (
    isQuestionOpened && (
      <Fragment data-testid="guidance-icon-container">
        <ReactTooltip
          id="guidanceTooltip"
          place="bottom"
          effect="solid"
          variant="info"
          content={t("guidance")}
        />
        <TbBulbFilled
          data-testid="guidance-icon"
          data-tooltip-id="guidanceTooltip"
          className={styles.card_icon}
          onClick={(e) => {
            setModalOpened(e, "guidance", true);
          }}
          size={32}
          fill={fillColor}
          style={{ color: fillColor }}
        />
      </Fragment>
    )
  );
}

export default GuidanceIcon;
