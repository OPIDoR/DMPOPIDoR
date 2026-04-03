import axios from '../utils/AxiosClient';
import createHeaders from '../utils/HeaderBuilder';

const commonHeaders = createHeaders({}, true);

const saveIsTestPlan = async (planId, isTestPlan) => axios.post(`/plans/${planId}/set_test`, { checked: isTestPlan }, { headers: commonHeaders });

/**
 * The function `saveFunder` returns an empty array and catches any errors that occur during execution.
 * @param grantId - The ID of a grant project.
 * @param projectFragmentId - The `projectFragmentId` parameter is an identifier for a specific fragment of a project. It is used in conjunction with the
 * `grantId` parameter to retrieve data related to a specific project and fragment.
 * @param scriptName Script name
 * @returns An object with a "data" property that contains an empty array.
 */
const importProject = async (grantId, projectFragmentId, scriptName) => axios.get(`/codebase/project_search?project_id=${grantId}&fragment_id=${projectFragmentId}&script_name=${scriptName}`);

const share = async (grantId, projectFragmentId, apiClient) => axios.get(`/codebase/share?project_id=${grantId}&fragment_id=${projectFragmentId}&api_client=${apiClient}`);

export default {
  saveIsTestPlan,
  importProject,
  share,
};
