import { useTranslation } from "react-i18next";
import Dropdown from "react-bootstrap/Dropdown";
import Table from "react-bootstrap/Table";

import * as tablesStyles from "../../assets/css/tables.module.css";
import { useState } from "react";
import Pagination from "../../Shared/Pagination";

function GuidanceGroupList({
  guidanceGroups,
  handleEdit,
  handleDelete,
  handlePublication,
}) {
  console.log(guidanceGroups);
  const { t } = useTranslation();
  const pageSize = 10;
  const [displayedGuidanceGroups, setDisplayedGuidanceGroups] = useState([]);

  const onChangePage = (pageOfItems) => {
    // update state with new page of items
    setDisplayedGuidanceGroups(pageOfItems);
  };

  /**
   * USE EFFECTS
   */

  /**
   * RENDERING
   */

  return (
    <>
      <Table hover striped>
        <thead>
          <tr>
            <th scope="col">{t("name")}</th>
            <th scope="col">{t("status")}</th>
            <th scope="col">{t("isDefault")}</th>
            <th scope="col">{t("dataTypesTopics")}</th>
            <th scope="col">{t("locale")}</th>
            <th scope="col">{t("lastUpdated")}</th>
            <th scope="col">{t("actions")}</th>
          </tr>
        </thead>
        <tbody>
          {displayedGuidanceGroups.length > 0 ? (
            displayedGuidanceGroups.map((group) => (
              <tr key={group.id}>
                <td>{group.name}</td>
                <td className={tablesStyles.table_row}>
                  {group.published ? t("published") : t("unpublished")}
                </td>
                <td className={tablesStyles.table_row}>
                  {group.is_default ? t("yes") : t("no")}
                </td>
                <td className={tablesStyles.table_row}>
                  {`${group.data_types.join(", ")} / ${group.topics.join(", ")}`}
                </td>
                <td className={tablesStyles.table_row}>{group.locale}</td>
                <td className={tablesStyles.table_row}>{group.last_updated}</td>
                <td className={tablesStyles.table_row}>
                  <Dropdown>
                    <Dropdown.Toggle
                      id={`guidance_group-${group.id}-actions`}
                      className={tablesStyles.dropdown_button}
                    >
                      {t("actions")}
                    </Dropdown.Toggle>

                    <Dropdown.Menu className={tablesStyles.dropdown_menu}>
                      <Dropdown.Item
                        as="button"
                        onClick={() => handleEdit(group.id)}
                      >
                        {t("edit")}
                      </Dropdown.Item>
                      <Dropdown.Item
                        as="button"
                        onClick={() =>
                          handlePublication(group.id, group.published)
                        }
                      >
                        {group.published ? t("unpublish") : t("publish")}
                      </Dropdown.Item>
                      <Dropdown.Item
                        as="button"
                        onClick={() => handleDelete(group.id)}
                      >
                        {t("delete")}
                      </Dropdown.Item>
                    </Dropdown.Menu>
                  </Dropdown>
                </td>
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
      </Table>

      {guidanceGroups.length > 0 && (
        <div className="row text-right">
          <div className="mx-auto">
            <Pagination
              key={guidanceGroups}
              items={guidanceGroups}
              onChangePage={onChangePage}
              pageSize={pageSize}
            />
          </div>
        </div>
      )}
    </>
  );
}

export default GuidanceGroupList;
