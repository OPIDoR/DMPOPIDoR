import axios from '../utils/AxiosClient';

/**
 * The function retrieves data from session storage or sets it if it doesn't exist.
 * @param token - The `token` parameter is not used in the `getPlanData` function. It is not necessary for the function to work properly.
 * @returns An object with a property "data" that contains either the parsed JSON data from sessionStorage if it exists, or the original dataObject if it
 * does not.
 */
const getPlanData = async (planId) => axios.get(`/plans/${planId}/research_outputs_data`);
const getSectionsData = async (templateId) => axios.get(`/templates/${templateId}`);

export default {
  getPlanData,
  getSectionsData,
};
