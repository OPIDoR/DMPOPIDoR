import axios from '../utils/AxiosClient';

const getRor = async (query, filter) => axios.get('/api/v1/madmp/services/ror', { params: { query, filter } });

const getOrcid = async (search) => axios.get('/api/v1/madmp/services/orcid', { params: { search } });

const getMetadore = async (query, type) => {
  if (/^10.\d{4,9}\/[-._;()/:A-Z0-9]+$/i.test(query)) {
    query = `(attributes.doi: "${query}")`;
  } else {
    query = `(attributes.titles.title: "${query}")`;
  }

  if (type) {
    query = `(${query} AND (attributes.types.resourceTypeGeneral: "${type}"))`;
  }

  return axios.get('/api/v1/madmp/services/metadore', { params: { query } });
};

export default {
  getRor,
  getOrcid,
  getMetadore,
};
