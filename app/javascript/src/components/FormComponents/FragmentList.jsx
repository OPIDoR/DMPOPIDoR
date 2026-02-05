import React from 'react';
import { FaPenToSquare, FaEye, FaXmark } from 'react-icons/fa6';
import DOMPurify from 'dompurify';
import { parsePattern } from '../../utils/GeneratorUtils';
import * as styles from '../assets/css/form.module.css';

function FragmentList({
  fragmentsList,
  handleEdit,
  handleDelete,
  parent = 'form',
  templateToString = [],
  tableHeader = null,
  readonly = false,
  isConst = false,
}) {
  const edit = !readonly;
  return (
    <>
      {fragmentsList && (
        <table style={{ marginTop: '20px' }} className="table table-hover" data-testid="fragment-list-table">
          {tableHeader && (
            <thead data-testid="fragment-list-table-header">
              {fragmentsList.length > 0
                && fragmentsList.some((el) => el.action !== 'delete') && (
                <tr>
                  <th scope="col">{tableHeader}</th>
                  <th scope="col">Actions</th>
                </tr>
              )}
            </thead>
          )}
          <tbody data-testid="fragment-list-table-body">
            {fragmentsList
              .map((el, idx) => (el.action !== 'delete'
                ? <tr key={idx} data-testid={`fragment-list-row-${idx}`}>
                  <td style={{ wordBreak: 'break-word' }}
                    data-testid={`fragment-list-row-value-${idx}`}
                    dangerouslySetInnerHTML={{
                      __html: DOMPurify.sanitize(parsePattern(el, templateToString)),
                    }}
                  ></td>
                  <td style={{ width: '200px' }}>
                    <div className={styles.table_container}>
                      {parent === 'form' && edit && !isConst && (
                        <FaPenToSquare
                          data-testid={`fragment-list-row-edit-btn-${idx}`}
                          size={18}
                          onClick={() => handleEdit(idx)}
                          className={styles.icon}
                        />
                      )}
                      {(isConst || readonly) && parent === 'form' && (
                        <FaEye
                          data-testid={`fragment-list-row-show-btn-${idx}`}
                          size={18}
                          onClick={() => handleEdit(idx)}
                          className={styles.icon}
                        />
                      )}
                      {(edit || (edit && isConst)) && (
                        <FaXmark
                          data-testid={`fragment-list-row-delete-btn-${idx}`}
                          onClick={() => handleDelete(idx)}
                          size={18}
                          className={styles.icon}
                        />
                      )}
                    </div>
                  </td>
                </tr> : null
              ))}
          </tbody>
        </table>
      )}
    </>
  );
}

export default FragmentList;
