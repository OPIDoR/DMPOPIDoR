import { StrictMode, useEffect } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import Global from "../context/Global.jsx";
import PlanCreation from "./PlanCreation.jsx";
import "../../i18n.js";
import { clearLocalStorage } from "../../utils/utils";

const queryClient = new QueryClient();

function PlanCreationLayout({ locale }) {
  useEffect(() => {
    window.addEventListener("beforeunload", () => clearLocalStorage());
  }, []);

  return (
    <StrictMode>
      <Global>
        <QueryClientProvider client={queryClient}>
          <PlanCreation locale={locale} />
        </QueryClientProvider>
      </Global>
    </StrictMode>
  );
}

export default PlanCreationLayout;
