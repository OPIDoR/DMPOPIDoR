import axios from 'axios';
import createHeaders from '../utils/HeaderBuilder';

const getFragment = async (id) => axios.get(`/madmp_fragments/${id}`);

const getNewForm = async (questionId, researchOutputId) => axios.get(`/answers/new_form?question_id=${questionId}&research_output_id=${researchOutputId}`);

const createFragment = async (data = {}, madmpSchemaId, dmpId, questionId = null, researchOutputId = null) => axios.post(
  '/madmp_fragments',
  {
    data,
    schema_id: madmpSchemaId,
    dmp_id: dmpId,
    question_id: questionId,
    research_output_id: researchOutputId,
  },
  { headers: createHeaders({}, true) },
);

const destroyFragment = async (fragmentId) => axios.delete(
  `/madmp_fragments/${fragmentId}`,
  { headers: createHeaders({}, true) },
);

const getSchema = async (id) => axios.get(`/madmp_schemas/${id}`);

const getSchemaByName = async (name) => axios.get(`/madmp_schemas/by_name/${name}`);

const getRegistryByName = async (name, page = null) => axios.get(`/registries/by_name/${name}`, { params: { page } });

const getAvailableRegistries = async (category, dataType, topic) => axios.get(`/registries?category=${category}&data_type=${dataType}&topic=${topic}`);

const suggestRegistry = async (category, dataType) => axios.get(`/registries/suggest?category=${category}&data_type=${dataType}`);

const getPersons = async (dmpId) => axios.get(`/madmp_fragments/load_fragments?dmp_id=${dmpId}&classname=person`);

const getContributors = async (planId) => axios.get(`/plans/${planId}/contributors_data`);

const destroyContributor = async (fragmentId) => axios.delete(
  `/madmp_fragments/destroy_contributor?contributor_id=${fragmentId}`,
  { headers: createHeaders({}, true) },
);

/**
 * It sends a POST request to the server with the jsonObject as the body of the request.
 * </code>
 * @param id - The fragment id
 * @param jsonObject - the data you want to send to the server
 * @returns The response object from the server.
 */
const saveFragment = async (id, jsonObject) => axios.put(`/madmp_fragments/${id}`, jsonObject, {
  headers: createHeaders({}, true),
});

const getAvailableForms = async (className, dataType, topic) => axios.get(`/madmp_schemas?classname=${className}&data_type=${dataType}&topic=${topic}`);

const runScript = async (fragmentId, scriptName) => axios.get(`/codebase/run?fragment_id=${fragmentId}&script_name=${scriptName}`);

export default {
  getFragment,
  getNewForm,
  createFragment,
  destroyFragment,
  getSchema,
  getSchemaByName,
  getRegistryByName,
  getAvailableRegistries,
  suggestRegistry,
  getPersons,
  saveFragment,
  getContributors,
  destroyContributor,
  getAvailableForms,
  runScript,
};
