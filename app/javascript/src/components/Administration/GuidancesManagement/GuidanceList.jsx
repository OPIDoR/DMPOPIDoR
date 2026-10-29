import DOMPurify from "dompurify";
import { useTranslation } from "react-i18next";
import Dropdown from "react-bootstrap/Dropdown";

import * as tablesStyles from "../../assets/css/tables.module.css";
import SortableTable from "../../Shared/SortableTable";

function GuidanceList({
  guidances = [],
  handleEdit,
  handleDelete,
  handlePublication,
}) {
  const { t } = useTranslation();
  const columns = [
    {
      key: "text",
      label: t("text"),
      sortable: true,
      render: (guidance) => (
        <span
          dangerouslySetInnerHTML={{
            __html: DOMPurify.sanitize(guidance.text),
          }}
        />
      ),
    },
    {
      key: "themes",
      label: t("themes"),
      render: (guidance) =>
        guidance.themes.map((theme) => theme.title).join(", "),
    },
    { key: "guidance_group", label: t("guidanceGroup"), sortable: true },
    {
      key: "status",
      label: t("status"),
      sortable: true,
      render: (guidance) =>
        guidance.published ? t("published") : t("unpublished"),
    },
    { key: "language", label: t("locale"), sortable: true },
    { key: "last_updated", label: t("lastUpdated"), sortable: true },
    {
      key: "actions",
      label: t("actions"),
      render: (guidance) => {
        if (!guidance) return null;
        return (
          <Dropdown>
            <Dropdown.Toggle
              id={`guidance_group-${guidance.id}-actions`}
              className={tablesStyles.dropdown_button}
            >
              {t("actions")}
            </Dropdown.Toggle>

            <Dropdown.Menu className={tablesStyles.dropdown_menu}>
              <Dropdown.Item
                as="button"
                onClick={() => handleEdit(guidance.id)}
                className={tablesStyles.dropdown_item}
              >
                {t("edit")}
              </Dropdown.Item>
              <Dropdown.Item
                as="button"
                onClick={() =>
                  handlePublication(guidance.id, guidance.published)
                }
                className={tablesStyles.dropdown_item}
              >
                {guidance.published ? t("unpublish") : t("publish")}
              </Dropdown.Item>
              <Dropdown.Item
                as="button"
                onClick={() => handleDelete(guidance.id)}
                className={tablesStyles.dropdown_item}
              >
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
      data={guidances}
      tableProps={{ hover: true, striped: true }}
    />
  );
}

export default GuidanceList;
