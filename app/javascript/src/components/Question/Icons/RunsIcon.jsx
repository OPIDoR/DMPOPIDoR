import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";

import * as styles from "../../assets/css/write_plan.module.css";
import { BsGear } from "react-icons/bs";

function RunsIcon({ isQuestionOpened, fillColor, setModalOpened }) {
  const { t } = useTranslation();

  return (
    <div>
      <ReactTooltip
        id="scriptTip"
        place="bottom"
        effect="solid"
        variant="info"
        content={t("tools")}
      />
      <div
        data-tooltip-id="scriptTip"
        className={styles.card_icon}
        onClick={(e) => {
          setModalOpened(e, "runs", true);
        }}
        style={{ marginLeft: "5px" }}
      >
        {isQuestionOpened && (
          <BsGear size={32} style={{ marginTop: "6px" }} fill={fillColor} />
        )}
      </div>
    </div>
  );
}

export default RunsIcon;
