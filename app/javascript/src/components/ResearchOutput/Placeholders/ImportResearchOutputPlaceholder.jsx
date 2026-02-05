import React from 'react';
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import Placeholder from 'react-bootstrap/Placeholder';

function ImportResearchOutputPlaceholder() {
  return (
    <Placeholder as="div" animation="wave" style={{ margin: '25px' }}>
      <Placeholder as={Card} style={{ margin: '10px', height: '50px', width: '100%' }} />
      <div style={{ display: 'flex', justifyContent: 'end' }}>
        <Placeholder as={Button} style={{ margin: '10px', width: '75px' }}/>
        <Placeholder as={Button} style={{ margin: '10px', width: '75px' }}/>
      </div>
    </Placeholder>
  );
}

export default ImportResearchOutputPlaceholder;
