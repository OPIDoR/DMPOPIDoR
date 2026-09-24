import { StrictMode } from "react";
import { useTranslation } from "react-i18next";

import "../../i18n.js";

export default function SharedLabelLayout({ planId, clients }) {
  const { t } = useTranslation();

  /**
   * RENDERING
   */

  return (
    <StrictMode>
      <span>
        {clients?.length > 0 && (
          <a href={`/plans/${planId}/share`}>
            <button className="btn btn-primary">
              {t("planSharedWithNames", {
                names: clients.join(", "),
              })}
            </button>
          </a>
        )}
      </span>
    </StrictMode>
  );
}
