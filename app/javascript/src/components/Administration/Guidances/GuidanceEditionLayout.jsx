import { StrictMode } from "react";

import { Toaster } from "react-hot-toast";
import Global from "../../context/GlobalContext";
import GuidanceEdition from "./GuidanceEdition";

const toastOptions = {
  duration: 5000,
};

function GuidanceEditionLayout({ locale = "en_GB" }) {
  return (
    <StrictMode>
      <Global initialLocale={locale}>
        <GuidanceEdition />
      </Global>
      <Toaster
        position="bottom-right"
        toastOptions={toastOptions}
        reverseOrder={false}
      />
    </StrictMode>
  );
}

export default GuidanceEditionLayout;
