import React, { useState, useContext, useEffect } from 'react';
import { Trans, useTranslation } from 'react-i18next';
import { FaCheckCircle, FaPlusSquare } from 'react-icons/fa';
import set from 'lodash.set';
import { externalServices } from '../../services';
import CustomError from '../Shared/CustomError';
import CustomSpinner from '../Shared/CustomSpinner';
import Pagination from '../Shared/Pagination';
import { flattenObject, normalize } from '../../utils/utils';

import { GlobalContext } from '../context/Global';

function OrcidList({ fragment, setFragment, mapping = {} }) {
  const { t, i18n } = useTranslation();
  const pageSize = 8;
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [currentData, setCurrentData] = useState([]);
  const [selectedPerson, setSelectedPerson] = useState(null);
  const [text, setText] = useState('');
  const { locale } = useContext(GlobalContext);

  useEffect(() => {
    i18n.changeLanguage(locale.substring(0, 2));
  }, [locale]);

  /**
   * The function `getData` makes an API call to get data, sets the retrieved data in state variables, and creates an array of distinct countries from the
   * data.
   */
  const getData = async (search) => {
    setLoading(true);

    const urlRegex = /^https:\/\/orcid.org\/(?<orcid>[0-9-]+)$/i;

    if (urlRegex.test(search)) {
      // eslint-disable-next-line no-unsafe-optional-chaining
      const { orcid } = /^https:\/\/orcid.org\/(?<orcid>[0-9-]+)$/i.exec(search)?.groups;
      if (orcid) {
        search = orcid;
      }
    }

    let response;
    try {
      response = await externalServices.getOrcid(search);
    } catch (error) {
      setError(error);
      return setLoading(false);
    }

    setData(response.data);

    if (response.data.length === 0) { setCurrentData([]); }

    setLoading(false);
  };

  /**
   * The onChangePage function updates the state with a new page of items.
   */
  const onChangePage = (pageOfItems) => {
    // update state with new page of items
    setCurrentData(pageOfItems);
  };

  /**
   * The function `setSelectedValue` updates the selected key and sets a temporary object with affiliation information.
   */
  const setSelectedValue = (el) => {
    setSelectedPerson(selectedPerson === el.orcid ? null : el.orcid);
    let obj = { firstName: el.givenNames, lastName: el?.familyNames, personId: el.orcid, idType: "ORCID" };

    if (mapping && Object.keys(mapping)?.length > 0) {
      const matchData = data.find(({ orcid }) => normalize(orcid)?.includes(normalize(el.orcid)));

      if (matchData) {
        const flattenedMapping = flattenObject(mapping);

        for (const [key, value] of Object.entries(flattenedMapping)) {
          set(obj, key, matchData?.[value] || '');
        }
      }
    }

    setFragment({ ...fragment.getValues(), ...obj, nameType: 'Personal' });
  };

  /**
   * The handleChangeText function filters data based on a text input value and updates the state with the filtered results.
   */
  const handleSearchTerm = () => {
    getData(text);
  };

  /**
   * The handleKeyDown function fetch the data when the user uses the Enter button in the search field.
   */
  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      getData(text);
    }
  };

  /**
   * The function `handleDeleteText` clears the text and then retrieves data.
   */
  const handleDeleteText = () => {
    setText('');
    setData([]);
    setCurrentData([]);
  };

  return (
    <div style={{ position: 'relative' }}>
      {error && <CustomError error={error} />}
      {!error && (
        <>
          <div className="row" style={{ margin: '10px' }}>
            <div>
              <div className="row" style={{ marginBottom: '10px' }}>
                <div>
                  <i>
                    <Trans
                      t={t}
                      i18nKey="orcidIdExplanation"
                      components={[<a href="https://orcid.org/" target="_blank" rel="noopener noreferrer" style={{ textDecoration: 'underline' }}>ORCID</a>]}
                    />
                  </i>
                </div>
              </div>
              <div className="row">
                <div>
                  <div className="input-group">
                    <input
                      type="text"
                      className="form-control"
                      value={text}
                      placeholder={t('searchPerson')}
                      onChange={(e) => setText(e.target.value)}
                      onKeyDown={(e) => handleKeyDown(e)}
                      style={{
                        borderRadius: '8px 0 0 8px', borderWidth: '1px', borderColor: 'var(--dark-blue)', height: '43px',
                      }}
                    />
                    <span className="input-group-btn">
                      <button
                        className="btn btn-default"
                        type="button"
                        onClick={handleSearchTerm}
                        style={{
                          borderRadius: '0', borderWidth: '1px', borderColor: 'var(--dark-blue)', height: '43px', margin: '0',
                        }}
                      >
                        <span className="fas fa-magnifying-glass" style={{ color: 'var(--dark-blue)' }} />
                      </button>
                    </span>
                    <span className="input-group-btn">
                      <button
                        onClick={handleDeleteText}
                        className="btn btn-default"
                        type="button"
                        style={{
                          borderRadius: '0 8px 8px 0', borderWidth: '1px', borderColor: 'var(--dark-blue)', height: '43px', margin: '0',
                        }}
                      >
                        <span className="fa fa-xmark" />
                      </button>
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div>
            <table className="table table-bordered table-hover">
              <thead className="thead-dark">
                <tr>
                  <th scope="col"></th>
                  <th scope="col">{t('fullName')}</th>
                  <th scope="col">{t('orcidAffiliations')}</th>
                </tr>
              </thead>
              <tbody>
                {currentData.length > 0 ? currentData.map((el, idx) => (
                  <tr key={idx}>
                    <td>
                      {selectedPerson === el.orcid
                        ? <FaCheckCircle
                          className="text-center"
                          style={{ color: 'green' }}
                        />
                        : <FaPlusSquare
                          className="text-center"
                          style={{ cursor: 'pointer' }}
                          onClick={() => setSelectedValue(el)} />
                      }
                    </td>
                    <td>{`${el.familyNames} ${el.givenNames} `}</td>
                    <td>
                      {el?.institutionName.join(' / ')}
                    </td>
                  </tr>
                )) : (
                  <tr>
                    <td colSpan="5" style={{ textAlign: loading ? 'center' : 'left' }}>
                      { loading ? <CustomSpinner /> : t('noData') }
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
          {
            data.length > 0 && (
              <div className="row text-center">
                <div className="mx-auto"></div>
                <div className="mx-auto">
                  <Pagination items={data} onChangePage={onChangePage} pageSize={pageSize} />
                </div>
              </div>
            )
          }
        </>
      )}
    </div>
  );
}

export default OrcidList;
