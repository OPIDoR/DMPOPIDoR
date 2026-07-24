import axios from "../utils/AxiosClient";
// import createHeaders from "../utils/HeaderBuilder";

/**
 * Guidance Groups
 */
const getGuidanceGroupsData = async () =>
  axios.get(`/org_admin/guidance_groups`, {
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

const deleteGuidanceGroup = async (id) =>
  axios.delete(`/org_admin/guidance_groups/${id}`, null, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

/**
 * Guidances
 */
const getGuidancesData = async () =>
  axios.get(`/org_admin/guidances`, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const getNewGuidanceData = async () =>
  axios.get(`/org_admin/guidances/new`, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const getGuidanceData = async (guidanceId) =>
  axios.get(`/org_admin/guidances/${guidanceId}`, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const createGuidance = async (guidanceData) =>
  axios.post(
    `/org_admin/guidances`,
    { guidance: guidanceData },
    {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    },
  );

const saveGuidance = async (id, guidanceData) =>
  axios.put(
    `/org_admin/guidances/${id}`,
    { guidance: guidanceData },
    {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    },
  );

const getLanguages = async () =>
  axios.get(`/languages`, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

const getThemes = async (locale, dataTypes) =>
  axios.get(`/org_admin/themes?locale=${locale}&data_types=${dataTypes}`, {
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  });

export default {
  getGuidanceGroupsData,
  getNewGuidanceGroupData,
  getGuidanceGroupData,
  saveGuidanceGroup,
  createGuidanceGroup,
  publishGuidanceGroup,
  unpublishGuidanceGroup,
  deleteGuidanceGroup,
  getLanguages,
  getGuidancesData,
  getNewGuidanceData,
  getGuidanceData,
  createGuidance,
  saveGuidance,
  getThemes,
};
