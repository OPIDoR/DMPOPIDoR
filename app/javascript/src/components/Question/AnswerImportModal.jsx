import { useContext, useEffect, useRef, useState } from "react";
import styled from "styled-components";
import toast from "react-hot-toast";
import { Trans, useTranslation } from "react-i18next";
import { Alert, Button, Card, Placeholder, Spinner } from "react-bootstrap";

import InnerModal from "../Shared/InnerModal/InnerModal.jsx";
import ImportAnswerPlaceholder from "./Placeholders/ImportAnswerPlaceholder.jsx";
import ResearchOutputSelector from "../Shared/Import/ResearchOutputSelector.jsx";
import useFetchPlansData from "../../hooks/useFetchPlansData.js";
import { madmpFragment } from "../../services/index.js";
import { FormsContext } from "../context/FormsContext.jsx";
import useHandleNewAnswerResponse from "../../hooks/useHandleNewAnswerResponse.js";

const EndButton = styled.div`
  display: flex;
  justify-content: end;
`;

function AnswerImportModal({
  shown,
  hide,
  questionId,
  researchOutputId,
  dataType = null,
  className,
  setAnswer,
}) {
  const { t } = useTranslation();
  const { setFormData, setLoadedTemplates } = useContext(FormsContext);
  const { data, loading } = useFetchPlansData(dataType, className);
  const [selectedResearchOutput, setSelectedResearchOutput] = useState(null);
  const [selectedAnswer, setSelectedAnswer] = useState(null);
  const [answerLoading, setAnswerLoading] = useState(true);

  const modalRef = useRef(null);

  /**
   * Memoized values
   */
  const handleNewAnswerResponse = useHandleNewAnswerResponse();

  /**
   * USE EFFECTS
   */
  useEffect(() => {
    if (!selectedResearchOutput) return;

    madmpFragment
      .getFragmentFromParameters(selectedResearchOutput.id, className)
      .then(({ data }) => {
        setSelectedAnswer(data);
        setAnswerLoading(false);
      })
      .catch((err) => {
        console.log(err);
        setAnswerLoading(false);
      });
  }, [selectedResearchOutput]);

  const handleAnswerImport = async (e) => {
    e.preventDefault();
    e.stopPropagation();

    let response;
    try {
      response = await madmpFragment.importFragment(
        researchOutputId,
        questionId,
        selectedAnswer.fragment_id,
      );
    } catch {
      return toast.error(t("errorAnswerImport"));
    }

    if (!response) {
      return toast.error(t("errorAnswerImport"));
    }

    if (response.data.answer_created) {
      handleNewAnswerResponse(response.data, questionId, setAnswer);
    } else {
      setFormData({ [response.data.fragment.id]: response.data.fragment });
      setLoadedTemplates((prev) => ({
        ...prev,
        [response.data.template.name]: response.data.template,
      }));
    }

    hide();
    return toast.success(t("answerImportSuccess"));
  };

  return (
    <InnerModal show={shown} ref={modalRef}>
      <InnerModal.Header
        closeButton
        expandButton
        ref={modalRef}
        onClose={() => {
          hide();
        }}
      >
        <InnerModal.Title
          id={`#import-answer-title-${questionId}-research-output-${researchOutputId}`}
        >
          {t("importAnswer")}
        </InnerModal.Title>
      </InnerModal.Header>
      <InnerModal.Body style={{ borderRadius: "0 0 10px 10px" }}>
        {loading && <ImportAnswerPlaceholder />}

        {!loading && (
          <div style={{ margin: "25px" }}>
            <ResearchOutputSelector
              data={data}
              loading={loading}
              selectedResearchOutput={selectedResearchOutput}
              setSelectedResearchOutput={setSelectedResearchOutput}
              infoMessage={t("canReuseResearchOutputInfoFromPlans")}
            />
            {selectedResearchOutput && (
              <>
                {answerLoading && (
                  <Placeholder
                    as="div"
                    animation="wave"
                    style={{ margin: "25px" }}
                  >
                    <Placeholder
                      as={Card}
                      style={{ margin: "10px", height: "30px", width: "100%" }}
                    />
                  </Placeholder>
                )}
                {!answerLoading && (
                  <Alert variant="warning">
                    <Trans
                      t={t}
                      i18nKey="answerImportFormMessage"
                      values={{
                        templateName: selectedAnswer.template_name,
                      }}
                    />
                  </Alert>
                )}
              </>
            )}
            <EndButton>
              <Button
                variant="primary"
                style={{ backgroundColor: "var(--rust)", color: "white" }}
                onClick={(e) => handleAnswerImport(e)}
                disabled={!selectedResearchOutput && (answerLoading || loading)}
              >
                {loading && (
                  <Spinner
                    as="span"
                    animation="grow"
                    size="sm"
                    role="status"
                    aria-hidden="true"
                  />
                )}
                {t("import")}
              </Button>
            </EndButton>
          </div>
        )}
      </InnerModal.Body>
    </InnerModal>
  );
}

export default AnswerImportModal;
