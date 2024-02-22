/* eslint-disable import/no-relative-packages */
import { define } from 'remount';

import NewsPageLayout from './dmp_opidor_react/src/components/news/NewsPageLayout';
import Comment from './dmp_opidor_react/src/components/Shared/Comment';
import ContributorsTabLayout from './dmp_opidor_react/src/components/ContributorsTab/ContributorsTabLayout';
import GeneralInfoLayout from './dmp_opidor_react/src/components/GeneralInfo/GeneralInfoLayout';
import PlanCreationLayout from './dmp_opidor_react/src/components/PlanCreation/PlanCreationLayout';
import WritePlanLayout from './dmp_opidor_react/src/components/WritePlan/WritePlanLayout';

define({
  'dmp-news-page': NewsPageLayout,
  'dmp-general-info': GeneralInfoLayout,
  'dmp-plan-creation': PlanCreationLayout,
  'dmp-write-plan': WritePlanLayout,
  'dmp-comment': Comment,
  'dmp-contributors-tab': ContributorsTabLayout,
});
