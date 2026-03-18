import React, { useState } from 'react';
import { Trans, useTranslation } from 'react-i18next';
import set from 'lodash.set';
import { FaLink } from 'react-icons/fa6';
import { FaCheckCircle, FaPlusSquare } from 'react-icons/fa';
import Select from 'react-select';
import { externalServices } from '../../services';
import CustomSpinner from '../Shared/CustomSpinner';
import CustomError from '../Shared/CustomError';
import Pagination from '../Shared/Pagination';
import { flattenObject, normalize } from '../../utils/utils';

function RorList({
  fragment, setFragment, mapping = {}, locale,
}) {
  const { t } = useTranslation();
  const pageSize = 8;
  const [data, setData] = useState([]);
  const [filteredData, setFilteredData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [currentData, setCurrentData] = useState([]);
  const [countries, setCountries] = useState([]);
  const [selectedOrg, setSelectedOrg] = useState(null);
  const [text, setText] = useState('');
  const [selectedCountry, setSelectedCountry] = useState(null);

  const localeCode = locale.split('_').at(0);

  /**
   * The function `getData` makes an API call to get data, sets the retrieved data in state variables, and creates an array of distinct countries from the
   * data.
   */
  const getData = async (query, filter) => {
    setLoading(true);

    let response;
    try {
      response = await externalServices.getRor(query, filter);
    } catch (error) {
      setError(error);
      return setLoading(false);
    }

    setData(response.data);
    setFilteredData(response.data);

    if (response.data.length === 0) { setCurrentData([]); }

    const options = response.data.map((option) => ({
      value: option.country.code,
      label: option.country.name,
      object: option,
    }));

    // get distinct array of objects
    const distinctCountries = Object.values(
      options.reduce((acc, cur) => {
        if (!acc[cur.value]) acc[cur.value] = cur;
        return acc;
      }, {}),
    );
    setCountries(distinctCountries);

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
    setSelectedOrg(selectedOrg === el.ror ? null : el.ror);
    const obj = {
      affiliationId: el.ror,
      affiliationName: el?.name?.[localeCode || el?.country?.code.toLowerCase()] || el?.name[Object.keys(el?.name).at(0)],
      affiliationIdType: el?.type,
      acronyms: Array.isArray(el.acronyms) ? el.acronyms?.at(0) : el.acronyms,
    };

    if (mapping && Object.keys(mapping)?.length > 0) {
      const matchData = data.find(({ ror }) => normalize(ror)?.includes(normalize(el.ror)));

      if (matchData) {
        const flattenedMapping = flattenObject(mapping);

        for (const [key, value] of Object.entries(flattenedMapping)) {
          if (key === 'name') {
            set(obj, value, el?.name[el?.country?.code?.toLowerCase()] || el?.name?.[Object.keys(el?.name).at(0)]) || '';
          } else {
            set(obj, value, matchData?.[key] || '');
          }
        }
      }
    }

    setFragment({ ...fragment.getValues(), ...obj });
  };

  /**
   * The handleChangeCounty function filters an array of data based on the selected country code and updates the data state.
   */
  const handleChangeCountry = async (e) => {
    setSelectedCountry(e?.value);
    setLoading(true);

    let response;
    try {
      response = await externalServices.getRor(text, e ? `country.country_code:${e.value}` : null);
    } catch (error) {
      setError(error);
      return setLoading(false);
    } finally {
      setLoading(false);
    }

    setFilteredData(response.data);
    setData(response.data);
  };

  /**
   * The handleSearchTerm function filters data based on a text input value and updates the state with the filtered results.
   */
  const handleSearchTerm = () => getData(text, selectedCountry ? `country.country_code:${selectedCountry}` : null);

  /**
   * The handleKeyDown function fetch the data when the user uses the Enter button in the search field.
   */
  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      return getData(text, selectedCountry ? `country.country_code:${selectedCountry}` : null);
    }
    return null;
  };

  /**
   * The function `handleDeleteText` clears the text and then retrieves data.
   */
  const handleDeleteText = () => {
    setText('');
    setData([]);
    setCurrentData([]);
    setSelectedCountry(null);
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
                      i18nKey="rorIdExplanation"
                      components={[<a href="https://ror.org/" target="_blank" rel="noopener noreferrer" style={{ textDecoration: 'underline' }}>ROR</a>]}
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
                      onChange={(e) => setText(e.target.value)}
                      onKeyDown={(e) => handleKeyDown(e)}
                      placeholder={t('searchOrg')}
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
                        className="btn btn-default"
                        type="button"
                        onClick={handleDeleteText}
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
          {data.length > 0 && countries.length > 1 && (
            <div className="row" style={{ margin: '10px' }}>
              <div className="">
                <div className="row">
                  <div>
                    <Select
                      menuPortalTarget={document.body}
                      isClearable
                      isSearchable
                      styles={{
                        menuPortal: (base) => ({ ...base, zIndex: 9999 }),
                        singleValue: (base) => ({ ...base, color: 'var(--dark-blue)' }),
                        control: (base) => ({
                          ...base, borderRadius: '8px', borderWidth: '1px', borderColor: 'var(--dark-blue)', height: '43px',
                        }),
                      }}
                      value={ countries.find((c) => c.value === selectedCountry) || null }
                      onChange={handleChangeCountry}
                      placeholder={t('selectCountry')}
                      options={countries}
                    />
                  </div>
                </div>
              </div>
            </div>
          )}

          <table className="table table-bordered table-hover">
            <thead className="thead-dark">
              <tr>
                <th scope="col"></th>
                <th scope="col">{t('orgName')}</th>
                <th scope="col">{t('acronym')}</th>
                <th scope="col">{t('country')}</th>
                <th scope="col">{t('location')}</th>
              </tr>
            </thead>
            <tbody>
              {currentData.length > 0 ? currentData.map((el, idx) => (
                <tr key={idx}>
                  <td>
                    {selectedOrg === el.ror
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
                  <td>
                    {el?.name?.[localeCode] || el?.name?.[Object.keys(el.name).at(0)]}&nbsp;
                    <a href={el.links[0]} target="_blank" rel="noopener noreferrer">
                      <FaLink></FaLink>
                    </a>
                  </td>
                  <td>{el.acronyms}</td>
                  <td>{el.country.code}</td>
                  <td>
                    {el.addresses?.at(0)?.city}
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

          {data.length > 0 && (
            <div className="row text-center">
              <div className="mx-auto"></div>
              <div className="mx-auto">
                <Pagination items={filteredData} onChangePage={onChangePage} pageSize={pageSize} />
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}

export default RorList;
