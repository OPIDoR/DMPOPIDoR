import { useState } from "react";
import { useTranslation } from "react-i18next";
import Dropdown from "react-bootstrap/Dropdown";
import DropdownButton from "react-bootstrap/DropdownButton";
import Table from "react-bootstrap/Table";

import * as tablesStyles from "../../assets/css/tables.module.css";
import Pagination from "../../Shared/Pagination";

function GuidanceList({
  guidances = [],
  handleEdit,
  handleDelete,
  handlePublication,
}) {
  const { t } = useTranslation();
  const pageSize = 10;
  const [displayedGuidances, setDisplayedGuidances] = useState([]);

  const onChangePage = (pageOfItems) => {
    setDisplayedGuidances(pageOfItems);
  };

  /**
   * RENDERING
   */

  return (
    <>
      <Table hover striped>
        <thead>
          <tr>
            <th scope="col">{t("text")}</th>
            <th scope="col">{t("themes")}</th>
            <th scope="col">{t("guidanceGroup")}</th>
            <th scope="col">{t("status")}</th>
            <th scope="col">{t("locale")}</th>
            <th scope="col">{t("lastUpdated")}</th>
            <th scope="col">{t("actions")}</th>
          </tr>
        </thead>
        <tbody>
          {displayedGuidances.length > 0 ? (
            displayedGuidances.map((guidance) => (
              <tr key={guidance.id}>
                <td>{guidance.text}</td>
                <td className={tablesStyles.table_row}>
                  {guidance.themes.map((theme) => theme.title).join(", ")}
                </td>
                <td className={tablesStyles.table_row}>
                  {guidance.guidance_group}
                </td>
                <td className={tablesStyles.table_row}>
                  {guidance.published ? t("published") : t("unpublished")}
                </td>
                <td className={tablesStyles.table_row}>{guidance.locale}</td>
                <td className={tablesStyles.table_row}>
                  {guidance.last_updated}
                </td>
                <td className={tablesStyles.table_row}>
                  <DropdownButton
                    id={`guidance_group-${guidance.id}-actions`}
                    className={tablesStyles.dropdown_button}
                    title={t("actions")}
                  >
                    <Dropdown.Item as="button" onClick={handleEdit}>
                      {t("edit")}
                    </Dropdown.Item>
                    <Dropdown.Item as="button" onClick={handlePublication}>
                      {guidance.published ? t("unpublish") : t("publish")}
                    </Dropdown.Item>
                    <Dropdown.Item as="button" onClick={handleDelete}>
                      {t("delete")}
                    </Dropdown.Item>
                  </DropdownButton>
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

      {guidances.length > 0 && (
        <div className="row text-right">
          <div className="mx-auto">
            <Pagination
              key={guidances}
              items={guidances}
              onChangePage={onChangePage}
              pageSize={pageSize}
            />
          </div>
        </div>
      )}
    </>
  );
}

export default GuidanceList;
