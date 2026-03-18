import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import styled from 'styled-components';
import { MdOutlineCookie } from 'react-icons/md';
import * as cookieConsent from 'vanilla-cookieconsent';
import 'vanilla-cookieconsent/dist/cookieconsent.css';

import config from './config';

const CookieButton = styled.div`
  position: fixed;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  border: 1px solid var(--white);
  left: 3rem;
  bottom: 3rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--white);
  background-color: var(--dark-blue);
  transform: scale(1);
  transition: all 0.3s ease;

  &:hover {
    transform: scale(1.1);
  }
`;

const CookieConsent = () => {
  const { t, i18n } = useTranslation();

  useEffect(() => {
    cookieConsent.setLanguage(i18n.resolvedLanguage || 'fr');
    cookieConsent.run(config);
  }, []);

  const resetCookieConsent = () => {
    cookieConsent.show(true);
    cookieConsent.run(config);
  };

  return (
    <>
      <ReactTooltip
        id="cookie-settings-button"
        place="right"
        effect="solid"
        variant="info"
        content={t('cookiePreferences')}
      />
      <CookieButton
        data-tooltip-id="cookie-settings-button"
        onClick={resetCookieConsent}
      >
        <MdOutlineCookie size={28} />
      </CookieButton>
    </>
  );
};

export default CookieConsent;
