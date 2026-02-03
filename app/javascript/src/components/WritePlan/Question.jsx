import React, { useContext, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import DOMPurify from 'dompurify';

import Badge from 'react-bootstrap/Badge';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import Collapse from 'react-bootstrap/Collapse';

import { Tooltip as ReactTooltip } from 'react-tooltip';
import { TfiAngleDown, TfiAngleUp } from 'react-icons/tfi';
import { BsGear } from 'react-icons/bs';
import { TbBulbFilled } from 'react-icons/tb';
import { IoShuffleOutline } from 'react-icons/io5';

import { GlobalContext } from '../context/Global';
import * as styles from '../assets/css/write_plan.module.css';
import DynamicForm from '../Forms/DynamicForm';
import GuidanceModal from './GuidanceModal';
import CommentModal from './CommentModal';
import RunsModal from './RunsModal';
import { CommentSVG } from '../Styled/svg';
import { guidances } from '../../services';

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
  const {
    openedQuestions,
    setOpenedQuestions,
    displayedResearchOutput,
    commentablePlan,
  } = useContext(GlobalContext);
  const [questionId] = useState(question.id);
  const [hasGuidances, setHasGuidances] = useState(false);
  const [answer, setAnswer] = useState(null);
  const [scriptsData, setScriptsData] = useState({ scripts: [] });
  const [showModals, setShowModals] = useState({
    guidance: false,
    comment: false,
    runs: false,
    formSelector: true,
  });

  const { formSelectors } = useContext(GlobalContext);

  const { t } = useTranslation();

  const isQuestionOpened = !!openedQuestions?.[displayedResearchOutput?.id]?.[sectionId]?.[questionId];

  useEffect(() => {
    const ans = displayedResearchOutput?.answers?.find(
      (a) => question?.id === a?.question_id,
    );
    setAnswer(ans);
  }, [displayedResearchOutput, question.id]);

  useEffect(() => {
    if (isQuestionOpened) {
      guidances.hasQuestionGuidances(questionId, displayedResearchOutput?.id)
        .then((res) => {
          setHasGuidances(res.data?.has_guidances || false);
        });
    }
  }, [isQuestionOpened, questionId]);

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

  const getFillColor = (isOpened) => (isOpened ? 'var(--rust)' : 'var(--dark-blue)');

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

  return (
    <>
      {
        <Card
          id={`question-card-${question.id}`}
          style={{
            borderRadius: '10px',
            borderWidth: '2px',
            borderColor: 'var(--dark-blue)',
            marginBottom: '20px',
          }}
        >
          <Card.Header style={{
            background: 'white', borderRadius: '18px', borderBottom: 'none', paddingBottom: '0',
          }}>
            <Button
              style={{
                backgroundColor: 'white', width: '100%', border: 'none', margin: '0', padding: '0', borderBottom: '1px solid #ddd', borderRadius: '0',
              }}
              onClick={() => handleQuestionCollapse(!isQuestionOpened)}
              aria-controls={`card-collapse-${question.id}`}
              aria-expanded={isQuestionOpened}
            >
              <Card.Title>
                <div className={styles.question_title}>
                  <div className={styles.question_text}>
                    <div className={styles.question_number} data-testid="question-number">
                      {sectionNumber}.{questionIdx}
                    </div>
                    <div
                      className={styles.card_title}
                      data-testid="question-text"
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        whiteSpace: 'break-spaces',
                        textAlign: 'justify',
                        hyphens: 'auto',
                        paddingRight: '20px',
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
                      display: 'flex',
                      justifyContent: 'flex-end',
                      maxWidth: '200px',
                    }}
                  >
                    {hasGuidances && (
                      <div>
                        <ReactTooltip
                          id="guidanceTip"
                          place="bottom"
                          effect="solid"
                          variant="info"
                          content={t('guidance')}
                        />
                        <div
                          data-tooltip-id="guidanceTip"
                          className={styles.card_icon}
                          onClick={(e) => {
                            setModalOpened(e, 'guidance', true);
                          }}
                          style={{ marginLeft: '5px' }}
                        >
                          {isQuestionOpened && (
                            <TbBulbFilled
                              size={32}
                              fill={getFillColor(showModals.guidance)}
                              style={{ color: getFillColor(showModals.guidance) }}
                            />
                          )}
                        </div>
                      </div>
                    )}

                    <div>
                      <ReactTooltip
                        id="commentTip"
                        place="bottom"
                        effect="solid"
                        variant="info"
                        content={t('comments')}
                      />
                      <div
                        data-tooltip-id="commentTip"
                        className={styles.card_icon}
                        onClick={(e) => {
                          setModalOpened(e, 'comment', true);
                        }}
                        style={{ marginLeft: '5px' }}
                      >
                        {isQuestionOpened && (
                          <CommentSVG
                            size={32}
                            fill={getFillColor(showModals.comment)}
                          />
                        )}
                      </div>
                    </div>

                    {isQuestionOpened && !answer && formSelectors[question?.madmp_schema?.classname] && (
                      <div>
                        <ReactTooltip
                          id="form-changer-show-button"
                          place="bottom"
                          effect="solid"
                          variant="info"
                          content={t('listOfCustomizedForms')}
                        />
                        <div
                          data-tooltip-id="form-changer-show-button"
                          className={styles.card_icon}
                          onClick={(e) => {
                            setModalOpened(e, 'formSelector', true);
                          }}
                          style={{ marginLeft: '5px' }}
                        >
                          <IoShuffleOutline
                            data-tooltip-id="form-change-show-button"
                            size={32}
                            fill={getFillColor(showModals.formSelector)}
                            style={{ color: getFillColor(showModals.formSelector) }}
                          />
                        </div>
                      </div>
                    )}

                    {scriptsData.scripts.length > 0 && answer && (
                      <div>
                        <ReactTooltip
                          id="scriptTip"
                          place="bottom"
                          effect="solid"
                          variant="info"
                          content={t('tools')}
                        />
                        <div
                          data-tooltip-id="scriptTip"
                          className={styles.card_icon}
                          onClick={(e) => {
                            setModalOpened(e, 'runs', true);
                          }}
                          style={{ marginLeft: '5px' }}
                        >
                          {isQuestionOpened && (
                            <BsGear
                              size={32}
                              style={{ marginTop: '6px' }}
                              fill={getFillColor(showModals.runs)}
                            />
                          )}
                        </div>
                      </div>
                    )}

                    {isQuestionOpened ? (
                      <TfiAngleUp
                        style={{ marginLeft: '5px' }}
                        size={32}
                      />
                    ) : (
                      <TfiAngleDown
                        style={{ marginLeft: '5px' }}
                        size={32}
                      />
                    )}
                  </div>
                </div>
              </Card.Title>
            </Button>
          </Card.Header>
          <Collapse in={isQuestionOpened}>
            <div id={`card-collapse-${question.id}`}>
              <Card.Body id={`card-body-${question.id}`} style={{ position: 'relative', paddingTop: '0' }}>
                {isQuestionOpened && (
                  <div>
                    {answer && (
                      <>
                        {!readonly && scriptsData.scripts.length > 0 && (
                          <RunsModal
                            shown={showModals.runs === true}
                            hide={(e) => setModalOpened(e, 'runs', false)}
                            scriptsData={scriptsData}
                            fragmentId={answer?.fragment_id}
                          />
                        )}
                      </>
                    )}
                    <CommentModal
                      shown={showModals.comment === true}
                      hide={(e) => setModalOpened(e, 'comment', false)}
                      answerId={answer?.id}
                      setAnswer={setAnswer}
                      researchOutputId={displayedResearchOutput.id}
                      planId={planId}
                      questionId={question.id}
                      commentable={commentablePlan}
                    />
                    {hasGuidances && (<GuidanceModal
                      shown={showModals.guidance === true}
                      hide={(e) => setModalOpened(e, 'guidance', false)}
                      questionId={questionId}
                      researchOutputId={displayedResearchOutput.id}
                    />)}
                  </div>
                )}
                {isQuestionOpened ? (
                  <>
                    {readonly && !answer?.id ? (<Badge variant="primary">{t('questionNotAnswered')}</Badge>)
                      : (<DynamicForm
                        fragmentId={answer?.fragment_id}
                        className={question?.madmp_schema?.classname}
                        setScriptsData={setScriptsData}
                        questionId={question.id}
                        madmpSchemaId={question.madmp_schema?.id}
                        setAnswer={setAnswer}
                        readonly={readonly}
                        formSelector={{
                          shown: showModals.formSelector === true,
                          hide: (e) => setModalOpened(e, 'formSelector', false),
                        }}
                      />)
                    }
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
