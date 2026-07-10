import axios from "../utils/AxiosClient";
// import createHeaders from "../utils/HeaderBuilder";

const getGuidancesData = async () =>
  axios.get(`/org_admin/guidances`, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const getNewGuidanceGroupData = async () =>
  axios.get(`/org_admin/guidance_groups/new`, {
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

const getLanguages = async () =>
  axios.get(`/languages`, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const saveGuidanceGroup = async (id, guidanceGroupData) =>
  axios.put(`/org_admin/guidance_groups/${id}`, guidanceGroupData, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const createGuidanceGroup = async (guidanceGroupData) =>
  axios.post(`/org_admin/guidance_groups`, guidanceGroupData, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const publishGuidanceGroup = async (id) =>
  axios.put(`/org_admin/guidance_groups/${id}/publish`, null, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const unpublishGuidanceGroup = async (id) =>
  axios.put(`/org_admin/guidance_groups/${id}/unpublish`, null, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

export default {
  getGuidancesData,
  getNewGuidanceGroupData,
  getGuidanceGroupData,
  getLanguages,
  saveGuidanceGroup,
  createGuidanceGroup,
  publishGuidanceGroup,
  unpublishGuidanceGroup,
};
