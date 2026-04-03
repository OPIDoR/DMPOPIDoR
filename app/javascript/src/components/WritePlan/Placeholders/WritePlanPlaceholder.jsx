import React from 'react';
import Card from 'react-bootstrap/Card';
import Placeholder from 'react-bootstrap/Placeholder';

import SidebarPlaceholder from './SidebarPlaceholder';

function WritePlanPlaceholder() {
  const questionsPlaceholders = [];

  [...Array(4).keys()].forEach((i) => {
    questionsPlaceholders.push(
      <Placeholder key={i} as={Card} xs={10} style={{ margin: '10px', height: '50px' }}>
        <Placeholder xs={12} style={{ height: '100%' }} />
      </Placeholder>,
    );
  });

  return (
    <>
      <Placeholder xs={12} as="div" animation="wave" style={{ padding: '10px', textAlign: 'center' }}>
        <Placeholder xs={11} as={Card} style={{ margin: '10px', height: '50px' }} />
      </Placeholder>
      <div style={{ display: 'flex' }}>
        <SidebarPlaceholder />
        <Placeholder xs={10} as="div" animation="wave" style={{ padding: '50px' }}>
          <Placeholder xs={10} as={Card} style={{ margin: '10px', height: '200px' }} />
          {questionsPlaceholders}
        </Placeholder>
      </div>
    </>
  );
}

export default WritePlanPlaceholder;
