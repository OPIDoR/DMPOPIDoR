import { useMemo, useState } from "react";
import { Alert } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { FaVial } from "react-icons/fa6";
import { FaUniversity } from "react-icons/fa";

import * as stylesForm from "../../assets/css/form.module.css";
import CustomSelect from "../../Shared/CustomSelect";

function ResearchOutputSelector({
  data,
  loading,
  selectedResearchOutput,
  setSelectedResearchOutput,
  infoMessage = null,
}) {
  const { t } = useTranslation();
  const [selectedPlan, setSelectedPlan] = useState({});

  const plans = useMemo(() => {
    if (data?.plans) {
      return data?.plans?.map((plan) => ({
        value: plan.id,
        prependIcon:
          plan.context === "research_entity" ? (
            <FaUniversity style={{ marginRight: "8px" }} />
          ) : (
            <FaVial style={{ marginRight: "8px" }} />
          ),
        label: plan.title,
        ...plan,
        researchOutputs: plan.research_outputs.map((ro) => ({
          value: ro.id,
          label: ro.title,
          ...ro,
        })),
      }));
    }
    return [];
  }, [data]);
  /**
   * This is a function that handles the selection of a value and sets it as the type.
   */
  const handleSelectPlan = (e) => {
    setSelectedPlan(e);
    setSelectedResearchOutput(e?.researchOutputs?.at(0));
  };

  const handleSelectResearchOutput = (e) => {
    setSelectedResearchOutput(e);
  };

  /**
   * RENDERING
   */

  return (
    <>
      {plans.length > 0 ? (
        <div className="form-group">
          <div className={stylesForm.label_form}>
            <label>{t("choosePlan")}</label>
          </div>
          <div className="form-group">
            {infoMessage && <Alert variant="info">{infoMessage}</Alert>}
          </div>
          <div className="form-group">
            <FaVial /> {t("researchProject")} <FaUniversity />{" "}
            {t("researchEntity")}
          </div>
          <CustomSelect
            onSelectChange={(e) => handleSelectPlan(e)}
            options={plans}
            selectedOption={selectedPlan}
            isDisabled={loading}
            placeholder={t("selectValueFromList")}
          />
        </div>
      ) : (
        <div className="form-group">
          <Alert variant="warning">{t("noPlansComplyWithImportRules")}</Alert>
        </div>
      )}

      {selectedPlan?.researchOutputs?.length > 0 && (
        <div className="form-group">
          <div className={stylesForm.label_form}>
            <label>{t("chooseOutput")}</label>
          </div>
          <CustomSelect
            onSelectChange={(e) => handleSelectResearchOutput(e)}
            options={selectedPlan.researchOutputs}
            selectedOption={selectedResearchOutput}
            isDisabled={loading}
            placeholder={t("selectValueFromList")}
          />
        </div>
      )}
    </>
  );
}

export default ResearchOutputSelector;
