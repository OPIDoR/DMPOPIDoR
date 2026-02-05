import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'react-i18next';
import DOMPurify from 'dompurify';
import { Alert } from 'react-bootstrap';

import { directus } from '../../services';
import { CustomError, CustomSpinner } from '../Shared';

const languagesCode = {
  fr_FR: 'fr',
  en_GB: 'en',
};

export default function StaticPage({ locale, page, directusUrl }) {
  const { t } = useTranslation();

  const { isLoading, error, data } = useQuery({
    queryKey: ['staticPage'],
    queryFn: () => directus.getStaticPage(directusUrl, page).then((res) => res),
  });

  if (isLoading) return <CustomSpinner />;

  if (error) return <CustomError error={error} />;

  if (data?.static_pages.length === 0) {
    return (<Alert variant="warning">{t('noStaticPageFound')}</Alert>);
  }

  const reduceTranslations = (translations, field) => translations
    .reduce(
      (o, translation) => ({ ...o, [languagesCode[translation?.languages_code?.code.replace('-', '_') || 'fr_FR']]: translation[field] }),
      {},
    );

  const pageContent = data?.static_pages.map(({ translations: pageTranslation, ...category }) => ({
    ...category,
    title: reduceTranslations(pageTranslation, 'title'),
    content: reduceTranslations(pageTranslation, 'content'),
  })).at(0);

  return (
    <>
      <h1>{pageContent.title[languagesCode[locale]]}</h1>
      <div dangerouslySetInnerHTML={{
        __html: DOMPurify.sanitize(pageContent.content[languagesCode[locale]]),
      }} />
    </>
  );
}
