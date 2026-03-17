import { useTranslation } from "react-i18next";

import * as styles from "../../assets/css/guidance_edition.module.css";

function GuidanceGroupsList({ guidanceGroups }) {
  const { t } = useTranslation();

  /**
   * USE EFFECTS
   */

  /**
   * RENDERING
   */

  return (
    <table className="table table-hover">
      <thead>
        <tr>
          <th scope="col">{t("name")}</th>
          <th scope="col">{t("status")}</th>
          <th scope="col">{t("optionalSubset")}</th>
          <th scope="col">{t("dataTypesTopics")}</th>
          <th scope="col">{t("locale")}</th>
          <th scope="col">{t("lastUpdated")}</th>
          <th scope="col">{t("actions")}</th>
        </tr>
      </thead>
      <tbody>
        {guidanceGroups.length > 0 ? (
          guidanceGroups.map((group) => (
            <tr key={group.id}>
              <td>{group.name}</td>
              <td className={styles.table_row}>
                {group.published ? t("published") : t("unpublished")}
              </td>
              <td className={styles.table_row}>
                {group.optional_subset ? t("yes") : t("no")}
              </td>
              <td className={styles.table_row}>
                {`${group.data_types.join(", ")} / ${group.topics.join(", ")}`}
              </td>
              <td className={styles.table_row}>{group.locale}</td>
              <td className={styles.table_row}>{group.last_updated}</td>
              <td></td>
            </tr>
          ))
        ) : (
          <tr>
            <td colSpan="7" style={{ textAlign: "left" }}>
              {t("noData")}
            </td>
          </tr>
        )}
      </tbody>
    </table>
  );
}

export default GuidanceGroupsList;
