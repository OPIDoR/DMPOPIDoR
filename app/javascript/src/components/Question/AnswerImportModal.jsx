import { useEffect, useRef, useState } from "react";
import styled from "styled-components";
import { Trans, useTranslation } from "react-i18next";
import { Alert, Button, Card, Placeholder, Spinner } from "react-bootstrap";

import InnerModal from "../Shared/InnerModal/InnerModal.jsx";
import ImportAnswerPlaceholder from "./Placeholders/ImportAnswerPlaceholder.jsx";
import ResearchOutputSelector from "../Shared/Import/ResearchOutputSelector.jsx";
import useFetchPlansData from "../../hooks/useFetchPlansData.js";
import { madmpFragment } from "../../services/index.js";

const EndButton = styled.div`
  display: flex;
  justify-content: end;
`;

function AnswerImportModal({
  shown,
  hide,
  answerId = null,
  researchOutputId,
  dataType = null,
  className,
}) {
  const { t } = useTranslation();
  const { data, loading } = useFetchPlansData(dataType, className);
  const [selectedResearchOutput, setSelectedResearchOutput] = useState(null);
  const [selectedAnswer, setSelectedAnswer] = useState(null);
  const [answerLoading, setAnswerLoading] = useState(true);

  const modalRef = useRef(null);

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
          id={`#import-answer-title-${answerId}-research-output-${researchOutputId}`}
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
                onClick={() => {}}
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
