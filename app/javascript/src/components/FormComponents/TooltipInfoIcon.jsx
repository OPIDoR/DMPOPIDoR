import React from 'react';

import { FaInfoCircle } from 'react-icons/fa';
import uniqueId from 'lodash.uniqueid';

function Tooltip() {
  const id = uniqueId('tooltip_info_icon_');

  return <FaInfoCircle
    id={id}
    data-testid={id}
    size={12}
    style={{ marginLeft: '4px', verticalAlign: 'middle', color: 'var(--blue)' }}
  />;
}

export default Tooltip;
