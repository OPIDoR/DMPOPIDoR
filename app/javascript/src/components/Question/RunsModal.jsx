import { useState, useRef, useContext } from "react";
import { useTranslation } from "react-i18next";
import Swal from "sweetalert2";

import CustomError from "../Shared/CustomError.jsx";
import CustomSpinner from "../Shared/CustomSpinner.jsx";
import InnerModal from "../Shared/InnerModal/InnerModal.jsx";
import { createFormLabel } from "../../utils/GeneratorUtils.js";
import CustomButton from "../Styled/CustomButton.jsx";
import { GlobalContext } from "../context/GlobalContext.jsx";
import { FormsContext } from "../context/FormsContext.jsx";
import { madmpFragment } from "../../services/index.js";
import swalUtils from "../../utils/swalUtils.js";
import { getErrorMessage } from "../../utils/utils.js";

function RunsModal({ shown, hide, scriptsData, fragmentId }) {
  const { t } = useTranslation();
  const { locale, setClients } = useContext(GlobalContext);
  const { setFormData } = useContext(FormsContext);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const modalRef = useRef(null);

  const handleRunScript = (scriptName) => {
    if (
      scriptsData?.apiClient &&
      scriptName.toLocaleLowerCase().includes("notifyer")
    ) {
      Swal.fire({
        ...swalUtils.defaultConfirmConfig(t),
        text: t(
          "By using this notification, you will allow {{clientName}} to access the full content of your plan. Do you confirm ?",
          { clientName: scriptsData?.apiClient?.name },
        ),
      }).then((result) => {
        if (result.isConfirmed) executeScript(scriptName);
      });
    } else {
      executeScript(scriptName);
    }
  };

  const handleCloseError = () => {
    setError(null);
    setLoading(false);
  };

  function executeScript(scriptName) {
    setLoading(true);
    madmpFragment
      .runScript(fragmentId, scriptName)
      .then((res) => {
        if (res.data.needs_reload) {
          setFormData({
            [fragmentId]: {
              ...res.data.fragment,
              template_name: res.data.template_name,
            },
          });
          setSuccess(t("newDataAvailableInForm"));
        } else {
          setSuccess(res.data.message);
        }
        setClients(res?.data?.clients || []);
      })
      .catch((error) => {
        const errorMessage = getErrorMessage(error);
        setError({
          home: false,
          code: error.response.status,
          error: errorMessage,
        });
      })
      .finally(() => {
        setLoading(false);
      });
  }

  return (
    <InnerModal show={shown} ref={modalRef}>
      <InnerModal.Header
        closeButton
        expandButton
        ref={modalRef}
        onClose={() => {
          hide();
          setError(null);
          setSuccess(null);
        }}
      >
        <InnerModal.Title>{t("tools")}</InnerModal.Title>
      </InnerModal.Header>
      <InnerModal.Body style={{ backgroundColor: "white" }}>
        {loading && <CustomSpinner isOverlay={true} />}
        {!loading && error && (
          <CustomError
            error={error}
            showWarning={false}
            handleClose={handleCloseError}
          />
        )}
        {!error && (
          <>
            {scriptsData.scripts.map((script, idx) => (
              <div key={idx}>
                <CustomButton
                  handleClick={() => handleRunScript(script.name)}
                  title={createFormLabel(script, locale)}
                  buttonColor={"white"}
                  position="center"
                />
                <span>{script?.[`tooltip@${locale}`]}</span>
              </div>
            ))}
          </>
        )}
      </InnerModal.Body>
      <InnerModal.Footer>
        {success && (
          <span style={{ color: "var(--green)", fontWeight: "bold" }}>
            {success}
          </span>
        )}
      </InnerModal.Footer>
    </InnerModal>
  );
}

export default RunsModal;
