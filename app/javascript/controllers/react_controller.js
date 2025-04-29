import { Controller } from "@hotwired/stimulus"
import React from "react"
import ReactDOM from "react-dom/client"

import NewsPageLayout from '../dmp_opidor_react/src/components/news/NewsPageLayout.jsx';
import CommentList from '../dmp_opidor_react/src/components/Shared/CommentList.jsx';
import ContributorsTabLayout from '../dmp_opidor_react/src/components/ContributorsTab/ContributorsTabLayout.jsx';
import GeneralInfoLayout from '../dmp_opidor_react/src/components/GeneralInfo/GeneralInfoLayout.jsx';
import PlanCreationLayout from '../dmp_opidor_react/src/components/PlanCreation/PlanCreationLayout.jsx';
import WritePlanLayout from '../dmp_opidor_react/src/components/WritePlan/WritePlanLayout.jsx';
import HelpLayout from '../dmp_opidor_react/src/components/Help/HelpLayout.jsx';
import StaticPagesLayout from '../dmp_opidor_react/src/components/StaticPages/StaticPagesLayout.jsx';
import GlossaryLayout from '../dmp_opidor_react/src/components/Glossary/GlossaryLayout.jsx';
import CookieConsent from '../dmp_opidor_react/src/components/CookieConsent';
import BackToTop from '../dmp_opidor_react/src/components/BackToTop';
import SharedLabelLayout from '../dmp_opidor_react/src/components/SharedLabel/SharedLabelLayout';

const modules = {
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
}

export default class extends Controller {
  static values = {
    component: String,
    props: Object
  }

  connect() {
    const module = modules[this.componentValue]
    if (module) {
      this.root = ReactDOM.createRoot(this.element)
      this.root.render(
        React.createElement(module, this.propsValue)
      )
    } else {
      console.error(`Could not find module ${this.componentValue}`)
    }
  }

  disconnect() {
    this.root.unmount()
  }
}
