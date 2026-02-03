import axios from '../utils/AxiosClient';

const get = async (perPage = 3) => axios.get(`https://opidor.fr/wp-json/wp/v2/posts?per_page=${perPage}&categories=5&_embed`);

export default {
  get,
};
