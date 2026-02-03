import React from 'react';

const footerStyle = {
  color: 'var(--dark-blue)',
  display: 'flex',
  justifyContent: 'space-between',
  padding: '10px',
  boxSizing: 'border-box',
  verticalAlign: 'middle',
  borderRadius: '0 0 10px 10px',
  alignItems: 'center',
  backgroundColor: 'var(--white)',
};

function InnerModalFooter({
  className,
  style,
  children,
}) {
  return (
    <div
      style={{ ...footerStyle, ...style }}
      className={className}
    >
      {children}
    </div>
  );
}

export default InnerModalFooter;
