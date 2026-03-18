import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import { FaEye, FaCircleInfo } from 'react-icons/fa6';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import { GlobalContext } from '../context/Global';

function SavedGuidances() {
  const { t } = useTranslation();
  const {
    savedGuidances,
  } = useContext(GlobalContext);
  return (
    <>
      {savedGuidances.length > 0 && (
        <div style={{ paddingLeft: '20px', flex: 1 }}>
          <h3 style={{fontWeight: "bold"}}>
            {t('followingGuidancesApplyToThisResearchOutput')}
            <ReactTooltip
              id="saved-guidances-info-tooltip"
              place="bottom"
              effect="solid"
              variant="info"
              content={t("savedGuidancesInfo")}
              style={{ width: "30%" }}
            />
            <FaCircleInfo
              data-tooltip-id="saved-guidances-info-tooltip"
              size={18}
              style={{ paddingLeft: "5px" }}
            />
          </h3>
          <ul>
            {savedGuidances.map((guidance) => (
              <li key={guidance.id}>
                {guidance.name} ({t('providedBy')} {guidance.orgName})
                <a href={`/guidance_group_export/${guidance.id}.pdf`} target="_blank" rel="noopener noreferrer">
                  <FaEye size={14} style={{ marginLeft: '5px' }} />
                </a>
              </li>
            ))}
          </ul>
        </div>
      )}
    </>
  );
}

export default SavedGuidances;
