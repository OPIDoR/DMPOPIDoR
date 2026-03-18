import React, { useContext, useEffect, useState } from 'react';
import DOMPurify from 'dompurify';
import { useTranslation } from 'react-i18next';

import { GlobalContext } from '../context/Global';
import * as styles from '../assets/css/write_plan.module.css';
import Question from './Question';

function Section({ planId, section, readonly }) {
  const { t } = useTranslation();
  const { openedQuestions, setOpenedQuestions, displayedResearchOutput } = useContext(GlobalContext);
  const [sectionId, setSectionId] = useState(section.id);

  useEffect(() => {
    setSectionId(section.id);
  }, [section]);

  /**
 * Toggle the state of questions within a section to the provided boolean value.
 *
 * @param {boolean} boolVal - The boolean value to set for all questions in the section.
 */
  const toggleQuestionsInSection = (boolVal) => {
    const updatedState = {
      ...openedQuestions[displayedResearchOutput.id],
      [sectionId]: section.questions.reduce((acc, question) => {
        acc[question.id] = boolVal;
        return acc;
      }, {}),
    };

    setOpenedQuestions({
      ...openedQuestions,
      [displayedResearchOutput.id]: updatedState,
    });
  };

  return (
    <>
      <p className={styles.title}>
        {section.number}. {section.title}
      </p>
      <div
        dangerouslySetInnerHTML={{
          __html: DOMPurify.sanitize([section.description]),
        }}
      />
      <div className="column">
        <div className={styles.collapse_title}>
          <button
            type="button"
            className={`btn btn-link btn-sm m-0 p-0 ${styles.sub_title}`}
            style={{
              outline: 'none', fontSize: '14px', padding: 0, color: '#1c5170',
            }}
            onClick={(e) => {
              e.preventDefault();
              e.stopPropagation();
              toggleQuestionsInSection(true);
            }}
          >
            {t('expandAll')}
          </button>
          <span className={styles.sub_title}> | </span>
          <button
            type="button"
            className={`btn btn-link btn-sm m-0 p-0 ${styles.sub_title}`}
            style={{
              outline: 'none', fontSize: '14px', padding: 0, color: '#1c5170',
            }}
            onClick={(e) => {
              e.preventDefault();
              e.stopPropagation();
              toggleQuestionsInSection(false);
            }}
          >
            {t('collapseAll')}
          </button>
        </div>
      </div>
      {section.questions.filter((question) => {
        if (question?.madmp_schema?.classname === 'personal_data_issues') {
          return displayedResearchOutput.configuration.hasPersonalData;
        }
        return true;
      }).map((question, idx) => (
        <Question
          key={question.id}
          planId={planId}
          question={question}
          questionIdx={(idx + 1)}
          sectionId={sectionId}
          sectionNumber={section.number}
          readonly={readonly}
        />
      ))}
    </>
  );
}

export default Section;
