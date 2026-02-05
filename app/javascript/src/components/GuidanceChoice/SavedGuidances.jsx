import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import { FaEye } from 'react-icons/fa6';
import { GlobalContext } from '../context/Global';

function SavedGuidances() {
  const { t } = useTranslation();
  const {
    savedGuidances,
  } = useContext(GlobalContext);
  return (
    <>
      {savedGuidances.length > 0 && (
        <div style={{ margin: '20px' }}>
          <h3>{t('followingGuidancesApplyToThisResearchOutput')}</h3>
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
