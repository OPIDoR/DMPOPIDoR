import React, { useEffect, useState } from 'react';
import { Trans, useTranslation } from 'react-i18next';
import set from 'lodash.set';
import { FaCheckCircle, FaPlusSquare } from 'react-icons/fa';
import Select from 'react-select';

import { externalServices, service } from '../../services';
import CustomSpinner from '../Shared/CustomSpinner';
import CustomError from '../Shared/CustomError';
import Pagination from '../Shared/Pagination';
import { flattenObject, normalize } from '../../utils/utils';

const locales = {
  en: 'en_GB',
  fr: 'fr_FR',
};

function Metadore({ fragment, setFragment, mapping = {} }) {
  const { t, i18n } = useTranslation();
  const pageSize = 8;
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [selectedData, setSelectedData] = useState(null);
  const [currentData, setCurrentData] = useState([]);
  const [text, setText] = useState('');
  const [registry, setRegistry] = useState(null);
  const [researchDataTypes, setResearchDataTypes] = useState(null);
  const [researchDataType, setResearchDataType] = useState(null);

  useEffect(() => {
    service.getRegistryByName('DataLicenses').then(({ data }) => setRegistry(data));
    service.getRegistryByName('ResearchDataType').then(({ data }) => setResearchDataTypes(data.map((type) => ({
      value: type.en_GB,
      label: type[locales[i18n.language] || locales.fr],
    }))));
  }, []);

  /**
   * The function `getData` makes an API call to get data, sets the retrieved data in state variables, and creates an array of distinct countries from the
   * data.
   */
  const getData = async (query, type = null) => {
    setLoading(true);
    setData([]);

    let response;
    try {
      response = await externalServices.getMetadore(query, type);
    } catch (error) {
      setError(error);
      return setLoading(false);
    }

    const { data: resData } = response.data;

    setData(resData);

    if (resData.length === 0) { setCurrentData([]); }

    return setLoading(false);
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
  const setSelectedValue = async (el) => {
    const selectedDataById = selectedData === el?.attributes?.doi ? null : el?.attributes?.doi;
    setSelectedData(selectedDataById);

    const obj = {
      title: el?.attributes?.titles?.at(0)?.title,
      description: el?.attributes?.descriptions?.at(0)?.description,
      versionNumber: el?.attributes?.version,
      license: {
        licenseName: el?.attributes?.rightsList?.at(0)?.rights,
        licenseUrl: el?.attributes?.rightsList?.at(0)?.rightsUri,
      },
      idType: 'DOI',
      datasetId: el?.attributes?.doi,
    };
    const matchData = data?.find(({ attributes }) => normalize(attributes?.doi) === normalize(el?.attributes?.doi));

    if (matchData) {
      const flattenedMapping = flattenObject(mapping);

      for (const [key, value] of Object.entries(flattenedMapping)) {
        set(obj, key, matchData?.[value] || '');
      }
    }

    if (obj?.datasetId) {
      set(obj, 'datasetId', `https://doi.org/${el?.attributes?.doi}`);
    }

    if (obj?.license?.licenseName) {
      if (registry) {
        const res = registry?.find(({ licenseName }) => normalize(licenseName) === normalize(obj?.license?.licenseName));
        if (res) {
          const { licenseName, licenseUrl } = res;
          set(obj, 'license', {
            ...fragment?.license,
            licenseName,
            licenseUrl,
            action: fragment?.license?.id ? 'update' : 'create',
          });
        }
      }
    }

    if (!obj?.license?.licenseName && !obj?.license?.licenseUrl) {
      set(obj, 'license', fragment?.license?.id ? { id: fragment?.license?.id, action: 'delete' } : null);
    }

    setFragment({ ...fragment, ...obj });
  };

  /**
   * The handleSearchTerm function filters data based on a text input value and updates the state with the filtered results.
   */
  const handleSearchTerm = () => getData(text, researchDataType);

  const handleTypeFilter = (el) => {
    setResearchDataType(el?.value);
    return getData(text, el?.value);
  };

  /**
   * The handleKeyDown function fetch the data when the user uses the Enter button in the search field.
   */
  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      return getData(text);
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
                      i18nKey="dataCiteExplanation"
                      components={[<a href="https://datacite.org/" target="_blank" rel="noopener noreferrer" style={{ textDecoration: 'underline' }}>DataCite</a>]}
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
                      placeholder={t('enterTitleOrDoi')}
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
                    onChange={handleTypeFilter}
                    placeholder={t('typeSelection')}
                    options={researchDataTypes}
                    isDisabled={text.length === 0 || !text}
                  />
                </div>
              </div>
            </div>
          </div>

          <table className="table table-bordered table-hover">
            <thead className="thead-dark">
              <tr>
                <th scope="col"></th>
                <th scope="col">{t('DOI')}</th>
                <th scope="col">{t('title')}</th>
                <th scope="col">{t('publicationDate')}</th>
                <th scope="col">{t('type')}</th>
              </tr>
            </thead>
            <tbody>
              {currentData.length > 0 ? currentData.map((el, idx) => (
                <tr key={idx}>
                  <td>
                    {selectedData === el?.attributes?.doi
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
                  <td>{el.attributes.doi}</td>
                  <td>{el.attributes.titles.at(0).title}</td>
                  <td>{el.attributes.publicationYear}</td>
                  <td>{el.attributes.types.resourceTypeGeneral || '-'}</td>
                </tr>
              )) : (
                <tr>
                  <td colSpan="5" style={{ textAlign: loading ? 'center' : 'left' }}>
                    {loading ? <CustomSpinner /> : t('noData')}
                  </td>
                </tr>
              )}
            </tbody>
          </table>

          {data.length > 0 && (
            <div className="row text-center">
              <div className="mx-auto"></div>
              <div className="mx-auto">
                <Pagination items={data} onChangePage={onChangePage} pageSize={pageSize} />
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}

export default Metadore;
