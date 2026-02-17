import { StrictMode, useEffect } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

import Global from "../context/GlobalContext.jsx";
import PlanCreation from "./PlanCreation.jsx";
import "../../i18n.js";

const queryClient = new QueryClient();

function PlanCreationLayout({ locale }) {
  /**
   * USE EFFECTS
   */

  useEffect(() => {
    window.addEventListener("beforeunload", () => {
      if (localStorage.getItem("action")) {
        localStorage.removeItem("action");
      }
    });
  }, []);

  /**
   * RENDERING
   */

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
