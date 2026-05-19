import { StrictMode } from "react";

import Global from "../context/GlobalContext.jsx";
import ContributorsTab from "./ContributorsTab.jsx";
import "../../i18n.js";
import { Toaster } from "react-hot-toast";

const toastOptions = {
  duration: 5000,
};

function ContributorsTabLayout({ planId, locale, readonly }) {
  return (
    <StrictMode>
      <Global initialLocale={locale}>
        <ContributorsTab planId={planId} readonly={readonly} />
        <Toaster
          position="bottom-right"
          toastOptions={toastOptions}
          reverseOrder={false}
        />
      </Global>
    </StrictMode>
  );
}

export default ContributorsTabLayout;
