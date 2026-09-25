import { useTranslation } from "react-i18next";
import Dropdown from "react-bootstrap/Dropdown";

import * as tablesStyles from "../../assets/css/tables.module.css";
import SortableTable from "../../Shared/SortableTable";

function GuidanceGroupList({
  guidanceGroups = [],
  handleEdit,
  handleDelete,
  handlePublication,
}) {
  const { t } = useTranslation();

  const columns = [
    { key: "name", label: t("name") },
    {
      key: "status",
      label: t("status"),
      sortable: true,
      render: (group) => (group.published ? t("published") : t("unpublished")),
    },
    {
      key: "is_default",
      label: t("isDefault"),
      sortable: true,
      render: (group) => (group.is_default ? t("yes") : t("no")),
    },
    {
      key: "dataTypesTopics",
      label: t("dataTypesTopics"),
      render: (group) =>
        `${group.data_types.join(", ")} / ${group.topics.join(", ")}`,
    },
    { key: "language", label: t("locale"), sortable: true },
    { key: "last_updated", label: t("lastUpdated"), sortable: true },
    {
      key: "actions",
      label: t("actions"),
      render: (group) => {
        if (!group) return null;
        return (
          <Dropdown>
            <Dropdown.Toggle
              id={`guidance_group-${group.id}-actions`}
              className={tablesStyles.dropdown_button}
            >
              {t("actions")}
            </Dropdown.Toggle>

            <Dropdown.Menu className={tablesStyles.dropdown_menu}>
              <Dropdown.Item as="button" onClick={() => handleEdit(group.id)}>
                {t("edit")}
              </Dropdown.Item>
              <Dropdown.Item
                as="button"
                onClick={() => handlePublication(group.id, group.published)}
              >
                {group.published ? t("unpublish") : t("publish")}
              </Dropdown.Item>
              <Dropdown.Item as="button" onClick={() => handleDelete(group.id)}>
                {t("delete")}
              </Dropdown.Item>
            </Dropdown.Menu>
          </Dropdown>
        );
      },
    },
  ];

  /**
   * RENDERING
   */

  return (
    <SortableTable
      columns={columns}
      data={guidanceGroups}
      tableProps={{ hover: true, striped: true }}
    />
  );
}

export default GuidanceGroupList;
