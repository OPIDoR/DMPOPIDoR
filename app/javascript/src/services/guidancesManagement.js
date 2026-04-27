import axios from "../utils/AxiosClient";
// import createHeaders from "../utils/HeaderBuilder";

const getGuidancesData = async () =>
  axios.get(`/org_admin/guidances`, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const getGuidanceGroupData = async (guidanceGroupId) =>
  axios.get(`/org_admin/guidance_groups/${guidanceGroupId}`, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

export default {
  getGuidancesData,
  getGuidanceGroupData,
};
