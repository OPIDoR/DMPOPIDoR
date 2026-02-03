import React from 'react';

const titleStyle = {
  color: 'var(--white)',
  fontSize: '20px',
  fontFamily: '"Helvetica Neue", sans-serif',
};

function InnerModalTitle({
  className,
  style,
  children,
}) {
  return (
    <div
      style={{ ...titleStyle, ...style }}
      className={className}
    >
      {children}
    </div>
  );
}

export default InnerModalTitle;
