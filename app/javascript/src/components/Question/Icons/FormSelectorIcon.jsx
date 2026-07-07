import { useTranslation } from "react-i18next";
import { Tooltip as ReactTooltip } from "react-tooltip";

import * as styles from "../../assets/css/write_plan.module.css";
import { IoShuffleOutline } from "react-icons/io5";

function FormSelectorIcon({ fillColor, setModalOpened }) {
  const { t } = useTranslation();

  return (
    <div>
      <ReactTooltip
        id="form-changer-show-button"
        place="bottom"
        effect="solid"
        variant="info"
        content={t("listOfCustomizedForms")}
      />
      <div
        data-tooltip-id="form-changer-show-button"
        className={styles.card_icon}
        onClick={(e) => {
          setModalOpened(e, "formSelector", true);
        }}
        style={{ marginLeft: "5px" }}
      >
        <IoShuffleOutline
          data-tooltip-id="form-change-show-button"
          size={32}
          fill={fillColor}
          style={{
            color: fillColor,
          }}
        />
      </div>
    </div>
  );
}

export default FormSelectorIcon;
