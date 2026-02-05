import React from 'react';
import { useTranslation, Trans } from 'react-i18next';
import { fr, enGB } from 'date-fns/locale';
import { format } from 'date-fns';
import { FaRegCompass } from 'react-icons/fa6';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import { useTour } from '../Shared/Driver/DriverContext';

const locales = { fr, en: enGB };

function PlanInformations({ template }) {
  const { t, i18n } = useTranslation();

  const { setIsOpen } = useTour();

  return (template && (
    <div style={{
      textAlign: 'center',
      color: 'grey',
      fontSize: '16px',
      margin: '20px 0 20px 0',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    }}>
      <div id="guided-tour-compass">
        <ReactTooltip
          id="guided-tour"
          place="bottom"
          effect="solid"
          variant="info"
          content={t('runGuidedTour')}
        />
        <FaRegCompass
          data-tooltip-id="guided-tour"
          size="32"
          onClick={() => setIsOpen(true)}
          style={{
            cursor: 'pointer',
            marginRight: '10px',
            color: 'var(--dark-blue)',
          }}
        />
      </div>
      <div style={{
        marginTop: '5px',
      }}>
        <Trans
          t={t}
          i18nKey="thisPlanIsBasedOnModelProvidedBy"
          values={{
            model: template.title,
            orgName: template.org,
            version: template.version,
            publishedDate: format(new Date(template.publishedDate), 'dd LLLL yyyy', { locale: locales[template.locale || i18n.resolvedLanguage] }),
          }}
          components={[<strong>{template.title}</strong>, <strong>{template.org}</strong>]}
        />
      </div>
    </div>
  )
  );
}

export default PlanInformations;
