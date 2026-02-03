import { toast } from 'react-hot-toast';
import axios from '../utils/AxiosClient';
import createHeaders from '../utils/HeaderBuilder';
import { getErrorMessage } from '../utils/utils';

/**
 * This function sends a post request to a server with a JSON object and handles any errors that may occur.
 * @param jsonObject - This is an object containing the data to be sent in the POST request.
 * @returns An object with a "data" property, which is not defined in the code snippet. The value of "data" is likely intended to be the response data
 * from the axios post request, but it is not currently being assigned or returned correctly.
 */
const create = async (jsonObject) => axios.post('/research_outputs', jsonObject, { headers: createHeaders({}, true) });

const update = async (id, jsonObject) => axios.patch(`/research_outputs/${id}`, jsonObject, { headers: createHeaders({}, true) });

const get = async (roId) => axios.get(`/research_outputs/${roId}`);

/**
 * This function adds a new object to a list in session storage.
 * @param planId - The ID of the plan to which the product is being imported.
 * @param researchOutputId - The researchOutputId parameter is a unique identifier for a product that is being imported.
 * @returns an object with a "data" property that contains the updated data stored in the session storage.
 */
const importResearchOutput = async ({ planId, uuid, duplicate }) => {
  let res;
  try {
    res = await axios.post(`/research_outputs/import?plan_id=${planId}`, { uuid, duplicate }, { headers: createHeaders({}, true) });
  } catch (error) {
    return toast.error(getErrorMessage(error));
  }
  return res;
};

/**
 * This function sends a DELETE request to a specific endpoint to delete a search product associated with a plan ID and research output ID.
 * @param planId - The ID of the plan that the research output belongs to.
 * @param id - The `id` parameter is the unique identifier of the research output that needs to be deleted.
 * @returns a Promise that resolves to the response object returned by the axios.delete() method.
 */
const deleteResearchOutput = async (researchOutputId) => {
  let response;
  try {
    response = await axios.delete(`/research_outputs/${researchOutputId}`, { headers: createHeaders({}, true) });
  } catch (error) {
    toast.error(getErrorMessage(error));
  }
  return response;
};

/**
 * This function retrieves plans using a token and returns them as data.
 * @returns An object with a "data" property that contains the "plans" data. However, the "plans" variable is not defined in the code snippet, so it is
 * unclear what data is being returned.
 */
const getPlans = async () => {
  let res;
  try {
    res = await axios.get('/plans', {
      headers: {
        Accept: 'application/json',
      },
    });
  } catch (error) {
    return error;
  }
  return res;
};

const sort = async (planId, updatedOrder) => {
  let res;
  try {
    res = await axios.post('/research_outputs/sort', {
      plan_id: planId,
      updated_order: updatedOrder,
    }, { headers: createHeaders({}, true) });
  } catch (error) {
    return error;
  }
  return res;
};

export default {
  create,
  update,
  get,
  importResearchOutput,
  deleteResearchOutput,
  getPlans,
  sort,
};
