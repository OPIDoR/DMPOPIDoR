import { Tooltip as ReactTooltip } from "react-tooltip";
import { useTranslation } from "react-i18next";
import { FaPenToSquare, FaXmark } from "react-icons/fa6";

import { parsePattern } from "../../utils/GeneratorUtils";
import { isValidHttpUrl } from "../../utils/utils";
import * as styles from "../assets/css/form.module.css";
import SortableTable from "../Shared/SortableTable";

function ContributorsList({
  contributors,
  template,
  handleEdit,
  handleDelete,
  readonly = false,
}) {
  const { t } = useTranslation();

  const columns = [
    {
      key: "name",
      label: t("name"),
      sortable: true,
      render: (contributor) => (
        <>
          {parsePattern(contributor.data, template?.schema?.to_string)}
          {contributor.data?.personId &&
            (isValidHttpUrl(contributor.data?.personId)
              ? [
                  " - ",
                  <a
                    key={contributor.id}
                    href={contributor.data?.personId}
                    target="_blank"
                    rel="noreferrer"
                  >
                    {contributor.data?.personId}
                  </a>,
                ]
              : ` - ${contributor.data?.personId}`)}
        </>
      ),
    },
    {
      key: "affiliation",
      label: t("affiliation"),
      sortable: true,
      render: (contributor) => (
        <>
          {contributor.data?.affiliationName}
          {contributor.data?.affiliationId &&
            (isValidHttpUrl(contributor.data?.affiliationId)
              ? [
                  " - ",
                  <a
                    key={contributor.id}
                    href={contributor.data?.affiliationId}
                    target="_blank"
                    rel="noreferrer"
                  >
                    {contributor.data?.affiliationId}
                  </a>,
                ]
              : ` - ${contributor.data?.affiliationId}`)}
        </>
      ),
    },
    {
      key: "attributedRoles",
      label: t("attributedRoles"),
      render: (contributor) => (
        <ul>
          {contributor.roles.map((role, ridx) => (
            <li key={`${contributor.id}_${ridx}`}>{role}</li>
          ))}
        </ul>
      ),
    },
    {
      key: "actions",
      label: t("actions"),
      render: (contributor) => (
        <>
          {!readonly && (
            <>
              <ReactTooltip
                id="contributor-edit-button"
                place="bottom"
                effect="solid"
                variant="info"
                content={t("edit")}
              />
              <FaPenToSquare
                data-tooltip-id="contributor-edit-button"
                size={18}
                onClick={() => handleEdit(contributor)}
                className={styles.icon}
              />
              {contributors.length > 1 && (
                <>
                  <ReactTooltip
                    id="contributor-delete-button"
                    place="bottom"
                    effect="solid"
                    variant="info"
                    content={t("delete")}
                  />
                  <FaXmark
                    data-tooltip-id="contributor-delete-button"
                    size={18}
                    onClick={() => handleDelete(contributor)}
                    className={styles.icon}
                  />
                </>
              )}
            </>
          )}
        </>
      ),
    },
  ];

  return (
    <SortableTable
      columns={columns}
      data={contributors}
      tableProps={{ hover: true, striped: true }}
    />
  );
}

export default ContributorsList;
