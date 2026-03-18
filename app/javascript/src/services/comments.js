import axios from '../utils/AxiosClient';
import createHeaders from '../utils/HeaderBuilder';

const commonHeaders = createHeaders({}, true);

/**
 * Fetches comments associated with an answer by making a GET request to the server.
 *
 * @param {string} answerId - The identifier of the answer for which to retrieve comments.
 * @returns {Promise} A promise that resolves with the retrieved comments or nothing if the answerId is missing.
 */
const get = async (answerId) => {
  if (!answerId) return [];

  return axios.get(`/answers/${answerId}/notes`, { headers: createHeaders({}, false) });
};

/**
 * Creates a new comment by sending a POST request to the server.
 *
 * @param {Object} comment - The comment data to be sent in the request body.
 * @returns {Promise} A promise that resolves with the created comment response.
 */
const create = async (comment) => axios.post('/notes', comment, { headers: commonHeaders });

/**
 * Updates an existing comment with the provided data by sending a PUT request to the server.
 *
 * @param {Object} comment - The updated comment data.
 * @returns {Promise} A promise that resolves with the updated comment response if the comment has an 'id', otherwise, it returns nothing.
 */
const update = async (comment) => {
  const { id } = comment;
  if (!id) return;

  return axios.put(`/notes/${id}`, comment, { headers: commonHeaders });
};

/**
 * Archives a comment by sending a PATCH request to the server with the 'archive' action.
 *
 * @param {string} id - The identifier of the comment to be archived.
 * @param {Object} comment - The comment data, including the 'archive' action if needed.
 * @returns {Promise} A promise that resolves with the server response for the archive request.
 */
const archive = async (id, comment) => axios.patch(`/notes/${id}/archive`, comment, { headers: commonHeaders });

export default {
  get,
  create,
  update,
  archive,
};
