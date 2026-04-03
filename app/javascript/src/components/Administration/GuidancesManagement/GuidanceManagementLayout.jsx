import { StrictMode } from "react";
import { BrowserRouter, Routes, Route } from "react-router";
import { Toaster } from "react-hot-toast";

import Global from "../../context/GlobalContext";
import GuidanceManagement from "./GuidanceManagement";

const toastOptions = {
  duration: 5000,
};

function GuidanceManagementLayout({ locale = "en_GB" }) {
  return (
    <StrictMode>
      <Global initialLocale={locale}>
        <BrowserRouter>
          <Routes>
            <Route path="administration/guidances_management">
              <Route index element={<GuidanceManagement />} />
            </Route>
          </Routes>
        </BrowserRouter>
      </Global>
      <Toaster
        position="bottom-right"
        toastOptions={toastOptions}
        reverseOrder={false}
      />
    </StrictMode>
  );
}

export default GuidanceManagementLayout;
