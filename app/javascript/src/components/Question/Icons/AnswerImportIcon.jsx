import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";

import * as styles from "../../assets/css/write_plan.module.css";
import { CiImport } from "react-icons/ci";

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
        <CiImport
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
