import { useContext, useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import DOMPurify from "dompurify";

import Badge from "react-bootstrap/Badge";
import Button from "react-bootstrap/Button";
import Card from "react-bootstrap/Card";
import Collapse from "react-bootstrap/Collapse";

import { TfiAngleDown, TfiAngleUp } from "react-icons/tfi";

import { GlobalContext } from "../context/GlobalContext.jsx";
import { SectionsContext } from "../context/SectionsContext.jsx";
import { FormsContext } from "../context/FormsContext.jsx";
import * as styles from "../assets/css/write_plan.module.css";

import DynamicForm from "../Forms/DynamicForm.jsx";
import GuidanceModal from "./GuidanceModal.jsx";
import CommentModal from "./CommentModal.jsx";
import RunsModal from "./RunsModal.jsx";
import CommentIcon from "./Icons/CommentIcon.jsx";
import FormSelectorIcon from "./Icons/FormSelectorIcon.jsx";
import GuidanceIcon from "./Icons/GuidanceIcon.jsx";
import RunsIcon from "./Icons/RunsIcon.jsx";
import AnswerImportIcon from "./Icons/AnswerImportIcon.jsx";

import { guidances } from "../../services/index.js";
import AnswerImportModal from "./AnswerImportModal.jsx";

const closedModalState = {
  guidance: false,
  comment: false,
  runs: false,
  formSelector: false,
};
function Question({
  planId,
  question,
  questionIdx,
  sectionId,
  sectionNumber,
  readonly,
}) {
  const { commentablePlan } = useContext(GlobalContext);
  const { formSelectors } = useContext(FormsContext);
  const {
    openedQuestions,
    setOpenedQuestions,
    displayedResearchOutput,
    updateResearchOutputAnswer,
  } = useContext(SectionsContext);
  const { t } = useTranslation();
  const [hasGuidances, setHasGuidances] = useState(false);
  const [scriptsData, setScriptsData] = useState({ scripts: [] });
  const [showModals, setShowModals] = useState({
    guidance: false,
    comment: false,
    runs: false,
    formSelector: true,
    import: false,
  });

  /**
   * Memoized values
   */
  const questionId = useMemo(() => question.id, [question.id]);
  const isQuestionOpened = useMemo(() => {
    return !!openedQuestions?.[displayedResearchOutput?.id]?.[sectionId]?.[
      questionId
    ];
  }, [openedQuestions, displayedResearchOutput, sectionId, questionId]);

  const answer = useMemo(() => {
    return (
      displayedResearchOutput?.answers?.find(
        (a) => questionId === a?.question_id,
      ) || null
    );
  }, [displayedResearchOutput.answers, questionId]);

  /**
   * Handles toggling the open/collapse state of a question.
   * This function is called when a question is collapsed or expanded.
   * It updates the state of opened questions based on the changes.
   */
  const handleQuestionCollapse = (expanded) => {
    const updatedState = { ...openedQuestions[displayedResearchOutput.id] };

    if (!updatedState[sectionId]) {
      updatedState[sectionId] = {
        [questionId]: false,
      };
    }

    updatedState[sectionId] = {
      ...updatedState[sectionId],
      [questionId]: expanded,
    };

    setOpenedQuestions({
      ...openedQuestions,
      [displayedResearchOutput.id]: updatedState,
    });
  };

  const getFillColor = (isOpened) =>
    isOpened ? "var(--rust)" : "var(--dark-blue)";

  /**
   * Handles a given modal state according to the modalType & the state
   */
  const setModalOpened = (e, modalType, isOpened) => {
    if (e) {
      e.stopPropagation();
      e.preventDefault();
    }
    setShowModals({ ...closedModalState, [modalType]: isOpened });
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    if (isQuestionOpened) {
      guidances
        .hasQuestionGuidances(questionId, displayedResearchOutput?.id)
        .then((res) => {
          setHasGuidances(res.data?.has_guidances || false);
        });
    }
  }, [isQuestionOpened, questionId]);

  /**
   * RENDERING
   */

  return (
    <>
      {
        <Card
          id={`question-card-${questionId}`}
          style={{
            borderRadius: "10px",
            borderWidth: "2px",
            borderColor: "var(--dark-blue)",
            marginBottom: "20px",
          }}
        >
          <Card.Header
            style={{
              background: "white",
              borderRadius: "18px",
              borderBottom: "none",
              paddingBottom: "0",
            }}
          >
            <Button
              style={{
                backgroundColor: "white",
                width: "100%",
                border: "none",
                margin: "0",
                padding: "0",
                borderBottom: "1px solid #ddd",
                borderRadius: "0",
              }}
              onClick={() => handleQuestionCollapse(!isQuestionOpened)}
              aria-controls={`card-collapse-${questionId}`}
              aria-expanded={isQuestionOpened}
            >
              <Card.Title>
                <div className={styles.question_title}>
                  <div className={styles.question_text}>
                    <div
                      className={styles.question_number}
                      data-testid="question-number"
                    >
                      {sectionNumber}.{questionIdx}
                    </div>
                    <div
                      className={styles.card_title}
                      data-testid="question-text"
                      style={{
                        fontSize: "18px",
                        fontWeight: "bold",
                        whiteSpace: "break-spaces",
                        textAlign: "justify",
                        hyphens: "auto",
                        paddingRight: "20px",
                      }}
                      dangerouslySetInnerHTML={{
                        __html: DOMPurify.sanitize([question.text]),
                      }}
                    />
                  </div>

                  <div
                    id="icons-container"
                    className={styles.question_icons}
                    style={{
                      display: "flex",
                      justifyContent: "flex-end",
                      maxWidth: "200px",
                    }}
                  >
                    {hasGuidances && (
                      <GuidanceIcon
                        isQuestionOpened={isQuestionOpened}
                        fillColor={getFillColor(showModals.guidance)}
                        setModalOpened={setModalOpened}
                      />
                    )}

                    <CommentIcon
                      isQuestionOpened={isQuestionOpened}
                      fillColor={getFillColor(showModals.comment)}
                      setModalOpened={setModalOpened}
                    />

                    {isQuestionOpened &&
                      !answer &&
                      formSelectors[question?.madmp_schema?.classname] && (
                        <FormSelectorIcon
                          fillColor={getFillColor(showModals.formSelector)}
                          setModalOpened={setModalOpened}
                        />
                      )}

                    {scriptsData.scripts.length > 0 && answer && (
                      <RunsIcon
                        isQuestionOpened={isQuestionOpened}
                        fillColor={getFillColor(showModals.runs)}
                        setModalOpened={setModalOpened}
                      />
                    )}

                    <AnswerImportIcon
                      isQuestionOpened={isQuestionOpened}
                      fillColor={getFillColor(showModals.import)}
                      setModalOpened={setModalOpened}
                    />

                    {isQuestionOpened ? (
                      <TfiAngleUp style={{ marginLeft: "5px" }} size={32} />
                    ) : (
                      <TfiAngleDown style={{ marginLeft: "5px" }} size={32} />
                    )}
                  </div>
                </div>
              </Card.Title>
            </Button>
          </Card.Header>
          <Collapse in={isQuestionOpened}>
            <div id={`card-collapse-${questionId}`}>
              <Card.Body
                id={`card-body-${questionId}`}
                style={{ position: "relative", paddingTop: "0" }}
              >
                {isQuestionOpened && (
                  <div>
                    {answer && (
                      <>
                        {!readonly && scriptsData.scripts.length > 0 && (
                          <RunsModal
                            shown={showModals.runs === true}
                            hide={(e) => setModalOpened(e, "runs", false)}
                            scriptsData={scriptsData}
                            fragmentId={answer?.fragment_id}
                          />
                        )}
                      </>
                    )}
                    <CommentModal
                      shown={showModals.comment === true}
                      hide={(e) => setModalOpened(e, "comment", false)}
                      answerId={answer?.id}
                      setAnswer={(newAnswer) =>
                        updateResearchOutputAnswer(questionId, newAnswer)
                      }
                      researchOutputId={displayedResearchOutput.id}
                      planId={planId}
                      questionId={questionId}
                      commentable={commentablePlan}
                    />
                    {hasGuidances && (
                      <GuidanceModal
                        shown={showModals.guidance === true}
                        hide={(e) => setModalOpened(e, "guidance", false)}
                        questionId={questionId}
                        researchOutputId={displayedResearchOutput.id}
                      />
                    )}
                    <AnswerImportModal
                      shown={showModals.import === true}
                      hide={(e) => setModalOpened(e, "import", false)}
                      planId={planId}
                      questionId={questionId}
                      researchOutputId={displayedResearchOutput.id}
                      dataType={
                        displayedResearchOutput?.configuration?.dataType
                      }
                      className={question?.madmp_schema?.classname}
                      setAnswer={(newAnswer) =>
                        updateResearchOutputAnswer(questionId, newAnswer)
                      }
                    />
                  </div>
                )}
                {isQuestionOpened ? (
                  <>
                    {readonly && !answer?.id ? (
                      <Badge variant="primary">
                        {t("questionNotAnswered")}
                      </Badge>
                    ) : (
                      <DynamicForm
                        fragmentId={answer?.fragment_id}
                        className={question?.madmp_schema?.classname}
                        setScriptsData={setScriptsData}
                        questionId={questionId}
                        madmpSchemaId={question.madmp_schema?.id}
                        setAnswer={(newAnswer) =>
                          updateResearchOutputAnswer(questionId, newAnswer)
                        }
                        readonly={readonly}
                        formSelector={{
                          shown: showModals.formSelector === true,
                          hide: (e) => setModalOpened(e, "formSelector", false),
                        }}
                      />
                    )}
                  </>
                ) : (
                  <></>
                )}
              </Card.Body>
            </div>
          </Collapse>
        </Card>
      }
    </>
  );
}

export default Question;
