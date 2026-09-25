import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";

import * as styles from "../../assets/css/write_plan.module.css";
import { CiImport } from "react-icons/ci";

function AnswerImportIcon({ isQuestionOpened, fillColor, setModalOpened }) {
  const { t } = useTranslation();

  return (
    <div data-testid="answer-import-icon">
      <ReactTooltip
        id="importTip"
        place="bottom"
        effect="solid"
        variant="info"
        content={t("importAnswer")}
      />
      <div
        data-tooltip-id="importTip"
        className={styles.card_icon}
        onClick={(e) => {
          setModalOpened(e, "import", true);
        }}
        style={{ marginLeft: "5px" }}
      >
        {isQuestionOpened && (
          <CiImport
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

export default AnswerImportIcon;
