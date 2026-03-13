import { StrictMode } from "react";

import Global from "../context/GlobalContext.jsx";
import GeneralInfo from "./GeneralInfo.jsx";
import GuidanceSelector from "../GuidanceSelection/GuidanceSelector.jsx";
import "../../i18n.js";
import { Toaster } from "react-hot-toast";

const toastOptions = {
  duration: 5000,
};

function GeneralInfoLayout({
  planId,
  dmpId,
  projectFragmentId,
  metaFragmentId,
  locale = "en_GB",
  researchContext = "research_project",
  isTest = false,
  isClassic = false,
  readonly = false,
}) {
  return (
    <StrictMode>
      <Global initialLocale={locale} initialDmpId={dmpId}>
        {isClassic && !readonly && (
          <GuidanceSelector planId={planId} context={"plan"} />
        )}
        <GeneralInfo
          planId={planId}
          projectFragmentId={projectFragmentId}
          metaFragmentId={metaFragmentId}
          researchContext={researchContext}
          isTest={isTest}
          readonly={readonly}
          isClassic={isClassic}
        />
        <Toaster
          position="bottom-right"
          toastOptions={toastOptions}
          reverseOrder={false}
        />
      </Global>
    </StrictMode>
  );
}

export default GeneralInfoLayout;
