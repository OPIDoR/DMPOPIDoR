import { exists, pick } from "./utils";

/**
 * This method builds a select options list from a data array
 * @param dataList : a list of data to build the options from
 */
export function createSelectOptions(dataList) {
  return dataList.map((option) => ({
    value: option.id,
    label: option.label,
    object: option,
  }));
}
export function checkFragmentExists(
  fragmentList,
  newFragment,
  unicityCriteria,
) {
  if (unicityCriteria === undefined || unicityCriteria.length === 0)
    return false;
  if (fragmentList.length === 0) return false;

  // the filter method is here to remove the fragment from the list based on its id
  // this prevents the search to create false positives when updating a fragment.
  const list = fragmentList
    .filter((o) => o.id === undefined || o.id !== newFragment.id) // remove check fragment from list
    .map((f) => pick(f, unicityCriteria)) // pick properties listed in unicityCriteria array
    .filter((v) => Object.keys(v).length !== 0); // filter empty objects
  const filteredFragment = pick(newFragment, unicityCriteria);
  return exists(filteredFragment, list, unicityCriteria);
}
