import React, {
  useEffect, useState, useRef, useContext,
} from 'react';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import Collapse from 'react-bootstrap/Collapse';
import FormControl from 'react-bootstrap/FormControl';
import Row from 'react-bootstrap/Row';
import { FaXmark } from 'react-icons/fa6';
import { TfiAngleDown, TfiAngleUp } from 'react-icons/tfi';
import { TbBulbFilled } from 'react-icons/tb';
import { useTranslation, Trans } from 'react-i18next';
import toast from 'react-hot-toast';
import { GUIDANCES_GROUPS_LIMIT } from '../../config.js';
import { GlobalContext } from '../context/Global.jsx';
import { guidances } from '../../services/index.js';
import { CustomSpinner, CustomError } from '../Shared/index.jsx';
import CustomButton from '../Styled/CustomButton.jsx';
import GuidanceGroupItem from './GuidanceGroupItem.jsx';
import OrgWithGuidanceGroups from './OrgWithGuidanceGroups.jsx';

import * as guidanceChoiceStyles from '../assets/css/guidance_choice.module.css';
import * as formStyles from '../assets/css/form.module.css';
import debounce from 'lodash.debounce';
import { normalize } from '../../utils/utils.js';

const description = {
  fontFamily: '"Helvetica Neue", sans-serif',
  color: 'var(--blue)',
  fontSize: '16px',
  margin: '10px',
};

