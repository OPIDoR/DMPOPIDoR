import React from 'react';
import Modal from 'react-bootstrap/Modal';
import { useTranslation } from 'react-i18next';
import ResearchOutputForm from './ResearchOutputForm';

/* This is a functional component in JavaScript React that renders a modal window with two tabs: "Créer" and "Importer". The component takes in three
props: `planId`, `handleClose`, and `show`. The `useTranslation` hook is used to translate the text displayed in the modal. The `Tabs` component from
`react-bootstrap` is used to create the two tabs, and the `AddResearchOutput` and `ImportResearchOutput` components are rendered within each tab. The
`planId`, `handleClose`, and `show` props are passed down to these child components. */
function ResearchOutputModal({
  planId, handleClose, show, edit = false,
}) {
  const { t } = useTranslation();

  return (
    <Modal size="xl" show={show} onHide={handleClose}>
      <Modal.Header closeButton>
        <Modal.Title>{t(edit ? 'editResearchOutput' : 'addAResearchOutput')}</Modal.Title>
      </Modal.Header>
      <Modal.Body style={{ padding: '20px !important' }}>
        <ResearchOutputForm planId={planId} handleClose={handleClose} edit={edit}/>
      </Modal.Body>
    </Modal>
  );
}

export default ResearchOutputModal;
