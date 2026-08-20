import { useEffect, useState, useContext } from "react";
import { Trans, useTranslation } from "react-i18next";
import Card from "react-bootstrap/Card";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";

import SectionsContent from "./SectionsContent";
import { writePlan } from "../../services";
import { GlobalContext } from "../context/GlobalContext.jsx";
import { SectionsContext } from "../context/SectionsContext.jsx";
import Forms from "../context/FormsContext.jsx";
import CustomError from "../Shared/CustomError";
import * as styles from "../assets/css/sidebar.module.css";
import PlanInformations from "./PlanInformations";
import ResearchOutputForm from "../ResearchOutput/ResearchOutputForm";
import TooltipInfoIcon from "../FormComponents/TooltipInfoIcon";
import ResearchOutputsSidebar from "./ResearchOutputsSidebar";
import WritePlanPlaceholder from "./Placeholders/WritePlanPlaceholder";

function WritePlan({ planId, readonly, configuration }) {
  const { t, i18n } = useTranslation();
  const { locale, setConfiguration } = useContext(GlobalContext);
  const {
    setOpenedQuestions,
    setDisplayedResearchOutput,
    researchOutputs,
    setResearchOutputs,
  } = useContext(SectionsContext);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [template, setTemplate] = useState(null);
  const tooltipedLabelId = uniqueId("create_research_output_tooltip_id_");

  const loadData = (planId, researchOutputId) => {
    writePlan
      .getPlanData(planId, researchOutputId)
      .then((res) => {
        setTemplate(res.data.template);

        const { research_outputs } = res.data;

        if (research_outputs.length > 0) {
          let currentResearchOutput = research_outputs[0];
          if (researchOutputId) {
            const researchOutput = research_outputs.find(
              ({ id }) => id === Number.parseInt(researchOutputId, 10),
            );
            if (researchOutput) {
              currentResearchOutput = researchOutput;
            }
          }

          setDisplayedResearchOutput(currentResearchOutput);
          researchOutputs.length === 0 && setResearchOutputs(research_outputs);
        }
      })
      .catch((error) => setError(error))
      .finally(() => setLoading(false));
  };

  const handleRefresh = (e, researchOutputId) => {
    loadData(
      e?.detail?.message?.planId || planId,
      e?.detail?.message?.roId || researchOutputId,
    );
  };

  const handleQuestionParameter = (questionId, researchOutputId) => {
    if (questionId) {
      const updatedState = { [questionId]: true };
      setOpenedQuestions({
        [researchOutputId]: updatedState,
      });
    }
  };
  /**
   * USE EFFECTS
   */

  useEffect(() => {
    i18n.changeLanguage(locale.substring(0, 2));
  }, [locale]);

  useEffect(() => {
    setConfiguration(configuration);
  }, []);

  /* A hook that is called when the component is mounted. It is used to fetch data from the API. */
  // TODO update this , it can make error
  useEffect(() => {
    const queryParameters = new URLSearchParams(window.location.search);
    const questionId = queryParameters.get("question");
    const researchOutputId = queryParameters.get("research_output");
    loadData(planId, researchOutputId);
    handleQuestionParameter(questionId, researchOutputId);

    window.addEventListener("trigger-refresh-ro-data", (e) =>
      handleRefresh(e, researchOutputId),
    );

    return () => {
      window.removeEventListener("trigger-refresh-ro-data", handleRefresh);
    };
  }, [planId]);

  /**
   * RENDERING
   */

  return (
    <div style={{ position: "relative" }}>
      {loading && <WritePlanPlaceholder />}
      {error && <CustomError error={error}></CustomError>}
      {!loading && !error && (
        <>
          {researchOutputs.length > 0 && (
            <>
              <PlanInformations template={template} />
              <div className={styles.section}>
                <ResearchOutputsSidebar
                  planId={planId}
                  readonly={readonly}
                  setLoading={setLoading}
                />
                <div className={styles.main}>
                  {planId && (
                    <Forms>
                      <SectionsContent planId={planId} readonly={readonly} />
                    </Forms>
                  )}
                </div>
              </div>
            </>
          )}
          {researchOutputs.length === 0 && (
            <div style={{ display: "flex", justifyContent: "center" }}>
              <Card style={{ width: "800px" }}>
                <Card.Body>
                  {readonly ? (
                    <h2 style={{ textAlign: "center" }}>
                      {t("planDoesNotYetIncludeAnyResearchOutput")}
                    </h2>
                  ) : (
                    <h2
                      style={{ textAlign: "center" }}
                      data-tooltip-id={tooltipedLabelId}
                    >
                      <Trans
                        t={t}
                        i18nKey="addAResearchOutput"
                        // eslint-disable-next-line react/jsx-key
                        components={[<strong>research output</strong>]}
                      />
                      <TooltipInfoIcon />
                      <ReactTooltip
                        id={tooltipedLabelId}
                        place="bottom"
                        effect="solid"
                        variant="info"
                        content={
                          <Trans
                            t={t}
                            i18nKey="researchOutputDefinition"
                            // eslint-disable-next-line react/jsx-key
                            components={[<strong>Research output</strong>]}
                          />
                        }
                      />
                    </h2>
                  )}
                  {!readonly && (
                    <div
                      style={{
                        justifyContent: "center",
                        alignItems: "center",
                        left: 0,
                      }}
                    >
                      <ResearchOutputForm
                        planId={planId}
                        handleClose={() => {}}
                        edit={false}
                      />
                    </div>
                  )}
                </Card.Body>
              </Card>
            </div>
          )}
        </>
      )}
    </div>
  );
}

export default WritePlan;