function GuidanceSelector({
  planId,
  researchOutputId,
  context = 'research_output',
}) {
  const { t } = useTranslation();
  const {
    savedGuidances, setSavedGuidances,
  } = useContext(GlobalContext);
  const [guidancesData, setGuidancesData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [isOpen, setIsOpen] = useState(false);
  const [selectedGuidancesIds, setSelectedGuidancesIds] = useState([]);
  const [searchCriteria, setSearchCriteria] = useState('');
  const [debouncedCriteria, setDebouncedCriteria] = useState(''); // valeur filtrante (debounced)
  const guidancesRef = useRef(null);

  const savedGuidancesIds = savedGuidances.map((g) => g.id);

  /**
   * Fetches recommendations and updates state variables.
   */
  useEffect(() => {
    const fetchGuidanceGroups = context === 'plan' ? guidances.getPlanGuidanceGroups(planId) : guidances.getResearchOutputGuidanceGroups(researchOutputId);

    setLoading(true);
    fetchGuidanceGroups
      .then((res) => {
        const { data } = res.data;
        const savedGuidances = formatSelectedGuidances(data, 'init');
        setSavedGuidances(savedGuidances);
        setSelectedGuidancesIds(data.flatMap((org) => org.guidance_groups.filter((group) => group.selected).map((group) => group.id)));
        setGuidancesData(data);
      })
      .catch((error) => { setError(error); })
      .finally(() => setLoading(false));
    setSearchCriteria('');
  }, [planId, researchOutputId]);

  // Apply debounce whenever searchCriteria changes
  useEffect(() => {
    // Create a debounced function that updates debouncedCriteria
    const handler = debounce(() => {
      setDebouncedCriteria(normalize(searchCriteria));
    }, 500);

    // Call the debounced function
    handler();

    // Cleanup: cancel pending debounce when component unmounts or searchCriteria changes
    return () => {
      handler.cancel();
    };
  }, [searchCriteria]);

  const formatSelectedGuidances = (guidanceData, action) => guidanceData.flatMap((org) => org.guidance_groups
    .filter((group) => {
      if (action === 'init') return group.selected;
      if (action === 'select') return selectedGuidancesIds.includes(group.id);
      return group;
    })
    .map((group) => ({
      id: group.id,
      name: group.name,
      description: group.description,
      orgName: org.name,
    })));

  const handleSelectGuidances = (guidance_group_ids, action) => {
    guidance_group_ids = Array.isArray(guidance_group_ids) ? guidance_group_ids : [guidance_group_ids];
    if (action === 'add') {
      setSelectedGuidancesIds([...new Set([...selectedGuidancesIds, ...guidance_group_ids])]);
    } else if (action === 'remove') {
      setSelectedGuidancesIds(selectedGuidancesIds.filter((gid) => !guidance_group_ids.includes(gid)));
    }
  };

  /**
   * The function handles saving a choice and reloading a component in a JavaScript React application.
   */
  const handleSaveChoice = async (saveContext = 'reinit') => {
    let response;
    try {
      let updateGuidanceGroups;
      switch (saveContext) {
        case 'plan':
          updateGuidanceGroups = guidances.postPlanGuidanceGroups({ guidance_group_ids: selectedGuidancesIds, ro_id: researchOutputId }, planId);
          break;
        case 'research_output':
          updateGuidanceGroups = guidances.postResearchOutputGuidanceGroups({ guidance_group_ids: selectedGuidancesIds }, researchOutputId);
          break;
        case 'reinit':
          updateGuidanceGroups = guidances.reinitResearchOutputGuidanceGroups(researchOutputId);
          break;
      }
      response = await updateGuidanceGroups;
    } catch (error) {
      console.log(error);
      return toast.error(t('errorSavingSelectedGuidances'));
    }

    const { guidance_groups } = response.data;

    const savedGuidances = formatSelectedGuidances(guidance_groups, 'init');
    setSavedGuidances(savedGuidances);
    setSelectedGuidancesIds(savedGuidances.map((sg) => sg.id));
    setGuidancesData(guidance_groups);
    guidancesRef.current.scrollTo({
      top: 0,
      behavior: 'smooth',
    });

    toast.success(t('registrationSuccess'));
  };

  const limitHasBeenReached = () => selectedGuidancesIds.length >= GUIDANCES_GROUPS_LIMIT;

  const shouldGuidanceGroupDisplay = (org, guidanceGroup) => {
    if (selectedGuidancesIds.includes(guidanceGroup.id)) return false;
    if (!debouncedCriteria) return true;
    if (normalize(guidanceGroup.name).includes(debouncedCriteria)) return true;
    if (normalize(org.name).includes(debouncedCriteria)) return true;
    return false;
  };


  if (guidancesData?.length === 0) {
    return (
      <div style={{
        width: '100%',
        border: '1px solid #cccccc',
        borderRadius: '4px',
        margin: '0 10px 0 10px',
        color: '#212529',
        backgroundColor: '#e9ecef',
        fontSize: '24px',
        textAlign: 'center',
        padding: '10px',
        cursor: 'not-allowed',
      }}>
        {t('noGuidancesAvailable')}
      </div>
    );
  }

  return (
    <Card
      id="accordion-guidance-choice"
      className={guidanceChoiceStyles.card}
      style={{
        border: '2px solid var(--dark-blue)',
        borderRadius: '10px',
      }}>
      <Card.Header style={{ background: 'var(--dark-blue)', borderRadius: isOpen ? '5px 5px 0 0' : '5px' }}>
        <Button
          style={{
            backgroundColor: 'var(--dark-blue)', width: '100%', border: 'none', margin: '0',
          }}
          onClick={() => setIsOpen(!isOpen)}
          aria-controls="guidance-choice-collapse"
          aria-expanded={isOpen}
        >
          <Card.Title style={{ margin: '0' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{
                flexGrow: 3, fontSize: '24px', fontWeight: '900', display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <TbBulbFilled
                  fill={'var(--rust)'}
                  size={38}
                  style={{ marginRight: '10px', color: 'var(--rust)' }}
                />
                <span style={{ color: 'var(--white)', marginTop: '3px' }}>{
                  context === 'plan' ? t('selectGuidancePlan') : t('selectGuidanceOutput')
                }</span>
              </div>
              <div style={{ width: '30px', marginTop: '8px' }}>
                {isOpen ? (
                  <TfiAngleUp size={24} fill={'var(--white)'} />
                ) : (
                  <TfiAngleDown size={24} fill={'var(--white)'} />
                )}
              </div>
            </div>
          </Card.Title>
        </Button>
      </Card.Header>
      <Collapse in={isOpen}>
        <div id="guidance-choice-collapse">
          <Card.Body>
            <div style={description}>
              <div style={{ textAlign: 'justify' }}>
                <Trans
                  i18nKey="guidanceListInfo"
                  components={{ br: <br />, bold: <strong /> }}
                />
              </div>
              {!loading && !error && guidancesData && (
                <>
                  <div className="row" style={{ padding: '10px' }}>
                    <div className="col-md-12" style={{ padding: '10px 0', color: 'var(--rust)' }}>
                      {t('filterAvailableGuidances')}
                    </div>
                  </div>
                  <div className="row" style={{ padding: '10px 0', width: '50%' }}>
                    <div className={`col-md-11 ${formStyles.select_wrapper}`} style={{ alignContent: 'center' }}>
                      <FormControl
                        type="text" name="guidanceSearch" placeholder={t('selectAnOrganisation')}
                        value={searchCriteria}
                        onChange={(e) => setSearchCriteria(e.target.value)} />
                    </div>
                    <div className="col-md-1" style={{ alignContent: 'center' }}>
                      <FaXmark
                        onClick={() => setSearchCriteria('')}
                        className={formStyles.icon}
                      />
                    </div>
                  </div>
                </>
              )}
              {loading && <CustomSpinner />}
              {!loading && error && <CustomError error={error} />}
              {!loading && !error && (
                <Row ref={guidancesRef}>
                  <Card className="available-guidances" style={{ flex: '1', marginRight: '5px' }}>
                    <Card.Title className={guidanceChoiceStyles.card_title}>{t('availableGuidances')}</Card.Title>
                    <Card.Body style={{ maxHeight: '500px', overflow: 'auto', scrollbarWidth: 'thin', scrollbarColor: 'var(--rust) lightgray', borderTop: '1px solid lightgray' }}>
                      {guidancesData.length > 0
                        ? guidancesData.map((org, index) => (
                          org.guidance_groups.length > 1 ? (
                            <OrgWithGuidanceGroups
                              key={index}
                              org={org}
                              isLimitReached={limitHasBeenReached()}
                              shouldGuidanceGroupDisplay={(guidance_group) => shouldGuidanceGroupDisplay(org, guidance_group)}
                              onSelect={(guidance_group_id) => handleSelectGuidances(guidance_group_id, 'add')}
                            />
                          ) : (
                            shouldGuidanceGroupDisplay(org, org.guidance_groups[0])
                            && <GuidanceGroupItem
                              key={index}
                              guidance_group_id={org.guidance_groups[0].id}
                              guidance_group_name={org.name}
                              guidance_group_description={org.guidance_groups[0].description}
                              org={org}
                              level={1}
                              isLimitReached={limitHasBeenReached()}
                              onSelect={(guidance_group_id) => handleSelectGuidances(guidance_group_id, 'add')}
                            />
                          )
                        )) : t('noGuidancesAvailable')
                      }
                    </Card.Body>
                  </Card>
                  <Card className="selected-guidances" style={{ flex: '1', marginLeft: '5px' }}>
                    <Card.Title className={guidanceChoiceStyles.card_title}>{t('selectedGuidances')}</Card.Title>
                    <Card.Body style={{ borderTop: '1px solid lightgray' }}>
                      {guidancesData.length > 0
                        ? guidancesData.map((org, index) => (
                          org.guidance_groups.length > 1 ? (
                            <OrgWithGuidanceGroups
                              key={index}
                              org={org}
                              isLimitReached={false}
                              shouldGuidanceGroupDisplay={(guidance_group) => selectedGuidancesIds.includes(guidance_group.id)}
                              getStatus={(guidance_group_id) => (savedGuidancesIds.includes(guidance_group_id) ? 'saved' : 'new')}
                              onSelect={(guidance_group_id) => handleSelectGuidances(guidance_group_id, 'remove')}
                            />
                          ) : (
                            selectedGuidancesIds.includes(org.guidance_groups[0].id)
                            && <GuidanceGroupItem
                              key={index}
                              guidance_group_id={org.guidance_groups[0].id}
                              guidance_group_name={org.name}
                              guidance_group_description={org.guidance_groups[0].description}
                              org={org}
                              level={1}
                              isLimitReached={false}
                              status={savedGuidancesIds.includes(org.guidance_groups[0].id) ? 'saved' : 'new'}
                              onSelect={(guidance_group_id) => handleSelectGuidances(guidance_group_id, 'remove')}
                            />
                          )
                        )) : t('noGuidancesSelected')
                      }
                    </Card.Body>
                  </Card>
                </Row>
              )}

              <div style={{ display: 'flex', padding: '5px', marginTop: '10px' }}>
                <div style={{ width: '50%', float: 'left', color: 'var(--rust)', fontWeight: '600', alignSelf: 'center' }}>
                  {limitHasBeenReached() ? t('guidanceLimitReached', { limit: GUIDANCES_GROUPS_LIMIT }) : null}
                </div>
                <div style={{ width: '50%', float: 'right', display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                  {!loading && !error && guidancesData && (
                    <>
                      {context === 'research_output' &&
                        <CustomButton
                          title={t('reinit')}
                          buttonColor='blue'
                          position="start"
                          handleClick={() => handleSaveChoice('reinit')}
                        />}
                      <CustomButton
                        title={t('save')}
                        buttonColor='rust'
                        position="end"
                        handleClick={() => handleSaveChoice(context)}
                      />
                    </>
                  )}
                </div>
              </div>
            </div >
          </Card.Body >
        </div >
      </Collapse >
    </Card >
  );
}

export default GuidanceSelector;
