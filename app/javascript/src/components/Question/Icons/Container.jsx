import { TfiAngleDown, TfiAngleUp } from "react-icons/tfi";

import * as styles from "../../assets/css/write_plan.module.css";

import AnswerImportIcon from "./AnswerImportIcon";
import CommentIcon from "./CommentIcon";
import FormSelectorIcon from "./FormSelectorIcon";
import GuidanceIcon from "./GuidanceIcon";
import RunsIcon from "./RunsIcon";

function Container({
  answer,
  isQuestionOpened,
  showIcons,
  showModals,
  setModalOpened,
}) {
  const getFillColor = (isOpened) =>
    isOpened ? "var(--rust)" : "var(--dark-blue)";

  return (
    <div
      data-testid="icons-container"
      id="icons-container"
      className={styles.question_icons}
      style={{
        display: "flex",
        justifyContent: "flex-end",
        maxWidth: "200px",
      }}
    >
      {showIcons.guidanceIcon && (
        <GuidanceIcon
          isQuestionOpened={isQuestionOpened}
          fillColor={getFillColor(showModals.guidance)}
          setModalOpened={setModalOpened}
        />
      )}
      {showIcons.commentIcon && (
        <CommentIcon
          isQuestionOpened={isQuestionOpened}
          newCommentCount={answer?.new_comment_count || 0}
          fillColor={getFillColor(showModals.comment)}
          setModalOpened={setModalOpened}
        />
      )}

      {showIcons.formSelectorIcon && (
        <FormSelectorIcon
          fillColor={getFillColor(showModals.formSelector)}
          setModalOpened={setModalOpened}
        />
      )}

      {showIcons.runsIcon && (
        <RunsIcon
          isQuestionOpened={isQuestionOpened}
          fillColor={getFillColor(showModals.runs)}
          setModalOpened={setModalOpened}
        />
      )}

      {showIcons.answerImportIcon && (
        <AnswerImportIcon
          isQuestionOpened={isQuestionOpened}
          fillColor={getFillColor(showModals.import)}
          setModalOpened={setModalOpened}
        />
      )}

      {isQuestionOpened ? (
        <TfiAngleUp
          data-testid="question-angle-up"
          style={{ marginLeft: "5px" }}
          size={32}
        />
      ) : (
        <TfiAngleDown
          data-testid="question-angle-down"
          style={{ marginLeft: "5px" }}
          size={32}
        />
      )}
    </div>
  );
}

export default Container;
