import React, { useRef, useContext, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { GlobalContext } from '../context/Global';
import InnerModal from '../Shared/InnerModal/InnerModal';
import CommentList from '../Shared/CommentList';

function CommentModal({
  shown, hide, setAnswer, answerId, researchOutputId, planId, questionId, commentable,
}) {
  const { t } = useTranslation();
  const [commentsNumber, setCommentsNumber] = useState(0);
  const modalRef = useRef(null);
  const { userId } = useContext(GlobalContext);

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
        <InnerModal.Title id={`#notes-title-${questionId}-research-output-${researchOutputId}`}>
          {t('comments')} ({commentsNumber})
        </InnerModal.Title>
      </InnerModal.Header>
      <InnerModal.Body style={{ borderRadius: '0 0 10px 10px' }}>
        <CommentList
          answerId={answerId}
          researchOutputId={researchOutputId}
          planId={planId}
          questionId={questionId}
          userId={userId}
          commentable={commentable}
          inModal={true}
          setAnswer={setAnswer}
          setCommentsNumber={setCommentsNumber}
        />
      </InnerModal.Body>
    </InnerModal>
  );
}

export default CommentModal;
