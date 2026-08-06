import { useMemo, useState } from "react";
import { Table } from "react-bootstrap";
import Pagination from "./Pagination";
import { FaSort, FaSortUp, FaSortDown } from "react-icons/fa6";
import { useTranslation } from "react-i18next";
import CustomSpinner from "./CustomSpinner";

function SortableTable({
  columns = [],
  data = [],
  tableProps = {},
  pageSize = 10,
  loading = false,
}) {
  console.log("loading", loading);
  const { t } = useTranslation();
  const [displayedData, setDisplayedData] = useState([]);
  const [sortedColumn, setSortedColumn] = useState({
    key: null,
    direction: "asc",
  });

  const sortableColumns = useMemo(() => {
    return columns
      .filter((column) => column.sortable)
      .map((column) => column.key);
  }, [columns]);

  const onChangePage = (pageOfItems) => {
    setDisplayedData(pageOfItems);
  };

  const sortedColumnData = useMemo(() => {
    const cleanData = (displayedData ?? []).filter(Boolean);

    if (!sortedColumn.key) return cleanData;
    const sorted = [...cleanData].sort((a, b) => {
      const valA = a[sortedColumn.key];
      const valB = b[sortedColumn.key];

      if (typeof valA === "number" && typeof valB === "number") {
        return sortedColumn.direction === "asc" ? valA - valB : valB - valA;
      }
      return sortedColumn.direction === "asc"
        ? String(valA).localeCompare(String(valB))
        : String(valB).localeCompare(String(valA));
    });
    return sorted;
  }, [displayedData, sortedColumn, columns]);

  const handleSort = (key) => {
    if (!sortableColumns.includes(key)) return;
    setSortedColumn((prev) => {
      if (prev.key === key) {
        return { key, direction: prev.direction === "asc" ? "desc" : "asc" };
      }
      return { key, direction: "asc" };
    });
  };

  const renderSortIcon = (key) => {
    if (!sortableColumns.includes(key)) return null;
    if (sortedColumn.key !== key) return <FaSort />;
    return sortedColumn.direction === "asc" ? <FaSortUp /> : <FaSortDown />;
  };

  return (
    <div style={{ position: "relative" }}>
      {loading && <CustomSpinner isOverlay={true} />}
      <Table {...tableProps}>
        <thead>
          <tr>
            {columns.map((column) => (
              <th
                key={column.key}
                onClick={() => handleSort(column.key)}
                style={
                  column.sortable && { cursor: "pointer", userSelect: "none" }
                }
              >
                {column.label} {renderSortIcon(column.key)}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {sortedColumnData.length > 0 ? (
            sortedColumnData.map((row, rowIndex) => (
              <tr key={row.id ?? rowIndex}>
                {columns.map((column) =>
                  column.render ? (
                    <td key={column.key}>{column.render(row)}</td>
                  ) : (
                    <td key={column.key}>{row[column.key]}</td>
                  ),
                )}
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan={columns.length} style={{ textAlign: "center" }}>
                {t("noData")}
              </td>
            </tr>
          )}
        </tbody>
      </Table>

      {data.length > 0 && (
        <div className="row text-right">
          <div className="mx-auto">
            <Pagination
              key={data}
              items={data}
              onChangePage={onChangePage}
              pageSize={pageSize}
            />
          </div>
        </div>
      )}
    </div>
  );
}

export default SortableTable;
