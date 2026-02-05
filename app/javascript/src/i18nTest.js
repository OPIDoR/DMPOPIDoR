import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

const Languages = ['en', 'fr'];

i18n
  .use(initReactI18next) // pass the i18n instance to react-i18next.
  .init({
    load: 'languageOnly',
    fallbackLng: 'en',
    debug: true,
    whitelist: Languages,
    interpolation: {
      escapeValue: false, // not needed for react as it escapes by default
    },
  });

export default i18n;
