import axios from '../utils/AxiosClient';
import createHeaders from '../utils/HeaderBuilder';

const getTour = async (tourName) => axios.get(`/guided_tour/${tourName}`);

const endTour = async (tourName) => axios.post(`/guided_tour/${tourName}`, {}, { headers: createHeaders({}, true) });

export default {
  getTour,
  endTour,
};
