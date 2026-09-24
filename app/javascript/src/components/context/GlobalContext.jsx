import { createContext, useMemo, useState } from "react";

/* It's getting the form from localStorage. */
// const formLocalState = JSON.parse(localStorage.getItem('formData'));
// const researchOutputsLocalState = JSON.parse(sessionStorage.getItem("researchOutputs"));
export const GlobalContext = createContext();

/**
 * It's a function that takes a prop called children and returns a GlobalContext.Provider
 * component that has a value prop that is an object with two
 * properties: form and setform.
 * @returns The GlobalContext.Provider is being returned.
 */
function Global({
  children,
  initialLocale = "fr_FR",
  initialDmpId = null,
  initialPlanId = null,
  initialUserId = -1,
  initialCommentablePlan = false,
  initialPlanTitle = "",
  initialClients = [],
}) {
  const locale = initialLocale;
  const dmpId = initialDmpId;
  const planId = initialPlanId;
  const userId = initialUserId;
  const commentablePlan = initialCommentablePlan;

  const [configuration, setConfiguration] = useState({});
  const [planTitle, setPlanTitle] = useState(initialPlanTitle);
  const [clients, setClients] = useState(initialClients);

  const contextValue = useMemo(
    () => ({
      locale,
      dmpId,
      planId,
      userId,
      configuration,
      setConfiguration,
      commentablePlan,
      planTitle,
      setPlanTitle,
      clients,
      setClients,
    }),
    [
      locale,
      dmpId,
      planId,
      userId,
      configuration,
      commentablePlan,
      planTitle,
      clients,
    ],
  );

  return (
    <GlobalContext.Provider value={contextValue}>
      {children}
    </GlobalContext.Provider>
  );
}

export default Global;
