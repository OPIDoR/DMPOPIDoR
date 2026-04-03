import React from 'react';
import { Tooltip as ReactTooltip } from 'react-tooltip';

import * as guidanceChoiceStyles from '../assets/css/guidance_choice.module.css';

function GuidanceGroupItem({
  guidance_group_id,
  guidance_group_name,
  guidance_group_description,
  level = 1,
  isLimitReached,
  status = 'saved',
  onSelect,
}) {
  return (
    <React.Fragment key={`guidance-fragment-${guidance_group_id}`}>
      <div key={`guidance-group-${guidance_group_id}-parent`}>
        <div
          style={{ display: 'flex', alignItems: 'center', paddingBottom: '5px' }}
          key={`guidance-group-${guidance_group_id}-section`}
          id={`guidance-group-${guidance_group_id}-section`}
        >

          {guidance_group_description && <ReactTooltip
            id={`guidance-group-${guidance_group_id}-tooltip`}
            key={`guidance-group-${guidance_group_id}-tooltip`}
            style={{ width: '100%', backgroundColor: '#d4e5ee' }}
            place="bottom"
            effect="solid"
            variant="light"
          >
            <div dangerouslySetInnerHTML={{ __html: guidance_group_description }}></div>
          </ReactTooltip>}
          <label
            data-tooltip-id={`guidance-group-${guidance_group_id}-tooltip`}
            className={`form-check-label ${level === 1 ? guidanceChoiceStyles.label : guidanceChoiceStyles.guidance_group_title} ${status === 'new' ? guidanceChoiceStyles.new_guidance : ''}`}
            style={{ cursor: isLimitReached ? 'not-allowed' : 'pointer' }}
            onClick={() => (isLimitReached ? null : onSelect(guidance_group_id))}
          >
            {guidance_group_name}
          </label>
        </div>
      </div>
    </React.Fragment>
  );
}

export default GuidanceGroupItem;
