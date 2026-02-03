import React, { useContext } from 'react';
import Card from 'react-bootstrap/Card';
import { Tooltip } from 'react-tooltip';
import { AiOutlineEdit } from 'react-icons/ai';
import { FaTrash } from 'react-icons/fa6';
import { BiDuplicate } from 'react-icons/bi';
import { useTranslation } from 'react-i18next';

import { GlobalContext } from '../context/Global';
import { displayPersonalData, displayTopics } from '../../utils/GeneratorUtils';

function ResearchOutputInfobox({
  handleEdit, handleDelete, handleDuplicate, readonly,
}) {
  const { t } = useTranslation();
  const {
    researchOutputs,
    displayedResearchOutput,
  } = useContext(GlobalContext);

  return (
    <Card
      className="card-default"
      style={{
        borderRadius: '10px',
        borderWidth: '2px',
        borderColor: 'var(--dark-blue)',
      }}
    >
      <Card.Header style={{
        backgroundColor: 'var(--dark-blue)',
        borderRadius: '5px 5px 0 0',
      }}>
        <Card.Title style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          color: '#fff',
        }}>
          <strong>{displayedResearchOutput?.title}</strong>
          <span id="actions" style={{ display: 'flex', width: '100px', justifyContent: 'space-between' }}>
            {!readonly && (
              <>
                <Tooltip anchorSelect="#editBtn" place="bottom">
                  {t('edit')}
                </Tooltip>
                <button
                  type="button"
                  className="btn btn-link btn-sm m-0 p-0"
                  style={{
                    outline: 'none', color: '#fff', padding: 0, margin: '2px 5px 0 5px',
                  }}
                  onClick={handleEdit}
                  id="editBtn"
                >
                  <AiOutlineEdit size={22} />
                </button>
              </>
            )}
            {!readonly && (
              <>
                <Tooltip anchorSelect="#duplicateBtn" place="bottom">
                  {t('duplicate')}
                </Tooltip>
                <button
                  type="button"
                  className="btn btn-link btn-sm m-0 p-0"
                  style={{
                    outline: 'none', color: '#fff', padding: 0, margin: '2px 5px 0 5px',
                  }}
                  onClick={handleDuplicate}
                  id="duplicateBtn"
                >
                  <BiDuplicate size={22} />
                </button>
              </>
            )}
            {!readonly && researchOutputs.length > 0 && (
              <>
                <Tooltip anchorSelect="#deleteBtn" place="bottom">
                  {t('delete')}
                </Tooltip>
                <button
                  type="button"
                  className="btn btn-link btn-sm m-0 p-0"
                  style={{
                    outline: 'none', color: '#fff', padding: 0, margin: '2px 5px 0 5px',
                  }}
                  onClick={handleDelete}
                  id="deleteBtn"
                >
                  <FaTrash size={22} />
                </button>
              </>
            )}
          </span>
        </Card.Title>
      </Card.Header>
      <Card.Body>
        <ul>
          <li>
            {t('shortName')} : <strong>{displayedResearchOutput.abbreviation}</strong>
          </li>
          <li>
            {t('name')} : <strong>{displayedResearchOutput.title}</strong>
          </li>
          <li>
            {t('type')} : <strong>{t(displayedResearchOutput.type || '-')}</strong>
          </li>

          {displayedResearchOutput?.type && displayTopics(displayedResearchOutput.type) && (
            <li>
              {t('topic')} : <strong>{t(displayedResearchOutput.topic)}</strong>
            </li>
          )}
          {displayedResearchOutput?.type && displayPersonalData(displayedResearchOutput.type) && (
            <li>
              {t('containsPersonalData')} : <strong>{displayedResearchOutput.configuration.hasPersonalData ? t('yes') : t('no')}</strong>
            </li>
          )}
        </ul>
      </Card.Body>
    </Card>
  );
}

export default ResearchOutputInfobox;
