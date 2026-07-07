import { useContext, useState } from "react";
import styled from "styled-components";
import { Button, Spinner } from "react-bootstrap";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";

import { SectionsContext } from "../context/SectionsContext.jsx";
import { researchOutput } from "../../services";
import ImportResearchOutputPlaceholder from "./Placeholders/ImportResearchOutputPlaceholder";
import { setUrlParams } from "../../utils/utils.js";
import ResearchOutputSelector from "../Shared/Import/ResearchOutputSelector.jsx";
import useFetchPlansData from "../../hooks/useFetchPlansData.js";

const EndButton = styled.div`
  display: flex;
  justify-content: end;
`;

function ImportResearchOutput({ planId, handleClose }) {
  const { setResearchOutputs, setDisplayedResearchOutput } =
    useContext(SectionsContext);
  const { t } = useTranslation();
  const { data, loading: plansLoading } = useFetchPlansData();
  const [selectedResearchOutput, setSelectedResearchOutput] = useState({});
  const [importLoading, setImportLoading] = useState(false);

  const loading = plansLoading || importLoading;

  /**
   * This function handles the import of a product plan and updates the product data.
   */
  const handleImportResearchOutput = async (e) => {
    e.preventDefault();
    e.stopPropagation();
    setImportLoading(true);
    researchOutput
      .importResearchOutput({ planId, uuid: selectedResearchOutput.uuid })
      .then((res) => {
        const { research_outputs, created_ro_id } = res.data;

        setDisplayedResearchOutput(
          research_outputs.find(({ id }) => id === created_ro_id),
        );
        setResearchOutputs(research_outputs);
        setUrlParams({ research_output: created_ro_id });

        toast.success(t("importOutputSuccess"));
        return handleClose();
      })
      .catch(() => {
        setImportLoading(false);
        return toast.error(t("importError"));
      });
  };

  /**
   * RENDERING
   */

  return (
    <>
      {loading && <ImportResearchOutputPlaceholder />}
      {!loading && (
        <div style={{ margin: "25px" }}>
          <ResearchOutputSelector
            data={data}
            loading={plansLoading}
            selectedResearchOutput={selectedResearchOutput}
            setSelectedResearchOutput={setSelectedResearchOutput}
            infoMessage={t("canReuseResearchOutputInfoFromPlans")}
          />
          <EndButton>
            <Button
              variant="secondary"
              style={{ marginRight: "8px" }}
              onClick={handleClose}
              disabled={loading}
            >
              {t("close")}
            </Button>
            <Button
              variant="primary"
              style={{ backgroundColor: "var(--rust)", color: "white" }}
              onClick={handleImportResearchOutput}
              disabled={loading}
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
    </>
  );
}

export default ImportResearchOutput;
