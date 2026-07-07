import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";

import * as styles from "../../assets/css/write_plan.module.css";
import { TbBulbFilled } from "react-icons/tb";

function GuidanceIcon({ isQuestionOpened, fillColor, setModalOpened }) {
  const { t } = useTranslation();

  return (
    <div>
      <ReactTooltip
        id="guidanceTip"
        place="bottom"
        effect="solid"
        variant="info"
        content={t("guidance")}
      />
      <div
        data-tooltip-id="guidanceTip"
        className={styles.card_icon}
        onClick={(e) => {
          setModalOpened(e, "guidance", true);
        }}
        style={{ marginLeft: "5px" }}
      >
        {isQuestionOpened && (
          <TbBulbFilled
            size={32}
            fill={fillColor}
            style={{
              color: fillColor,
            }}
          />
        )}
      </div>
    </div>
  );
}

export default GuidanceIcon;
