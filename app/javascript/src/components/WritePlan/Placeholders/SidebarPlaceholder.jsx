import React from 'react';
import Card from 'react-bootstrap/Card';
import Placeholder from 'react-bootstrap/Placeholder';

function SidebarPlaceholder() {
  const roPlaceholders = [];

  [...Array(4).keys()].forEach((i) => {
    roPlaceholders.push(
      <Placeholder key={i} as={Card} animation="wave" style={{ border: 'none', margin: '10px', height: '50px' }}>
        <Placeholder xs={12} style={{ height: '100%' }} />
      </Placeholder>,
    );
  });

  return (
    <div className="col-2" style={{ padding: '10px' }}>
      {roPlaceholders}
    </div>
  );
}

export default SidebarPlaceholder;
