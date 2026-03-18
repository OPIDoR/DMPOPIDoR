import React, { forwardRef } from 'react';

import InnerModalHeader from './InnerModalHeader';
import InnerModalTitle from './InnerModalTitle';
import InnerModalBody from './InnerModalBody';
import InnerModalFooter from './InnerModalFooter';
import InnerModalSpacer from './InnerModalSpacer';

const InnerModal = forwardRef((props, ref) => {
  const {
    className,
    style,
    children,
    ariaLabelledby,
    ariaDescribedby,
    ariaLabel,
    show = false,
  } = props;

  const modalStyles = {
    display: show ? 'block' : 'none',
    position: 'absolute',
    zIndex: 15,
    background: 'var(--white)',
    borderRadius: '10px',
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
    color: 'var(--white)',
    width: '540px', // 'calc(100% - 30px)'
    top: 15,
    right: '15px',
    border: '1px solid var(--dark-blue)',
    paddingBottom: '10px',
  };

  return (
    <div
      ref={ref}
      style={{ ...modalStyles, ...style }}
      className={className}
      aria-label={ariaLabel}
      aria-labelledby={ariaLabelledby}
      aria-describedby={ariaDescribedby}
    >
      {children}
    </div>
  );
});

export default Object.assign(InnerModal, {
  Header: InnerModalHeader,
  Title: InnerModalTitle,
  Body: InnerModalBody,
  Footer: InnerModalFooter,
  Spacer: InnerModalSpacer,
});
