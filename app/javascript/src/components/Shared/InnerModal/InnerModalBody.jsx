import React from 'react';

const bodyStyle = {
  color: 'var(--dark-blue)',
  padding: '10px',
  marginTop: '4px',
  width: '100%',
  marginRight: '20px',
  boxSizing: 'border-box',
  alignItems: 'center',
  backgroundColor: 'var(--white)',
};

function InnerModalBody({
  className,
  style,
  children,
}) {
  return (
    <div
      style={{ ...bodyStyle, ...style }}
      className={className}
    >
      {children}
    </div>
  );
}

export default InnerModalBody;
