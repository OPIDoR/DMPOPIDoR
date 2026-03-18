import axios from '../utils/AxiosClient';
import createHeaders from '../utils/HeaderBuilder';

const hasQuestionGuidances = async (questionId, researchOutputId) => axios.get(`/research_outputs/${researchOutputId}/has_guidances?question=${questionId}`);

const getGuidances = async (researchOutputId, questionId) => axios.get(`/research_outputs/${researchOutputId}/guidances?question=${questionId}`);

const getPlanGuidanceGroups = async (planId) => axios.get(`/plans/${planId}/guidance_groups`);

const postPlanGuidanceGroups = async (jsonObject, planId) => axios.post(`/plans/${planId}/guidance_groups`, jsonObject, { headers: createHeaders({}, true) });

const getResearchOutputGuidanceGroups = async (researchOutputId) => axios.get(`/research_outputs/${researchOutputId}/guidance_groups`);

const reinitResearchOutputGuidanceGroups = async (researchOutputId) => axios.get(`/research_outputs/${researchOutputId}/reinit_guidance_groups`);

const postResearchOutputGuidanceGroups = async (jsonObject, researchOutputId) => axios.post(`/research_outputs/${researchOutputId}/guidance_groups`, jsonObject, { headers: createHeaders({}, true) });

export default {
  hasQuestionGuidances,
  getGuidances,
  getPlanGuidanceGroups,
  postPlanGuidanceGroups,
  getResearchOutputGuidanceGroups, 
  reinitResearchOutputGuidanceGroups,
  postResearchOutputGuidanceGroups,
};
