import { Tooltip as ReactTooltip } from "react-tooltip";
import { useTranslation } from "react-i18next";

import CommentSVG from "../../Shared/CommentSVG";
import * as styles from "../../assets/css/write_plan.module.css";

function CommentIcon({
  isQuestionOpened,
  newCommentCount,
  fillColor,
  setModalOpened,
}) {
  const { t } = useTranslation();
  return (
    <div>
      <ReactTooltip
        id="commentTip"
        place="bottom"
        effect="solid"
        variant="info"
        content={t("comments")}
      />
      <div
        data-tooltip-id="commentTip"
        className={styles.card_icon}
        onClick={(e) => {
          setModalOpened(e, "comment", true);
        }}
        style={{ marginLeft: "5px" }}
      >
        {(isQuestionOpened || newCommentCount > 0) && (
          <CommentSVG
            size={32}
            fill={fillColor}
            commentCount={newCommentCount}
          />
        )}
      </div>
    </div>
  );
}

export default CommentIcon;
