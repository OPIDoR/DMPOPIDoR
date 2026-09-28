import { StrictMode } from "react";
import { Toaster } from "react-hot-toast";
import { useTranslation } from "react-i18next";

import Global from "../context/GlobalContext.jsx";
import SectionsProvider from "../context/SectionsContext.jsx";
import WritePlan from "./WritePlan.jsx";
import "../../i18n.js";

import Driver from "../Shared/Driver/index.jsx";
import { writePlanSteps } from "../Shared/Tours";
import PlanTabLayout from "../Shared/Layouts/PlanTabLayout.jsx";

const toastOptions = {
  duration: 5000,
};

function WritePlanLayout({
  planId,
  planTitle,
  dmpId,
  locale = "en_GB",
  userId,
  commentablePlan = false,
  readonly,
  configuration = {},
  clientsName = [],
}) {
  const { t } = useTranslation();

  return (
    <StrictMode>
      <Global
        initialLocale={locale}
        initialDmpId={dmpId}
        initialUserId={userId}
        initialCommentablePlan={commentablePlan}
        initialPlanTitle={planTitle}
        initialPlanId={planId}
        initialClients={clientsName}
      >
        <SectionsProvider>
          <Driver
            tourName="write_plan"
            steps={writePlanSteps(t)}
            locale={locale}
          >
            <PlanTabLayout>
              <WritePlan
                readonly={readonly}
                configuration={configuration}
                className="research-outputs-tabs"
              />
            </PlanTabLayout>
          </Driver>
          <Toaster
            position="bottom-right"
            toastOptions={toastOptions}
            reverseOrder={false}
          />
        </SectionsProvider>
      </Global>
    </StrictMode>
  );
}

export default WritePlanLayout;
