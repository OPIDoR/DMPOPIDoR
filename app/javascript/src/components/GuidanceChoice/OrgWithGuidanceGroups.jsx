import * as guidanceChoiceStyles from "../assets/css/guidance_choice.module.css";
import GuidanceGroupItem from "./GuidanceGroupItem";

function OrgWithGuidanceGroups({
  org,
  isLimitReached,
  shouldGuidanceGroupDisplay,
  getStatus = null,
  onSelect,
}) {
  const guidanceGroups = org.guidance_groups.filter((group) =>
    shouldGuidanceGroupDisplay(group),
  );
  if (guidanceGroups.length === 0) {
    return null;
  }

  return (
    <div
      data-testid={`org-section-${org.id}`}
      key={`org-section-${org.id}`}
      style={{ paddingBottom: "5px" }}
    >
      <div
        style={{ display: "flex", flexDirection: "column" }}
        key={`org-container-${org.id}`}
      >
        <div
          style={{ display: "flex", alignItems: "center" }}
          key={`org-container-${org.id}`}
        >
          <label
            data-testid={`org-${org.id}-label`}
            className={`${guidanceChoiceStyles.label}`}
            style={{ cursor: isLimitReached ? "not-allowed" : "pointer" }}
            onClick={() =>
              isLimitReached
                ? null
                : onSelect(guidanceGroups.map((group) => group.id))
            }
            key={`org-${org.id}-label`}
          >
            {org.name}
          </label>
        </div>
        <div
          data-testid={`org-${org.id}-childs`}
          style={{
            display: "flex",
            flexDirection: "column",
            marginLeft: "26px",
          }}
          key={`org-${org.id}-childs`}
        >
          {guidanceGroups.map((guidance_group, key) => (
            <GuidanceGroupItem
              key={key}
              guidance_group_id={guidance_group.id}
              guidance_group_name={guidance_group.name}
              guidance_group_description={guidance_group.description}
              level={2}
              org={org}
              isLimitReached={isLimitReached}
              status={getStatus ? getStatus(guidance_group.id) : "available"}
              onSelect={onSelect}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

export default OrgWithGuidanceGroups;
