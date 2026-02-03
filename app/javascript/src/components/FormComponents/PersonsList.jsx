import React from 'react';
import { useTranslation } from 'react-i18next';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import { FaPenToSquare, FaXmark } from 'react-icons/fa6';

import { parsePattern } from '../../utils/GeneratorUtils';
import * as styles from '../assets/css/form.module.css';
import CustomSelect from '../Shared/CustomSelect';

function PersonsList({
  personsList,
  handleEdit,
  handleDelete,
  roleOptions,
  defaultRole,
  handleSelectRole,
  parent = 'form',
  templateToString = [],
  tableHeader = null,
  overridable = false,
  readonly = false,
  isRoleConst = false,
}) {
  const { t } = useTranslation();
  return (
    <>
      {personsList && (
        <table style={{ marginTop: '20px' }} className="table" data-testid="persons-list-table">
          <thead data-testid="persons-list-table-header">
            {personsList.length > 0 && tableHeader && personsList.some((el) => el.action !== 'delete') && (
              <tr>
                <th scope="col">{tableHeader}</th>
                <th scope="col">{t('roles')}</th>
              </tr>
            )}
          </thead>
          <tbody data-testid="persons-list-table-body">
            {personsList.map((el, idx) => (el.action !== 'delete'
              ? <tr key={idx} data-testid={`persons-list-row-${idx}`}>
                <td style={{ width: '50%' }} data-testid={`persons-list-row-value-${idx}`}>
                  <div className={styles.cell_content}>
                    <div>{parsePattern(el.person, templateToString.length > 0 ? templateToString : ['$.lastName', ' ', '$.firstName'])} </div>
                    {!readonly && (
                      <div className={styles.table_container}>
                        {parent === 'form' && (
                          <>
                            <ReactTooltip
                              id="contributor-edit-button"
                              place="bottom"
                              effect="solid"
                              variant="info"
                              content={t('edit')}
                            />
                            <FaPenToSquare
                              data-testid={`persons-list-row-edit-btn-${idx}`}
                              data-tooltip-id="contributor-edit-button"
                              onClick={(e) => handleEdit(e, idx)}
                              className={styles.icon}
                            />
                          </>
                        )}
                        <ReactTooltip
                          id="contributor-delete-button"
                          place="bottom"
                          effect="solid"
                          variant="info"
                          content={t('delete')}
                        />
                        <FaXmark
                          data-testid={`persons-list-row-delete-btn-${idx}`}
                          data-tooltip-id="contributor-delete-button"
                          onClick={(e) => handleDelete(e, idx)}
                          className={styles.icon}
                        />
                      </div>
                    )}
                  </div>
                </td>
                <td style={{ verticalAlign: 'middle' }} data-testid={`persons-list-role-${idx}`}>
                  {isRoleConst && (
                    defaultRole
                  )}
                  {roleOptions && !isRoleConst && (
                    <CustomSelect
                      onSelectChange={(e) => handleSelectRole(e, idx)}
                      options={roleOptions}
                      selectedOption={{ label: el.role || defaultRole, value: el.role || defaultRole }}
                      name="role"
                      isDisabled={readonly}
                      overridable={overridable}
                    />
                  )}
                </td>
              </tr> : null
            ))}
          </tbody>
        </table>
      )}
    </>
  );
}

export default PersonsList;
