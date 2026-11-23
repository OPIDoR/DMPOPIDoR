import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";

import * as styles from "../../assets/css/write_plan.module.css";
import { IoShuffleOutline } from "react-icons/io5";

function FormSelectorIcon({ fillColor, setModalOpened, isQuestionOpened }) {
  const { t } = useTranslation();

  return (
    isQuestionOpened && (
      <>
        <ReactTooltip
          id="formSelectorTooltip"
          place="bottom"
          effect="solid"
          variant="info"
          content={t("listOfCustomizedForms")}
        />
        <IoShuffleOutline
          data-testid="form-selector-icon"
          data-tooltip-id="formSelectorTooltip"
          className={styles.card_icon}
          onClick={(e) => {
            setModalOpened(e, "formSelector", true);
          }}
          size={32}
          fill={fillColor}
          style={{ color: fillColor }}
        />
      </>
    )
  );
}

export default FormSelectorIcon;
