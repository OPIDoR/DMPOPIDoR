import React from 'react';
import {
  cleanup, fireEvent, render, screen, waitFor,
} from '@testing-library/react';

import InputText from '../../../components/FormComponents/InputText';
import { Wrapper } from '../../__utils__/reactHookFormHelpers';

jest.mock('react-i18next', () => ({
  // this mock makes sure any components using the translate hook can use it without a warning being shown
  useTranslation: () => ({
    t: (str) => str,
    i18n: {
      changeLanguage: () => new Promise(() => { }),
    },
  }),
  initReactI18next: {
    type: '3rdParty',
    init: () => { },
  },
}));

const inputTextProps = {
  label: 'Input Text Label',
  type: 'text',
  propName: 'myInput',
  tooltip: 'my tooltip',
  placeholder: 'my placeholder',
};

afterEach(cleanup);

describe('InputText component', () => {
  test('component rendering', async () => {
    render(
      <Wrapper propName={inputTextProps.propName}>
        <InputText {...inputTextProps} />
      </Wrapper>,
    );
    expect(screen.getByTestId('input-text-label')).toHaveTextContent(inputTextProps.label);
    expect(screen.getByTestId('input-text')).toBeInTheDocument();
    expect(screen.getByTestId('input-text')).toHaveAttribute('type', 'text');
    expect(screen.getByPlaceholderText(`e.g. ${inputTextProps.placeholder}`)).toBeInTheDocument();
    expect(screen.getByTestId(/tooltip_info_icon_[0-9]+/i)).toBeInTheDocument();
  });

  test('component rendering with value', async () => {
    render(
      <Wrapper propName={inputTextProps.propName} data="myText">
        <InputText {...inputTextProps} />
      </Wrapper>,
    );
    expect(screen.getByTestId('input-text')).toBeInTheDocument();
    expect(screen.getByTestId('input-text').value).toBe('myText');
  });

  test('tooltip is showing when hovering label', async () => {
    render(
      <Wrapper propName={inputTextProps.propName}>
        <InputText {...inputTextProps} />
      </Wrapper>,
    );
    const label = screen.getByTestId('input-text-label');
    expect(screen.queryByText(inputTextProps.tooltip)).not.toBeInTheDocument();
    fireEvent.mouseOver(label);
    await waitFor(() => screen.getByRole('tooltip'));
    const tooltip = screen.getByRole('tooltip');
    expect(tooltip).toBeInTheDocument();
    expect(tooltip).toHaveTextContent(inputTextProps.tooltip);
    expect(label.getAttribute('data-tooltip-id')).toBe(tooltip.getAttribute('id'));
  });

  test('component rendering as readonly', async () => {
    const inputTextReadonlyProps = { ...inputTextProps, readonly: true };
    render(
      <Wrapper propName={inputTextProps.propName}>
        <InputText {...inputTextReadonlyProps} />
      </Wrapper>,
    );
    expect(screen.getByTestId('input-text')).toHaveAttribute('readonly');
  });

  test('component with type=date rendering <input type="date"/>', async () => {
    const inputTextDateProps = { ...inputTextProps, type: 'date' };
    render(
      <Wrapper propName={inputTextProps.propName}>
        <InputText {...inputTextDateProps} />
      </Wrapper>,
    );
    expect(screen.getByTestId('input-text')).toHaveAttribute('type', 'date');
  });

  test('component with type=number rendering <input type="number"/>', async () => {
    const inputTextNumberProps = { ...inputTextProps, type: 'number', min: 42 };
    render(
      <Wrapper propName={inputTextProps.propName}>
        <InputText {...inputTextNumberProps} />
      </Wrapper>,
    );
    const input = screen.getByTestId('input-text');
    expect(input).toHaveAttribute('type', 'number');
    expect(input).toHaveAttribute('min', inputTextNumberProps.min.toString());
  });

  test('component with hidden rendering <input type="hidden"/>', async () => {
    const inputTextHiddenProps = { ...inputTextProps, hidden: true };
    render(
      <Wrapper propName={inputTextProps.propName}>
        <InputText {...inputTextHiddenProps} />
      </Wrapper>,
    );
    expect(screen.queryByText(inputTextProps.label)).not.toBeInTheDocument();
    expect(screen.getByTestId('input-text')).toHaveAttribute('type', 'hidden');
  });
});
