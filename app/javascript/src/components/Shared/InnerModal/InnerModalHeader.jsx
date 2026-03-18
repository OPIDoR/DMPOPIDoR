import React, { forwardRef, useState } from 'react';
import { IoClose } from 'react-icons/io5';
import { TbMinimize, TbMaximize } from 'react-icons/tb';

const headerStyle = {
  color: 'var(--white)',
  backgroundColor: 'var(--dark-blue)',
  display: 'flex',
  justifyContent: 'space-between',
  padding: '0 10px',
  boxSizing: 'border-box',
  verticalAlign: 'middle',
  borderRadius: '10px 10px 0 0',
  alignItems: 'center',
};

const InnerModalHeader = forwardRef((props, ref) => {
  const {
    closeButton = false,
    expandButton = false,
    className,
    style,
    children,
    onClose,
  } = props;

  const [isExpanded, setIsExpanded] = useState(false);
  const parentRef = ref?.current || null;

  const expand = (value) => {
    if (!parentRef) { return; }

    if (value) {
      setIsExpanded(true);
      // eslint-disable-next-line react-compiler/react-compiler
      return parentRef.style.width = 'calc(100% - 30px)';
    }

    setIsExpanded(false);
    return parentRef.style.width = '540px';
  };

  return (
    <div
      ref={ref}
      style={{ ...headerStyle, ...style }}
      className={className}
    >
      <div>{children}</div>
      <div id="inner-modal-header-actions">
        {expandButton && isExpanded && (
          <TbMinimize
            id="inner-modal-header-actions-minimize"
            size={24}
            style={{ margin: '0 5px 0 5px', cursor: 'pointer' }}
            onClick={() => expand(false)}
          />
        )}
        {expandButton && !isExpanded && (
          <TbMaximize
            id="inner-modal-header-actions-maximize"
            size={24}
            style={{ margin: '0 5px 0 5px', cursor: 'pointer' }}
            onClick={() => expand(true)}
          />
        )}
        {closeButton && (
          <IoClose
            id="inner-modal-header-actions-close"
            size={24}
            style={{ margin: '0 5px 0 5px', cursor: 'pointer' }}
            onClick={() => onClose()}
          />
        )}
      </div>
    </div>
  );
});

export default InnerModalHeader;
