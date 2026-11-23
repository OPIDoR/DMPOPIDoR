import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";

import * as styles from "../../assets/css/write_plan.module.css";
import { BiDownload } from "react-icons/bi";

function AnswerImportIcon({ isQuestionOpened, fillColor, setModalOpened }) {
  const { t } = useTranslation();

  return (
    isQuestionOpened && (
      <>
        <ReactTooltip
          id="importTooltip"
          place="bottom"
          effect="solid"
          variant="info"
          content={t("importAnswer")}
        />
        <BiDownload
          data-testid="answer-import-icon"
          data-tooltip-id="importTooltip"
          className={styles.card_icon}
          onClick={(e) => {
            setModalOpened(e, "import", true);
          }}
          style={{ color: fillColor }}
          size={32}
          fill={fillColor}
        />
      </>
    )
  );
}

export default AnswerImportIcon;
