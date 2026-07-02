import { StrictMode } from "react";

import Global from "../context/GlobalContext.jsx";
import SectionsProvider from "../context/SectionsContext.jsx";

import GeneralInfo from "./GeneralInfo.jsx";
import GuidanceSelector from "../GuidanceChoice/GuidanceSelector.jsx";
import "../../i18n.js";
import { Toaster } from "react-hot-toast";
import PlanTabLayout from "../Shared/Layouts/PlanTabLayout.jsx";

const toastOptions = {
  duration: 5000,
};

function GeneralInfoLayout({
  planId,
  planTitle,
  dmpId,
  projectFragmentId,
  metaFragmentId,
  locale = "en_GB",
  researchContext = "research_project",
  isTest = false,
  isClassic = false,
  readonly = false,
  clientsName = [],
}) {
  return (
    <StrictMode>
      <Global
        initialLocale={locale}
        initialDmpId={dmpId}
        initialPlanTitle={planTitle}
        initialPlanId={planId}
        initialClients={clientsName}
      >
        <PlanTabLayout>
          {isClassic && !readonly && (
            <SectionsProvider>
              <GuidanceSelector planId={planId} context={"plan"} />
            </SectionsProvider>
          )}
          <GeneralInfo
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
        </PlanTabLayout>
      </Global>
    </StrictMode>
  );
}

export default GeneralInfoLayout;
