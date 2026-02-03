import DOMPurify from 'dompurify';
import React, { useEffect, useState, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { Tooltip as ReactTooltip } from 'react-tooltip';

import { guidances } from '../../services';
import CustomError from '../Shared/CustomError';
import CustomSpinner from '../Shared/CustomSpinner';
import {
  NavBody, NavBodyText, ScrollNav, Theme, SubTitle,
} from './styles/GuidanceModalStyles';
import InnerModal from '../Shared/InnerModal/InnerModal';

function GuidanceModal({
  shown, hide, questionId, researchOutputId,
}) {
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = useState('Science Europe');
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [indexTab, setIndexTab] = useState(0);
  const modalRef = useRef(null);

  const navStyles = (tab) => ({
    color: activeTab === tab ? 'var(--white)' : 'var(--dark-blue)',
    textDecoration: 'none',
    cursor: 'pointer',
    display: 'flex',
    justifyContent: 'space-around',
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: activeTab === tab ? 'var(--dark-blue)' : 'var(--white)',
    border: activeTab === tab ? '1px solid var(--dark-blue)' : '1px solid var(--white)',
    padding: '10px',
    borderRadius: '10px 10px 0 0',
    fontWeight: 'bold',
    margin: '0 0 1px 0',
    flex: 1,
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap',
  });

  /* A hook that is called when the component is mounted. */
  useEffect(() => {
    if (!questionId) { return; }

    setLoading(true);

    guidances.getGuidances(researchOutputId, questionId)
      .then(({ data }) => {
        const guidancesData = data?.guidances.map((guidance) => {
          const groups = guidance.groups.reduce((acc, group) => {
            const [groupInfo, guidanceInfo] = group;
            const groupName = groupInfo.name;

            const descriptionKey = Object.keys(guidanceInfo).find((key) => key !== 'id');

            acc[groupName] = {
              title: descriptionKey,
              guidances: Array.isArray(guidanceInfo[descriptionKey]) ? guidanceInfo[descriptionKey] : [],
            };

            return acc;
          }, {});

          const title = Object.values(groups)?.at(0)?.title || '';

          return {
            name: guidance.name,
            title,
            groups,
            annotations: guidance.annotations || [],
          };
        });

        setData(guidancesData);
        setActiveTab(guidancesData?.at(0)?.name || '');
      })
      .catch((error) => setError(error))
      .finally(() => setLoading(false));
  }, [researchOutputId, questionId]);

  /**
  * getContent function returns JSX with a scrollable container (<ScrollNav>) containing a body (<NavBody>) and text (<NavBodyText>).
  * Text is based on data and indexTab. If data[indexTab].annotations[0].text exists, it's displayed using dangerouslySetInnerHTML for HTML rendering.
  * Otherwise, the function maps data[indexTab].groups to show each group's theme and guidances using dangerouslySetInnerHTML.
  * Horizontal lines (<hr>) separate each guidance.
  */
  const getContent = () => (
    <NavBody>
      <NavBodyText>
        <ScrollNav>
          {data?.[indexTab]?.annotations?.length > 0 && (
            <>
              {data?.[indexTab]?.annotations?.map((annotation, id) => (
                <div
                  key={`guidance-${indexTab}-annotation-${id}`}
                  dangerouslySetInnerHTML={{
                    __html: DOMPurify.sanitize(annotation.text),
                  }}
                />
              ))}
            </>
          )}
          {data?.filter(({ name }) => name === activeTab).map(({ title, groups }, dId) => (
            <div key={`guidance-${dId}`}>
              <Theme alt={title}>{title}</Theme>
              {Object.keys(groups)?.map((groupName) => (
                <div key={`guidance-div-${dId}`}>
                  <SubTitle key={`guidance-subtitle-${dId}`} style={{ marginBottom: '10px' }}>{groupName}</SubTitle>
                  {groups[groupName].guidances.map((guidance) => (
                    <div
                      key={`guidance-value-${dId}`}
                      dangerouslySetInnerHTML={{
                        __html: DOMPurify.sanitize(guidance.text),
                      }}
                    />
                  ))}
                </div>
              ))}
            </div>
          ))}
        </ScrollNav>
      </NavBodyText>
    </NavBody>
  );

  return (
    <InnerModal show={shown} ref={modalRef}>
      <InnerModal.Header
        closeButton
        expandButton
        ref={modalRef}
        onClose={() => {
          hide();
        }}
      >
        <InnerModal.Title>
          {t('guidance')}
        </InnerModal.Title>
      </InnerModal.Header>
      <InnerModal.Body>
        {loading && <CustomSpinner />}
        {!loading && error && <CustomError error={error} />}
        {!loading && !error && data && (
          <>
            <nav style={{ display: 'flex', width: '100%', padding: '0 10px 0 10px' }} id="guidances-thumbs">
              {data.map((el, idx) => (
                <span
                  key={`guidance-tab-${idx}`}
                  onClick={(e) => {
                    e.stopPropagation();
                    e.preventDefault();
                    setActiveTab(el.name);
                    setIndexTab(idx);
                  }}
                  style={{
                    ...navStyles(el.name),
                    width: `calc(100% / ${data.length})`,
                    borderTop: indexTab === idx ? null : '1px solid var(--dark-blue)',
                    borderLeft: indexTab === idx ? null : '1px solid var(--dark-blue)',
                    borderRight: indexTab === idx ? null : '1px solid var(--dark-blue)',
                  }}
                  alt={el.name}
                >
                  <ReactTooltip
                    key={`guidance-tab-tooltip-${idx}`}
                    id={`guidance-tab-title-${idx}`}
                    place="bottom"
                    effect="solid"
                    variant="info"
                    content={el.name}
                  />
                  <span
                    key={`guidance-tab-title-${idx}`}
                    data-tooltip-id={`guidance-tab-title-${idx}`}
                    alt={el.name}
                  >
                    {el.name.length < 15 ? el.name : `${el.name.substring(0, 15)}...`}
                  </span>
                </span>
              ))}
            </nav>
            <div id="guidances-content">{data && getContent()}</div>
          </>
        )}
      </InnerModal.Body>
    </InnerModal>
  );
}

export default GuidanceModal;
