import { Tooltip as ReactTooltip } from "react-tooltip";
import { useTranslation } from "react-i18next";

import CommentSVG from "../../Shared/CommentSVG";

function CommentIcon({
  isQuestionOpened,
  newCommentCount,
  fillColor,
  setModalOpened,
}) {
  const { t } = useTranslation();
  return (
    (isQuestionOpened || newCommentCount > 0) && (
      <>
        <ReactTooltip
          id="commentTooltip"
          place="bottom"
          effect="solid"
          variant="info"
          content={t("comments")}
        />
        <CommentSVG
          setModalOpened={setModalOpened}
          size={32}
          fill={fillColor}
          commentCount={newCommentCount}
        />
      </>
    )
  );
}

export default CommentIcon;
