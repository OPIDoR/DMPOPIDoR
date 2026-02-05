import { useEffect, useState, useContext } from "react";
import { Trans, useTranslation } from "react-i18next";
import Card from "react-bootstrap/Card";
import { Tooltip as ReactTooltip } from "react-tooltip";
import uniqueId from "lodash.uniqueid";

import SectionsContent from "./SectionsContent";
import { writePlan } from "../../services";
import { GlobalContext } from "../context/Global";
import CustomError from "../Shared/CustomError";
import * as styles from "../assets/css/sidebar.module.css";
import PlanInformations from "./PlanInformations";
import ResearchOutputForm from "../ResearchOutput/ResearchOutputForm";
import TooltipInfoIcon from "../FormComponents/TooltipInfoIcon";
import ResearchOutputsSidebar from "./ResearchOutputsSidebar";
import WritePlanPlaceholder from "./Placeholders/WritePlanPlaceholder";

function WritePlan({ locale = "en_GB", planId, userId, readonly }) {
  const { t, i18n } = useTranslation();
  const {
    setFormData,
    setDmpId,
    setUserId,
    setLocale,
    setDisplayedResearchOutput,
    setLoadedSectionsData,
    researchOutputs,
    setResearchOutputs,
    setCommentablePlan,
  } = useContext(GlobalContext);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [template, setTemplate] = useState(null);
  const tooltipedLabelId = uniqueId("create_research_output_tooltip_id_");

  useEffect(() => {
    i18n.changeLanguage(locale.substring(0, 2));
  }, [locale]);

  /* A hook that is called when the component is mounted. It is used to fetch data from the API. */
  // TODO update this , it can make error
  useEffect(() => {
    setLoading(true);

    const queryParameters = new URLSearchParams(window.location.search);
    const researchOutputId = queryParameters.get("research_output");

    setUserId(userId);
    setLocale(locale);

    loadData(planId, researchOutputId);

    const handleRefresh = (e) => {
      loadData(
        e?.detail?.message?.planId || planId,
        e?.detail?.message?.roId || researchOutputId,
      );
    };

    window.addEventListener("trigger-refresh-ro-data", handleRefresh);

    return () => {
      window.removeEventListener("trigger-refresh-ro-data", handleRefresh);
    };
  }, [planId]);

  const loadData = (planId, researchOutputId) => {
    writePlan
      .getPlanData(planId)
      .then((res) => {
        setDmpId(res.data.dmp_id);
        setTemplate(res.data.template);
        setCommentablePlan(res.data.commentable);

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
          setLoadedSectionsData({
            [currentResearchOutput.template.id]: currentResearchOutput.template,
          });
          researchOutputs.length === 0 && setResearchOutputs(research_outputs);
        }
        setFormData(null);
      })
      .catch((error) => setError(error))
      .finally(() => setLoading(false));
  };

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
                    <SectionsContent planId={planId} readonly={readonly} />
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
