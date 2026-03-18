import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { OrcidList, RorList, Metadore } from '.';

function ImportExternal({
  fragment, setFragment, externalImports = {}, locale,
}) {
  const { t } = useTranslation();

  const [importsState, setImportsState] = useState(
    Object.keys(externalImports)
      .reduce((acc, key) => {
        acc[key] = false;
        return acc;
      }, {}),
  );

  const toggleImport = (type) => setImportsState((prevState) => Object.keys(prevState).reduce((updatedState, key) => {
    updatedState[key] = key === type ? !prevState[key] : false;
    return updatedState;
  }, {}));

  const buttonColor = (buttonActive) => (buttonActive ? 'var(--green)' : 'var(--dark-blue)');

  const externalImportComponent = (type, fragment, setFragment) => {
    const importComponents = {
      ror: (fragment, setFragment, mapping) => <RorList key={`${type}-import-component`} fragment={fragment} setFragment={setFragment} mapping={mapping} locale={locale} />,
      orcid: (fragment, setFragment, mapping) => <OrcidList key={`${type}-import-component`} fragment={fragment} setFragment={setFragment} mapping={mapping} />,
      metadore: (fragment, setFragment, mapping) => <Metadore key={`${type}-import-component`} fragment={fragment} setFragment={setFragment} mapping={mapping} />,
    };

    return (
      <div key={`${type}-import`}>
        {importsState[type] && (
          <div key={`${type}-import-container`}>
            {importComponents[type](fragment, setFragment, externalImports[type])}
            <div key={`${type}-import-spacer`} style={{ display: 'flex', justifyContent: 'center' }}></div>
          </div>
        )}
      </div>
    );
  };

  const externalImportButton = (type) => {
    const buttons = {
      ror: t('retrieveRor'),
      orcid: t('retrieveOrcid'),
      metadore: t('retrieveDataRelatedToDoi'),
    };

    return (
      <button
        key={`${type}-button`}
        data-tooltip-id={type}
        type="button"
        className="btn btn-dark"
        style={{ marginRight: '40px', color: 'white', backgroundColor: buttonColor(importsState[type]) }}
        onClick={() => toggleImport(type)}
      >
        {buttons[type]}
      </button>
    );
  };

  const externalImportsKeys = Object.keys(externalImports);

  return (
    <div style={{ margin: '0 15px' }}>
      <div style={{ marginBottom: '25px' }}>
        {externalImportsKeys.map((key) => externalImportButton(key))}
      </div>

      {externalImportsKeys.map((key) => externalImportComponent(key, fragment, setFragment, externalImports[key]))}
    </div>
  );
}

export default ImportExternal;
