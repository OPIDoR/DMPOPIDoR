import { StrictMode } from "react";

import Global from "../context/GlobalContext.jsx";
import ContributorsTab from "./ContributorsTab.jsx";
import PlanTabLayout from "../Shared/Layouts/PlanTabLayout.jsx";
import "../../i18n.js";
import { Toaster } from "react-hot-toast";

const toastOptions = {
  duration: 5000,
};

function ContributorsTabLayout({
  planId,
  planTitle,
  dmpId,
  locale,
  readonly,
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
          <ContributorsTab readonly={readonly} />
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

export default ContributorsTabLayout;
