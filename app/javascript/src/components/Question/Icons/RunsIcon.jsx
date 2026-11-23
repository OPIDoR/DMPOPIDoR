import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";

import * as styles from "../../assets/css/write_plan.module.css";
import { BsGear } from "react-icons/bs";

function RunsIcon({ isQuestionOpened, fillColor, setModalOpened }) {
  const { t } = useTranslation();

  return (
    isQuestionOpened && (
      <>
        <ReactTooltip
          id="scriptTooltip"
          place="bottom"
          effect="solid"
          variant="info"
          content={t("tools")}
        />
        <BsGear
          data-testid="runs-icon"
          data-tooltip-id="scriptTooltip"
          className={styles.card_icon}
          onClick={(e) => {
            setModalOpened(e, "runs", true);
          }}
          style={{ color: fillColor }}
          size={32}
          fill={fillColor}
        />
      </>
    )
  );
}

export default RunsIcon;
