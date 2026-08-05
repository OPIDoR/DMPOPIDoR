import DOMPurify from "dompurify";
import { useTranslation } from "react-i18next";
import Dropdown from "react-bootstrap/Dropdown";
import DropdownButton from "react-bootstrap/DropdownButton";

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
      render: (text) => (
        <span dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(text) }} />
      ),
    },
    {
      key: "themes",
      label: t("themes"),
      render: (themes) => themes.map((theme) => theme.title).join(", "),
    },
    { key: "guidance_group", label: t("guidanceGroup") },
    {
      key: "status",
      label: t("status"),
      render: (status) => (status ? t("published") : t("unpublished")),
    },
    { key: "language", label: t("locale") },
    { key: "last_updated", label: t("lastUpdated"), sortable: true },
    {
      key: "actions",
      label: t("actions"),
      render: (guidance) => {
        if (!guidance) return null;
        return (
          <DropdownButton
            id={`guidance_group-${guidance.id}-actions`}
            className={tablesStyles.dropdown_button}
            title={t("actions")}
          >
            <Dropdown.Item as="button" onClick={() => handleEdit(guidance.id)}>
              {t("edit")}
            </Dropdown.Item>
            <Dropdown.Item
              as="button"
              onClick={() => handlePublication(guidance.id, guidance.published)}
            >
              {guidance.published ? t("unpublish") : t("publish")}
            </Dropdown.Item>
            <Dropdown.Item
              as="button"
              onClick={() => handleDelete(guidance.id)}
            >
              {t("delete")}
            </Dropdown.Item>
          </DropdownButton>
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
