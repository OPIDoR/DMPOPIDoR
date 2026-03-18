import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { format } from 'date-fns';
import { fr, enGB } from 'date-fns/locale';
import { useTranslation } from 'react-i18next';

import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import Col from 'react-bootstrap/Col';
import Row from 'react-bootstrap/Row';

import CustomSpinner from '../Shared/CustomSpinner.jsx';
import CustomError from '../Shared/CustomError.jsx';
import { news } from '../../services/index.js';

const locales = {
  'fr-FR': fr,
  'en-GB': enGB,
};

export default function NewsPage({ locale, size }) {
  const { t, i18n } = useTranslation();

  const { isLoading, error, data } = useQuery({
    queryKey: ['news'],
    queryFn: () => news.get(size).then((res) => res.data),
  });

  if (isLoading) return <CustomSpinner />;

  if (error) return <CustomError error={error} />;

  return (
    <Row xs={1} md={3} className="g-4">
      {data.map((r) => ({
        id: r.id,
        title: r.title.rendered,
        content: r.content.rendered,
        link: r.link,
        date: format(new Date(r.date), 'dd/MM/yyyy', { locale: locales[i18n.resolvedLanguage || locale] }),
        full: r?._embedded?.['wp:featuredmedia']?.[0]?.media_details?.sizes?.full,
      })).map((n, idx) => (
        <Col key={idx}>
          <Card
            style={{
              padding: '5px', margin: '0 15px', borderColor: '#ddd', height: '100%',
            }}
            key={`thumbnail-${n.id}`}>
            <Card.Img variant="top" src={n.full.source_url} />
            <Card.Body>
              <Card.Title as="h2">
                <Card.Link style={{ backgroundColor: 'white', textDecoration: 'none' }} key={`link-${n.id}`} href={n.link}>{n.title}</Card.Link>
              </Card.Title>
              <Card.Text
                style={{
                  marginBottom: '50px',
                }}
                dangerouslySetInnerHTML={{ __html: `${n.content.substring(0, 120)}...` }}
                key={`content-${n.id}`} />
            </Card.Body>
            <Card.Footer className="text-muted" style={{ border: 'none', backgroundColor: 'white' }}>
              <Button
                href={n.link}
                variant="primary"
                key={`read-button-${n.id}`}
                className="float-end"
              >{t('readArticle')}</Button>
            </Card.Footer>
          </Card>
        </Col>
      ))}
    </Row>
  );
}
