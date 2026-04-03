import React from 'react';
import Select, { components } from 'react-select';
import AsyncSelect from 'react-select/async';
import AsyncCreatableSelect from 'react-select/async-creatable';
import CreatableSelect from 'react-select/creatable';
import { useTranslation } from 'react-i18next';
import { filterOptions } from '../../utils/GeneratorUtils';

function CustomSelect({
  inputId = null,
  propName = null,
  options,
  selectedOption = null,
  onSelectChange,
  async = false,
  isDisabled = false,
  isClearable = false,
  isSearchable = true,
  placeholder = null,
  overridable = false,
}) {
  const { t } = useTranslation();
  const SelectComponent = getSelectComponent();
  const { Option } = components;

  function getSelectComponent() {
    if (async) {
      return overridable ? AsyncCreatableSelect : AsyncSelect;
    }
    return overridable ? CreatableSelect : Select;
  }

  const CustomOption = (props) => (
    <Option {...props}>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center' }}>
          {props?.data?.prependIcon}
          {props?.data?.label}
        </div>
        {props?.data?.appendIcon}
      </div>
    </Option>
  );

  return (
    <SelectComponent
      inputId={inputId}
      data-testid={`select-component-${propName}`}
      menuPortalTarget={document.body}
      styles={{
        menuPortal: (base) => ({ ...base, zIndex: 9999, color: 'var(--dark-blue)' }),
        singleValue: (base) => ({ ...base, color: 'var(--dark-blue)' }),
        control: (base) => ({
          ...base, borderRadius: '8px', borderWidth: '1px', borderColor: 'var(--dark-blue)', marginRight: '2px',
        }),
      }}
      name={propName}
      components={{ Option: CustomOption }}
      options={options}
      onChange={onSelectChange}
      value={selectedOption}
      placeholder={placeholder}
      loadOptions={async ? (value) => filterOptions(options, value) : undefined}
      defaultOptions={async ? options.slice(0, 100) : undefined}
      cacheOptions
      isDisabled={isDisabled}
      isClearable={isClearable}
      isSearchable={isSearchable}
      noOptionsMessage={() => t('noResultsFound')}
    />
  );
}

export default CustomSelect;
