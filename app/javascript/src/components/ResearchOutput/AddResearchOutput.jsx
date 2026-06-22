import { useContext, useEffect, useMemo, useState } from "react";
import { Button, Alert, Spinner } from "react-bootstrap";
import { Trans, useTranslation } from "react-i18next";
import { toast } from "react-hot-toast";
import { Tooltip as ReactTooltip } from "react-tooltip";
import styled from "styled-components";
import uniqueId from "lodash.uniqueid";
import DOMPurify from "dompurify";

import * as stylesForm from "../assets/css/form.module.css";
import { GlobalContext } from "../context/GlobalContext.jsx";
import { SectionsContext } from "../context/SectionsContext.jsx";
import { researchOutput, service } from "../../services";
import {
  createOptions,
  dataTypeSelectValues,
  displayPersonalData,
  displayTopics,
} from "../../utils/GeneratorUtils";
import CustomSelect from "../Shared/CustomSelect";
import { getErrorMessage, setUrlParams } from "../../utils/utils";
import TooltipInfoIcon from "../FormComponents/TooltipInfoIcon";

const EndButton = styled.div`
  display: flex;
  justify-content: end;
`;

function AddResearchOutput({
  planId,
  handleClose,
  inEdition = false,
  close = true,
}) {
  const { locale, configuration } = useContext(GlobalContext);
  const {
    displayedResearchOutput,
    setDisplayedResearchOutput,
    researchOutputs,
    setResearchOutputs,
  } = useContext(SectionsContext);
  const { t } = useTranslation();
  /**
   * Memoized values
   */

  const typeTooltipId = useMemo(() => uniqueId("type_tooltip_id_"), []);
  const topicTooltipId = useMemo(() => uniqueId("topic_tooltip_id_"), []);
  const pos = useMemo(
    () =>
      researchOutputs.length > 0
        ? Math.max(...researchOutputs.map(({ order }) => order))
        : 0,
    [researchOutputs],
  );
  const nextOrder = useMemo(
    () => (pos < researchOutputs.length ? researchOutputs.length + 1 : pos + 1),
    [pos, researchOutputs],
  );

  const dataTypeOptions = useMemo(
    () => dataTypeSelectValues(t, configuration?.enablePhysicalObject),
    [t],
  );

  /**
   * States
   */
  const [topicOptions, setTopicOptions] = useState([{ value: "", label: "" }]);
  const [selectedDataType, setSelectedDataType] = useState({
    value: "",
    label: "",
  });
  const [selectedTopic, setSelectedTopic] = useState({ value: "", label: "" });
  const [abbreviation, setAbbreviation] = useState(() =>
    inEdition
      ? displayedResearchOutput?.abbreviation
      : `${t("ro")} ${nextOrder}`,
  );
  const [title, setTitle] = useState(() =>
    inEdition
      ? displayedResearchOutput?.title
      : `${t("researchOutput")} ${nextOrder}`,
  );
  const [dataType, setDataType] = useState(() =>
    inEdition ? displayedResearchOutput?.configuration.dataType : null,
  );
  const [hasPersonalData, setHasPersonalData] = useState(() =>
    inEdition ? displayedResearchOutput?.configuration.hasPersonalData : true,
  );
  const [loading, setLoading] = useState(false);

  /**
   * This is a function that handles the selection of a value and sets it as the type.
   */
  const handleSelectType = (e) => {
    setSelectedDataType(dataTypeOptions.find(({ value }) => value === e.value));
    setDataType(e.value);

    setHasPersonalData(displayPersonalData(e.value));
  };

  /**
   * The function handles saving data by creating an object and posting it to a server, then updating state variables and closing a modal.
   */
  const handleSave = async (e) => {
    e.stopPropagation();

    setLoading(true);

    if (!dataType || dataType.length === 0) {
      setLoading(false);
      return toast.error(t("typeRequiredToCreateResearchOutput"));
    }

    if (
      displayTopics(dataType, configuration?.enableTopics) &&
      (!selectedTopic?.value || selectedTopic?.value.length === 0)
    ) {
      setLoading(false);
      return toast.error(t("topicRequiredToCreateResearchOutput"));
    }

    const researchOutputInfo = {
      plan_id: planId,
      abbreviation,
      title,
      type: t(dataType || "-"),
      topic: selectedTopic.value ? selectedTopic.value : null,
      configuration: {
        hasPersonalData,
        dataType,
      },
    };

    if (inEdition) {
      let res;
      try {
        res = await researchOutput.update(
          displayedResearchOutput.id,
          researchOutputInfo,
        );
      } catch (error) {
        setLoading(false);
        toast.error(getErrorMessage(error));
        return;
      }

      setDisplayedResearchOutput(
        res?.data?.research_outputs?.find(
          ({ id }) => id === displayedResearchOutput.id,
        ),
      );
      setResearchOutputs(res?.data?.research_outputs);

      setUrlParams({ research_output: displayedResearchOutput.id });

      toast.success(t("saveSuccess"));
      setLoading(false);
      return handleClose();
    }

    let res;
    try {
      res = await researchOutput.create(researchOutputInfo);
    } catch (error) {
      setLoading(false);
      toast.error(getErrorMessage(error));
      return;
    }

    const createdResearchOutput = res?.data?.research_outputs?.find(
      ({ id }) => id === res?.data?.created_ro_id,
    );
    setDisplayedResearchOutput(createdResearchOutput);
    setResearchOutputs(res?.data?.research_outputs);
    setUrlParams({ research_output: res?.data?.created_ro_id });

    toast.success(t("addOutputSuccess"));

    const event = new CustomEvent("trigger-refresh-ro-data", {
      detail: { message: { roId: res?.data?.created_ro_id, planId } },
    });
    window.dispatchEvent(event);

    setLoading(false);

    return handleClose();
  };

  function displayQuestionnaireTopicWarning() {
    if (inEdition) return null;

    const shouldDisplayTopics = displayTopics(
      dataType,
      configuration?.enableTopics,
    );

    let warningText = null;
    if (shouldDisplayTopics && dataType && selectedTopic?.value) {
      warningText = t("topicWarning");
    }
    if (!shouldDisplayTopics && dataType) {
      warningText = t("outputTypeWarning");
    }

    return (
      <div
        style={{
          fontSize: "14px",
          fontWeight: 400,
          marginBottom: "10px",
          color: "var(--rust)",
        }}
        dangerouslySetInnerHTML={{
          __html: DOMPurify.sanitize([warningText]),
        }}
      />
    );
  }

  /**
   * USE EFFECTS
   */
  useEffect(() => {
    service.getRegistryByName("Topics").then((res) => {
      const topicsOpts = createOptions(res.data, locale);
      setTopicOptions(topicsOpts);

      if (inEdition) {
        setSelectedDataType(
          dataTypeOptions.find(
            ({ value }) =>
              value === displayedResearchOutput?.configuration?.dataType,
          ),
        );
        setSelectedTopic(
          topicsOpts.find(
            ({ value }) => value === displayedResearchOutput.topic,
          ),
        );
      }
    });
  }, []);

  /**
   * RENDERING
   */

  return (
    <div style={{ margin: "25px" }}>
      <div className="form-group">
        <Alert variant="info">
          <Trans t={t} i18nKey="createResearchOutputInfo" />
          {configuration?.enableTopics && (
            <>
              <br />
              <Trans t={t} i18nKey="chooseTopicInfo" />
            </>
          )}
        </Alert>
      </div>
      <div className="form-group">
        <div className={stylesForm.label_form}>
          <label>{t("shortName")}</label>
        </div>
        <input
          value={abbreviation || ""}
          disabled={loading}
          className={`form-control ${stylesForm.input_text}`}
          placeholder={t("addAbbreviation")}
          type="text"
          onChange={(e) => setAbbreviation(e.target.value)}
          maxLength="20"
        />
        <small className="form-text text-muted">{t("limit20Chars")}</small>
      </div>
      <div className="form-group">
        <div className={stylesForm.label_form}>
          <label>{t("name")}</label>
        </div>
        <input
          value={title || ""}
          disabled={loading}
          className={`form-control ${stylesForm.input_text}`}
          placeholder={t("addTitle")}
          onChange={(e) => setTitle(e.target.value)}
        />
      </div>
      <div className="form-group">
        <div className={stylesForm.label_form}>
          <label data-tooltip-id={typeTooltipId}>
            {t("selectQuestionnaire")}
            <TooltipInfoIcon />
            <ReactTooltip
              id={typeTooltipId}
              place="right"
              effect="solid"
              variant="info"
              content={<Trans t={t} i18nKey="learnMoreQuestionnaires" />}
            />
          </label>
        </div>
        {dataTypeOptions && (
          <CustomSelect
            onSelectChange={handleSelectType}
            options={dataTypeOptions}
            selectedOption={selectedDataType}
            placeholder={t("selectValueFromList")}
            overridable={false}
            isDisabled={inEdition || loading}
          />
        )}
      </div>
      {dataType && displayTopics(dataType, configuration?.enableTopics) && (
        <div className="form-group">
          <div className={stylesForm.label_form}>
            <label data-tooltip-id={topicTooltipId}>
              {t("selectTopic")}
              <TooltipInfoIcon />
              <ReactTooltip
                id={topicTooltipId}
                place="bottom"
                effect="solid"
                variant="info"
                content={<Trans t={t} i18nKey="topicTooltip" />}
              />
            </label>
          </div>
          {topicOptions && (
            <CustomSelect
              onSelectChange={(e) =>
                setSelectedTopic(
                  topicOptions.find(({ value }) => value === e.value),
                )
              }
              options={topicOptions}
              selectedOption={selectedTopic}
              placeholder={t("selectValueFromList")}
              overridable={false}
              isDisabled={inEdition || loading}
            />
          )}
        </div>
      )}
      {displayQuestionnaireTopicWarning()}
      {dataType && displayPersonalData(dataType) && (
        <div className="form-group">
          <div className={stylesForm.label_form}>
            <label>{t("outputContainsPersonalData")}</label>
          </div>
          <div
            style={{
              fontSize: "14px",
              fontWeight: 400,
              marginBottom: "10px",
            }}
          >
            <i>{t("personalDataQuestionDisplayCondition")}</i>
          </div>
          <div className="form-check">
            <label className={stylesForm.switch}>
              <input
                type="checkbox"
                id="togBtn"
                checked={hasPersonalData}
                onChange={() => {
                  setHasPersonalData(!hasPersonalData);
                }}
              />
              <div
                className={`${stylesForm.switchSlider} ${stylesForm.switchRound}`}
              >
                <span className={stylesForm.switchOn}>{t("yes")}</span>
                <span className={stylesForm.switchOff}>{t("no")}</span>
              </div>
            </label>
          </div>
        </div>
      )}
      <EndButton>
        {close && (
          <Button
            onClick={handleClose}
            style={{ margin: "0 5px 0 5px" }}
            disabled={loading}
          >
            {t("close")}
          </Button>
        )}
        <Button
          variant="primary"
          onClick={handleSave}
          style={{
            backgroundColor: "var(--rust)",
            color: "white",
            margin: "0 5px 0 5px",
          }}
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
          {inEdition ? t("save") : t("add")}
        </Button>
      </EndButton>
    </div>
  );
}

export default AddResearchOutput;
