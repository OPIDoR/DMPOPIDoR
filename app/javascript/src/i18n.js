import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import Backend from 'i18next-http-backend';
import LanguageDetector from 'i18next-browser-languagedetector';

i18n
  .use(Backend)
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    load: 'languageOnly',
    fallbackLng: 'en',
    debug: false,
    whitelist: ['en', 'fr'],
    backend: {
      loadPath: '/locales/{{lng}}.json',
      requestOptions: {
        cache: 'no-store',
      },
    },
    interpolation: {
      escapeValue: false,
    },
  });

export default i18n;
