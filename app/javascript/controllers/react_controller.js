import { Controller } from "@hotwired/stimulus";
import React from "react";
import ReactDOM from "react-dom/client";

import NewsPageLayout from "../src/components/news/NewsPageLayout.jsx";
import CommentList from "../src/components/Shared/CommentList.jsx";
import ContributorsTabLayout from "../src/components/ContributorsTab/ContributorsTabLayout.jsx";
import GeneralInfoLayout from "../src/components/GeneralInfo/GeneralInfoLayout.jsx";
import PlanCreationLayout from "../src/components/PlanCreation/PlanCreationLayout.jsx";
import WritePlanLayout from "../src/components/WritePlan/WritePlanLayout.jsx";
import HelpLayout from "../src/components/Help/HelpLayout.jsx";
import StaticPagesLayout from "../src/components/StaticPages/StaticPagesLayout.jsx";
import GlossaryLayout from "../src/components/Glossary/GlossaryLayout.jsx";
import CookieConsent from "../src/components/CookieConsent/index.jsx";
import BackToTop from "../src/components/BackToTop/index.jsx";
import SharedLabelLayout from "../src/components/SharedLabel/SharedLabelLayout.jsx";

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
};

export default class extends Controller {
  static values = {
    component: String,
    props: Object,
  };

  connect() {
    const module = modules[this.componentValue];
    if (module) {
      this.root = ReactDOM.createRoot(this.element);
      this.root.render(React.createElement(module, this.propsValue));
    } else {
      console.error(`Could not find module ${this.componentValue}`);
    }
  }

  disconnect() {
    this.root.unmount();
  }
}
