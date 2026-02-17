import { StrictMode } from "react";
import { Toaster } from "react-hot-toast";
import { useTranslation } from "react-i18next";

import Global from "../context/GlobalContext.jsx";
import ResearchOutputs from "../context/ResearchOutputsContext.jsx";
import WritePlan from "./WritePlan.jsx";
import "../../i18n.js";

import Driver from "../Shared/Driver/index.jsx";
import { writePlanSteps } from "../Shared/Tours";

const toastOptions = {
  duration: 5000,
};

function WritePlanLayout({
  planId,
  dmpId,
  locale = "en_GB",
  userId,
  commentablePlan = false,
  readonly,
  configuration = {},
}) {
  const { t } = useTranslation();

  return (
    <StrictMode>
      <Global
        initialLocale={locale}
        initialDmpId={dmpId}
        initialUserId={userId}
        initialCommentablePlan={commentablePlan}
      >
        <ResearchOutputs>
          <Driver
            tourName="write_plan"
            steps={writePlanSteps(t)}
            locale={locale}
          >
            <WritePlan
              planId={planId}
              readonly={readonly}
              configuration={configuration}
              className="research-outputs-tabs"
            />
          </Driver>
          <Toaster
            position="bottom-right"
            toastOptions={toastOptions}
            reverseOrder={false}
          />
        </ResearchOutputs>
      </Global>
    </StrictMode>
  );
}

export default WritePlanLayout;
