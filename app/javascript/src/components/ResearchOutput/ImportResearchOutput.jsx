import React, { useContext, useEffect, useState } from 'react';
import styled from 'styled-components';
import { Button, Alert, Spinner } from 'react-bootstrap';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { FaVial } from 'react-icons/fa6';
import { FaUniversity } from 'react-icons/fa';

import * as stylesForm from '../assets/css/form.module.css';
import { GlobalContext } from '../context/Global';
import { researchOutput } from '../../services';
import CustomSelect from '../Shared/CustomSelect';
import ImportResearchOutputPlaceholder from './Placeholders/ImportResearchOutputPlaceholder';

const EndButton = styled.div`
  display: flex;
  justify-content: end;
`;

function ImportResearchOutput({ planId, handleClose }) {
  const {
    setResearchOutputs,
    setDisplayedResearchOutput,
    setUrlParams,
  } = useContext(GlobalContext);
  const { t } = useTranslation();
  const [plans, setPlans] = useState([]);
  const [selectedPlan, setSelectedPlan] = useState({});
  const [selectedResearchOutput, setSelectedResearchOutput] = useState({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    researchOutput.getPlans().then(({ data }) => {
      const plans = data?.plans?.map((plan) => ({
        value: plan.id,
        prependIcon: plan.context === 'research_entity' ? <FaUniversity style={{ marginRight: '8px' }} /> : <FaVial style={{ marginRight: '8px' }} />,
        label: plan.title,
        ...plan,
        researchOutputs: plan.research_outputs.map((ro) => ({
          value: ro.id,
          label: ro.title,
          ...ro,
        })),
      }));
      setPlans(plans || []);
      setLoading(false);
    });
  }, []);

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
   * This function handles the import of a product plan and updates the product data.
   */
  const handleImportResearchOutput = async (e) => {
    e.preventDefault();
    e.stopPropagation();
    setLoading(true);
    researchOutput.importResearchOutput({ planId, uuid: selectedResearchOutput.uuid }).then((res) => {
      const { research_outputs, created_ro_id } = res.data;

      setDisplayedResearchOutput(research_outputs.find(({ id }) => id === created_ro_id));
      setResearchOutputs(research_outputs);
      // setLoadedSectionsData({ [currentResearchOutput.template.id]: currentResearchOutput.template })
      setUrlParams({ research_output: created_ro_id });

      toast.success(t('importOutputSuccess'));
      return handleClose();
    }).catch(() => {
      setLoading(false);
      return toast.error(t('importError'));
    });
  };

  return (
    <>
      {loading && <ImportResearchOutputPlaceholder />}
      {!loading && <div style={{ margin: '25px' }}>
        {plans.length > 0 ? (
          <div className="form-group">
            <div className={stylesForm.label_form}>
              <label>{t('choosePlan')}</label>
            </div>
            <div className="form-group">
              <Alert variant="info">
                {t('canReuseResearchOutputInfoFromPlans')}
              </Alert>
            </div>
            <div className="form-group">
              <FaVial /> {t('researchProject')} <FaUniversity /> {t('researchEntity')}
            </div>
            <CustomSelect
              onSelectChange={(e) => handleSelectPlan(e)}
              options={plans}
              selectedOption={selectedPlan}
              isDisabled={loading}
              placeholder={t('selectValueFromList')}
            />
          </div>
        ) : (
          <div className="form-group">
            <Alert variant="warning">
              {t('noPlansComplyWithImportRules')}
            </Alert>
          </div>
        )}

        {selectedPlan?.researchOutputs?.length > 0 && (
          < div className="form-group">
            <div className={stylesForm.label_form}>
              <label>{t('chooseOutput')}</label>
            </div>
            <CustomSelect
              onSelectChange={(e) => handleSelectResearchOutput(e)}
              options={selectedPlan.researchOutputs}
              selectedOption={selectedResearchOutput}
              isDisabled={loading}
              placeholder={t('selectValueFromList')}
            />
          </div>
        )}
        <EndButton>
          <Button variant="secondary" style={{ marginRight: '8px' }} onClick={handleClose} disabled={loading}>
            {t('close')}
          </Button>
          <Button variant="primary" style={{ backgroundColor: 'var(--rust)', color: 'white' }} onClick={handleImportResearchOutput} disabled={loading}>
            {loading && (<Spinner
              as="span"
              animation="grow"
              size="sm"
              role="status"
              aria-hidden="true"
            />)}
            {t('import')}
          </Button>
        </EndButton>
      </div>
      }
    </>
  );
}

export default ImportResearchOutput;
