import axios from "../utils/AxiosClient";

/**
 * The function retrieves data from session storage or sets it if it doesn't exist.
 * @param token - The `token` parameter is not used in the `getResearchOutputsData` function. It is not necessary for the function to work properly.
 * @returns An object with a property "data" that contains either the parsed JSON data from sessionStorage if it exists, or the original dataObject if it
 * does not.
 */
const getResearchOutputsData = async (planId, researchOutputId) =>
  axios.get(
    `/research_outputs?plan_id=${planId}&${researchOutputId ? "research_output_id=" + researchOutputId : ""}`,
  );
const getSectionsData = async (templateId) =>
  axios.get(`/templates/${templateId}`);

export default {
  getResearchOutputsData,
  getSectionsData,
};
