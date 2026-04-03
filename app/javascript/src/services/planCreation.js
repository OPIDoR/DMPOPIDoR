import axios from '../utils/AxiosClient';
import createHeaders from '../utils/HeaderBuilder';

/**
 * This function returns a default template data object or an error if it fails to retrieve the data.
 * @param token - The `token` parameter is not used in the `getDefaultModel` function. It is not necessary for the function to work properly.
 * @returns an object with a `data` property that contains the `dataDefaultModel` value.
 */
const getRecommendedTemplate = async (researchContext, locale) => axios.get(`/template_options/recommend?context=${researchContext}&locale=${locale}`);

/**
 * This is an asynchronous function that retrieves data for an other organism by ID and name using a token and context.
 * @param orgData - An object containing the id and name of the research organization.
 * @returns An object with a "data" property, which contains the data for the "dataOtherOrganismeById" variable.
 */

const getTemplatesByOrgId = async (orgData, researchContext) => {
  const { id, name } = orgData;

  return axios.get('/template_options', {
    params: {
      'plan[research_org_id][id]': id,
      'plan[research_org_id][name]': name,
      'plan[research_org_id][sort_name]': name,
      'plan[funder_id]': 'none',
      'plan[context]': researchContext,
    },
  });
};

/**
 * This function returns a mock data object for an organism.
 * @param token - The `token` parameter is not used in the `getOrganisme` function. It is not necessary for the function to work properly.
 * @returns an object with a "data" property that contains the dataOrganisme variable.
 */
const getOrgs = async (researchContext, templateLanguage) => axios.get(`/orgs/list?context=${researchContext}&locale=${templateLanguage}&type=org`);

/**
 * Send choosen templateId to the back for the plan creation,
 * Redirect to the newly created plan if necessary
 * @param templateId identifier of the choosen template
 * @returns
 */
const createPlan = async (template_id, context) => axios.post('/plans', { template_id, context }, { headers: createHeaders({}, true) });

const importPlan = async (formData) => axios.post('/plans/import', formData, {
  headers: {
    ...createHeaders({}, true),
    'Content-Type': 'multipart/form-data',
    Accept: 'application/json',
  },
  maxRedirects: 0,
});

export default {
  getRecommendedTemplate,
  getTemplatesByOrgId,
  getOrgs,
  createPlan,
  importPlan,
};
