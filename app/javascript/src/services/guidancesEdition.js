import axios from "../utils/AxiosClient";
// import createHeaders from "../utils/HeaderBuilder";

const getGuidancesData = async () => axios.get(`/org_admin/guidances_edition`);

export default {
  getGuidancesData,
};
