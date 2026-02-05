import React, { useContext, useEffect, useState } from 'react';
import { Button, Alert, Spinner } from 'react-bootstrap';
import { Trans, useTranslation } from 'react-i18next';
import { toast } from 'react-hot-toast';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import styled from 'styled-components';
import uniqueId from 'lodash.uniqueid';
import DOMPurify from 'dompurify';

import * as stylesForm from '../assets/css/form.module.css';
import { GlobalContext } from '../context/Global';
import { researchOutput, service } from '../../services';
import { createOptions, displayPersonalData, displayTopics, researchOutputTypeToDataType } from '../../utils/GeneratorUtils';
import CustomSelect from '../Shared/CustomSelect';
import { getErrorMessage } from '../../utils/utils';
import TooltipInfoIcon from '../FormComponents/TooltipInfoIcon';

const EndButton = styled.div`
  display: flex;
  justify-content: end;
`;

function AddResearchOutput({
  planId, handleClose, inEdition = false, close = true,
}) {
  const {
    locale,
    displayedResearchOutput, setDisplayedResearchOutput,
    setLoadedSectionsData,
    setResearchOutputs,
    setUrlParams,
    researchOutputs,
  } = useContext(GlobalContext);
  const { t } = useTranslation();
  const [typeOptions, setTypeOptions] = useState([{ value: '', label: '' }]);
  const [topicOptions, setTopicOptions] = useState([{ value: '', label: '' }]);
  const [abbreviation, setAbbreviation] = useState(undefined);
  const [title, setTitle] = useState(undefined);
  const [type, setType] = useState(null);
  const [hasPersonalData, setHasPersonalData] = useState(false);
  const [selectedType, setSelectedType] = useState({ value: '', label: '' });
  const [selectedTopic, setSelectedTopic] = useState({ value: '', label: '' });
  const [disableTypeChange, setDisableTypeChange] = useState(false);
  const typeTooltipId = uniqueId('type_tooltip_id_');
  const topicTooltipId = uniqueId('topic_tooltip_id_');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (displayedResearchOutput && inEdition) {
      setAbbreviation(displayedResearchOutput.abbreviation);
      setTitle(displayedResearchOutput.title);
      setHasPersonalData(displayedResearchOutput.configuration.hasPersonalData);
      setType(displayedResearchOutput.type);
      handlePersonalData(displayedResearchOutput.type);
    }

    if (!displayedResearchOutput && !inEdition) {
      const maxOrder = researchOutputs.length > 0 ? Math.max(...researchOutputs.map((ro) => ro.order)) : 0;
      setAbbreviation(`${t('ro')} ${maxOrder + 1}`);
      setTitle(`${t('researchOutput')} ${maxOrder + 1}`);
      setHasPersonalData(true);
    }
    if (!inEdition) {
      const pos = Math.max(...researchOutputs.map(({ order }) => order));
      const nextOrder = pos < researchOutputs.length ? researchOutputs.length + 1 : pos + 1;
      setAbbreviation(`${t('ro')} ${nextOrder}`);
      setTitle(`${t('researchOutput')} ${nextOrder}`);
      setHasPersonalData(true);
    }

    setDisableTypeChange(inEdition);
  }, [displayedResearchOutput, inEdition]);

  useEffect(() => {
    service.getRegistryByName('ResearchDataType').then((res) => {
      const typeOpts = createOptions(res.data, locale);
      setTypeOptions(typeOpts);
      if (inEdition) {
        setSelectedType(typeOpts.find(({ value }) => value === displayedResearchOutput.type));
      }
    });
  }, []);

  useEffect(() => {
    service.getRegistryByName('Topics').then((res) => {
      const topicsOpts = createOptions(res.data, locale);
      setTopicOptions(topicsOpts);
      if (inEdition) {
        setSelectedTopic(topicsOpts.find(({ value }) => value === displayedResearchOutput.topic));
      }
    });
  }, []);

  /**
   * This is a function that handles the selection of a value and sets it as the type.
   */
  const handleSelectType = (e) => {
    setSelectedType(typeOptions.find(({ value }) => value === e.value));
    setType(e.value);
    handlePersonalData(e.value);
  };

  /**
   * The function handles saving data by creating an object and posting it to a server, then updating state variables and closing a modal.
   */
  const handleSave = async (e) => {
    e.stopPropagation();

    setLoading(true);

    if (!type || type.length === 0) {
      setLoading(false);
      return toast.error(t('typeRequiredToCreateResearchOutput'));
    }

    const dataType = researchOutputTypeToDataType(type);
    const researchOutputInfo = {
      plan_id: planId,
      abbreviation,
      title,
      type,
      topic: selectedTopic.value,
      configuration: {
        hasPersonalData,
        dataType,
      },
    };

    if (inEdition) {
      let res;
      try {
        res = await researchOutput.update(displayedResearchOutput.id, researchOutputInfo);
      } catch (error) {
        setLoading(false);
        toast.error(getErrorMessage(error));
        return;
      }

      setDisplayedResearchOutput(res?.data?.research_outputs?.find(({ id }) => id === displayedResearchOutput.id));
      setResearchOutputs(res?.data?.research_outputs);

      setUrlParams({ research_output: displayedResearchOutput.id });

      toast.success(t('saveSuccess'));
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

    const createdResearchOutput = res?.data?.research_outputs?.find(({ id }) => id === res?.data?.created_ro_id);
    setDisplayedResearchOutput(createdResearchOutput);
    setLoadedSectionsData({ [createdResearchOutput.template.id]: createdResearchOutput.template });
    setResearchOutputs(res?.data?.research_outputs);
    setUrlParams({ research_output: res?.data?.created_ro_id });

    toast.success(t('addOutputSuccess'));

    const event = new CustomEvent('trigger-refresh-ro-data', {
      detail: { message: { roId: res?.data?.created_ro_id, planId } },
    });
    window.dispatchEvent(event);

    setLoading(false);

    return handleClose();
  };

  const handlePersonalData = (researchOutputType) => {
    if (inEdition) return;
    if (displayPersonalData(researchOutputType)) {
      setHasPersonalData(true);
    } else {
      setHasPersonalData(false);
    }
  };

  return (
    <div style={{ margin: '25px' }}>
      <div className="form-group">
        <Alert variant="info">
          {t('canCreateNewResearchOutputAndDisplayQuestionsBySelectingType')}
        </Alert>
      </div>
      <div className="form-group">
        <div className={stylesForm.label_form}>
          <label>{t('shortName')}</label>
        </div>
        <input
          value={abbreviation || ''}
          disabled={loading}
          className={`form-control ${stylesForm.input_text}`}
          placeholder={t('addAbbreviation')}
          type="text"
          onChange={(e) => setAbbreviation(e.target.value)}
          maxLength="20"
        />
        <small className="form-text text-muted">{t('limit20Chars')}</small>
      </div>
      <div className="form-group">
        <div className={stylesForm.label_form}>
          <label>{t('name')}</label>
        </div>
        <input
          value={title || ''}
          disabled={loading}
          className={`form-control ${stylesForm.input_text}`}
          placeholder={t('addTitle')}
          onChange={(e) => setTitle(e.target.value)}
        />
      </div>
      <div className="form-group">
        <div className={stylesForm.label_form}>
          <label data-tooltip-id={typeTooltipId}>
            {t('type')}
            <TooltipInfoIcon />
            <ReactTooltip
              id={typeTooltipId}
              place="bottom"
              effect="solid"
              variant="info"
              content={<Trans
                t={t}
                i18nKey="learnMoreOutputTypes"
              />}
            />
          </label>
        </div>
        {type && !inEdition && (
          <div style={{
            fontSize: '14px',
            fontWeight: 400,
            marginBottom: '10px',
            color: 'var(--rust)',
          }}
            dangerouslySetInnerHTML={{
              __html: DOMPurify.sanitize([t('outputTypeWarning')]),
            }} />
        )}
        {typeOptions && (
          <CustomSelect
            onSelectChange={handleSelectType}
            options={typeOptions}
            selectedOption={selectedType}
            placeholder={t('Select a value from the list')}
            overridable={false}
            isDisabled={disableTypeChange}
          />
        )}
      </div>
      {type && displayTopics(type) && (
        <div className="form-group">
          <div className={stylesForm.label_form}>
            <label data-tooltip-id={topicTooltipId}>
              {t('topic')}
              <TooltipInfoIcon />
              <ReactTooltip
                id={topicTooltipId}
                place="bottom"
                effect="solid"
                variant="info"
                content={<Trans
                  t={t}
                  defaults="Topic tooltip PLACEHOLDER"
                />}
              />
            </label>
          </div>
          {topicOptions && (
            <CustomSelect
              onSelectChange={(e) => setSelectedTopic(topicOptions.find(({ value }) => value === e.value))}
              options={topicOptions}
              selectedOption={selectedTopic}
              placeholder={t('Select a value from the list')}
              overridable={false}
              isDisabled={disableTypeChange || loading}
            />
          )}
        </div>)}
      {type && displayPersonalData(type) && (
        <div className="form-group">
          <div className={stylesForm.label_form}>
            <label>{t('outputContainsPersonalData')}</label>
          </div>
          <div style={{
            fontSize: '14px',
            fontWeight: 400,
            marginBottom: '10px',
          }}>
            <i>{t('personalDataQuestionDisplayCondition')}</i>
          </div>
          <div className="form-check">
            <label className={stylesForm.switch}>
              <input type="checkbox" id="togBtn" checked={hasPersonalData} onChange={() => { setHasPersonalData(!hasPersonalData); }} />
              <div className={`${stylesForm.switchSlider} ${stylesForm.switchRound}`}>
                <span className={stylesForm.switchOn}>{t('yes')}</span>
                <span className={stylesForm.switchOff}>{t('no')}</span>
              </div>
            </label>
          </div>
        </div>
      )}
      <EndButton>
        {close && (
          <Button onClick={handleClose} style={{ margin: '0 5px 0 5px' }} disabled={loading}>
            {t('close')}
          </Button>
        )}
        <Button variant="primary" onClick={handleSave} style={{ backgroundColor: 'var(--rust)', color: 'white', margin: '0 5px 0 5px' }} disabled={loading}>
          {loading && (<Spinner
            as="span"
            animation="grow"
            size="sm"
            role="status"
            aria-hidden="true"
          />)}
          {inEdition ? t('save') : t('add')}
        </Button>
      </EndButton>
    </div>
  );
}

export default AddResearchOutput;
