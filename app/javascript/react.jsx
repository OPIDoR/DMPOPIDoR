import React from 'react';
import ReactDOM from 'react-dom/client';

import NewsPageLayout from './dmp_opidor_react/src/components/news/NewsPageLayout.jsx';
import CommentList from './dmp_opidor_react/src/components/Shared/CommentList.jsx';
import ContributorsTabLayout from './dmp_opidor_react/src/components/ContributorsTab/ContributorsTabLayout.jsx';
import GeneralInfoLayout from './dmp_opidor_react/src/components/GeneralInfo/GeneralInfoLayout.jsx';
import PlanCreationLayout from './dmp_opidor_react/src/components/PlanCreation/PlanCreationLayout.jsx';
import WritePlanLayout from './dmp_opidor_react/src/components/WritePlan/WritePlanLayout.jsx';
import HelpLayout from './dmp_opidor_react/src/components/Help/HelpLayout.jsx';
import StaticPagesLayout from './dmp_opidor_react/src/components/StaticPages/StaticPagesLayout.jsx';
import GlossaryLayout from './dmp_opidor_react/src/components/Glossary/GlossaryLayout.jsx';
import CookieConsent from './dmp_opidor_react/src/components/CookieConsent';
import BackToTop from './dmp_opidor_react/src/components/BackToTop';
import SharedLabelLayout from './dmp_opidor_react/src/components/SharedLabel/SharedLabelLayout';

export default function mount(components) {
  document.addEventListener('DOMContentLoaded', () => {
    const mountPoints = document.querySelectorAll('[data-react-component]');
    mountPoints.forEach((mountPoint) => {
      const { dataset } = mountPoint;
      const componentName = dataset.reactComponent;
      if (componentName) {
        const Component = components[componentName];
        if (Component) {
          const props = JSON.parse(dataset.props);
          const root = ReactDOM.createRoot(mountPoint);
          root.render(<Component {...props} />);
        } else {
          console.warn(
            'WARNING: No component found for: ',
            dataset.reactComponent,
            components,
          );
        }
      }
    });
  });
}

mount({
  NewsPageLayout,
  GeneralInfoLayout,
  PlanCreationLayout,
  WritePlanLayout,
  CommentList,
  ContributorsTabLayout,
  HelpLayout,
  StaticPagesLayout,
  GlossaryLayout,
  CookieConsent,
  BackToTop,
  SharedLabelLayout,
});
