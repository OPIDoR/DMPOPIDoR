import { TbBulbFilled } from 'react-icons/tb';
import { BsGear } from 'react-icons/bs';
import { IoShuffleOutline } from 'react-icons/io5';
import { FaEnvelope, FaWrench } from 'react-icons/fa';
import { renderToStaticMarkup } from 'react-dom/server';

import { CommentSVG } from '../../Styled/svg';

const icons = {
  TbBulbFilled,
  BsGear,
  IoShuffleOutline,
  FaEnvelope,
  FaWrench,
  CommentSVG,
};

const showIcon = (name, size) => {
  const IconComponent = icons[name];
  if (!IconComponent) return '';
  return renderToStaticMarkup(<IconComponent size={size} />);
};

export default (t) => [
  {
    element: '#guided-tour-compass',
    popover: {
      title: t('discoverEditingFeatures'),
      description: t('guidedTourDescription'),
      side: 'left',
      align: 'start',
    },
  },
  {
    element: '#accordion-guidance-choice',
    popover: {
      title: t('selectGuidances'),
      description: `<div style="display: flex; align-items: center; height: 100px;">
          <div style="margin: -20px 10px 0 10px;">${showIcon('TbBulbFilled', 60)}</div>
          <div>
            <p>${t('consultGuidancesList')}</p>
            <p>${t('checkOffRelevantGuidances')}</p>
            <p>${t('seeGuidancesToRightOfQuestion')}</p>
          </div>
        </div>`,
      side: 'top',
      align: 'start',
    },
  },
  {
    element: '#icons-container',
    popover: {
      title: t('viewSuggestedAids'),
      description: `
        <p>
          <div style="display: flex; align-items: center; height: 70px;">
            <div style="margin: -20px 10px 0 10px;">${showIcon('TbBulbFilled', 32)}</div>
            <p>${t('displayGuidancesForQuestion')}</p>
          </div>

          <div style="display: flex; align-items: center; height: 70px;">
            <div style="margin: -10px 10px 0 10px;">${showIcon('CommentSVG', 32)}</div>
            <p>${t('viewCommentsSharedByCollaborators')}</p>
          </div>

          <div style="display: flex; align-items: center; height: 70px;">
            <div style="margin: -20px 10px 0 10px;">${showIcon('IoShuffleOutline', 32)}</div>
            <p>${t('chooseAppropriateFormForDataManagementService')}</p>
          </div>

          <div style="display: flex; align-items: center; height: 70px;">
            <div style="margin: -15px 10px 0 10px;">${showIcon('BsGear', 32)}</div>
            <p>${t('activateToolsProposedForForm')}</p>
          </div>
        </p>
      `,
      side: 'left',
      align: 'start',
    },
  },
  {
    element: '.contact-icons',
    popover: {
      title: t('doYouHaveAQuestion'),
      description: `
        <p>
          <div style="display: flex; align-items: center; height: 70px;">
            <div style="margin: -1px 10px 0 5px;">${showIcon('FaEnvelope', 32)}</div>
            <p>${t('infoDataManagementClickEnvelope')}</p>
          </div>
          <div style="display: flex; align-items: center; height: 70px;">

            <div style="margin: -20px 10px 0 5px;">${showIcon('FaWrench', 32)}</div>
            <p>${t('reportTechnicalErrorClickKey')}</p>
          </div>
        </p>
      `,
      side: 'top',
      align: 'start',
    },
  },
];
