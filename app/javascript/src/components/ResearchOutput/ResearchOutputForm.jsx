import React from 'react';
import { Tab, Tabs } from 'react-bootstrap';
import { useTranslation } from 'react-i18next';

import AddResearchOutput from './AddResearchOutput';
import ImportResearchOutput from './ImportResearchOutput';
import * as styles from '../assets/css/modal.module.css';

/* This is a functional component in JavaScript React that renders a modal window with two tabs: "Créer" and "Importer". The component takes in three
props: `planId`, `handleClose`, and `show`. The `useTranslation` hook is used to translate the text displayed in the modal. The `Tabs` component from
`react-bootstrap` is used to create the two tabs, and the `AddResearchOutput` and `ImportResearchOutput` components are rendered within each tab. The
`planId`, `handleClose`, and `show` props are passed down to these child components. */
function ResearchOutputForm({ planId, handleClose, edit = false }) {
  const { t } = useTranslation();

  return (
    <div className="dmpopidor-branding">
      {edit ? (
        <AddResearchOutput planId={planId} handleClose={handleClose} inEdition={edit} />
      ) : (
        <Tabs className={`mb-3 ${styles.modal_tabs}`} defaultActiveKey={'create'} id="create-edit-research-output-tabs" fill>
          <Tab eventKey={'create'} title={t('create')} tabClassName={styles.modal_tab} style={{ flex: 1, width: '800px' }}>
            <AddResearchOutput planId={planId} handleClose={handleClose} inEdition={edit} />
          </Tab>
          <Tab eventKey="import" title={t('import')} tabClassName={styles.modal_tab} style={{ flex: 1, width: '800px' }}>
            <ImportResearchOutput planId={planId} handleClose={handleClose} />
          </Tab>
        </Tabs>
      )}
    </div>
  );
}

export default ResearchOutputForm;
