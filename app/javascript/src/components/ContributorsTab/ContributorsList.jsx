import React, { useState } from 'react';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import { useTranslation } from 'react-i18next';
import { FaPenToSquare, FaXmark } from 'react-icons/fa6';

import { parsePattern } from '../../utils/GeneratorUtils';
import Pagination from '../Shared/Pagination';
import { isValidHttpUrl } from '../../utils/utils';
import * as styles from '../assets/css/form.module.css';

function ContributorsList({
  contributors, template, handleEdit, handleDelete, readonly = false,
}) {
  const { t } = useTranslation();
  const pageSize = 10;
  const [page, setPage] = useState(1);
  const [currentData, setCurrentData] = useState([]);

  /**
   * The onChangePage function updates the state with a new page of items.
   */
  const onChangePage = (pageOfItems, page) => {
    // update state with new page of items
    setPage(page - 1);
    setCurrentData(pageOfItems);
  };

  return (
    <>
      <table className="table table-hover">
        <thead>
          <tr>
            <th scope="col">{t('name')}</th>
            <th scope="col" className="sorter-false">{t('affiliation')}</th>
            <th scope="col" className="sorter-false">{t('attributedRoles')}</th>
            <th scope="col" className="sorter-false">{t('actions')}</th>
          </tr>
        </thead>
        <tbody>
          {currentData.length > 0 && template ? currentData.map((contributor, idx) => (
            <tr key={contributor.id}>
              <td>
                {parsePattern(contributor.data, template?.schema?.to_string)}
                {contributor.data?.personId && (
                  isValidHttpUrl(contributor.data?.personId)
                    ? [' - ', <a key={contributor.id} href={contributor.data?.personId} target="_blank" rel="noreferrer">{contributor.data?.personId}</a>]
                    : ` - ${contributor.data?.personId}`
                )}
              </td>
              <td>
                {contributor.data?.affiliationName}
                {contributor.data?.affiliationId && (
                  isValidHttpUrl(contributor.data?.affiliationId)
                    ? [' - ', <a key={contributor.id} href={contributor.data?.affiliationId} target="_blank" rel="noreferrer">{contributor.data?.affiliationId}</a>]
                    : ` - ${contributor.data?.affiliationId}`
                )}
              </td>
              <td>
                <ul>
                  {contributor.roles.map((role, ridx) => <li key={`${contributor.id}_${ridx}`}>{role}</li>)}
                </ul>
              </td>
              <td>
                {!readonly && (
                  <>
                    <ReactTooltip
                      id="contributor-edit-button"
                      place="bottom"
                      effect="solid"
                      variant="info"
                      content={t('edit')}
                    />
                    <FaPenToSquare
                      data-tooltip-id="contributor-edit-button"
                      size={18}
                      onClick={() => handleEdit(pageSize * page + idx)}
                      className={styles.icon}
                    />
                    {contributors.length > 1
                      && <>
                        <ReactTooltip
                          id="contributor-delete-button"
                          place="bottom"
                          effect="solid"
                          variant="info"
                          content={t('delete')}
                        />
                        <FaXmark
                          data-tooltip-id="contributor-delete-button"
                          size={18}
                          onClick={() => handleDelete(pageSize * page + idx)}
                          className={styles.icon}
                        />
                      </>
                    }
                  </>
                )}
              </td>
            </tr>
          )) : (
            <tr>
              <td colSpan="5" style={{ textAlign: 'left' }}>
                {t('noData')}
              </td>
            </tr>
          )}
        </tbody>
      </table>

      {contributors.length > 0 && (
        <div className="row text-right">
          <div className="mx-auto">
            <Pagination items={contributors} onChangePage={onChangePage} pageSize={pageSize} />
          </div>
        </div>
      )}
    </>
  );
}

export default ContributorsList;
