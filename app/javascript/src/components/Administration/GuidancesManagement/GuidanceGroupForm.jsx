import { useEffect, useMemo, useState } from "react";
import { useParams } from "react-router";
import { useForm, FormProvider } from "react-hook-form";

import { guidancesManagement } from "../../../services";
import Forms from "../../context/FormsContext";
import InputText from "../../FormComponents/InputText";
import { useTranslation } from "react-i18next";
import TinyArea from "../../FormComponents/TinyArea";
import CustomSelect from "../../Shared/CustomSelect";
import { createSelectOptions } from "../../../utils/JsonFragmentsUtils";
import * as styles from "../../assets/css/form.module.css";

function GuidanceGroupForm() {
  const params = useParams();
  const { t } = useTranslation();
  const methods = useForm({ defaultValues: {} });
  const [guidanceGroupData, setGuidanceGroupData] = useState({});
  const isEditing = Boolean(params.id);

  let selectedOption = guidanceGroupData.language
    ? guidanceGroupData.language
    : { value: "", label: "" };

  /**
   * Memoized values
   */
  const languageOptions = useMemo(
    () =>
      guidanceGroupData?.available_languages?.length > 0
        ? createSelectOptions(guidanceGroupData.available_languages)
        : [{ value: "", label: "" }],
    [guidanceGroupData],
  );

  /**
   * USE EFFECTS
   */
  useEffect(() => {
    const handleGetGuidanceGroupData = isEditing
      ? guidancesManagement.getGuidanceGroupData(params.id)
      : guidancesManagement.getNewGuidanceGroupData();

    handleGetGuidanceGroupData.then((res) => {
      setGuidanceGroupData(res.data);
      methods.reset(res.data);
    });
  }, [params.id]);

  return (
    <Forms>
      <h1>{isEditing ? "Edit Guidance Group" : "Create Guidance Group"}</h1>
      <p>{JSON.stringify(guidanceGroupData)}</p>
      <FormProvider {...methods}>
        <form
          name="guidance-group-form"
          id="guidance-group-form"
          style={{ margin: "15px" }}
          onSubmit={() => {}}
        >
          <InputText
            key="name"
            label={t("name")}
            type="string"
            placeholder={null}
            propName="name"
            tooltip={t("guidanceGroupNameTooltip")}
            hidden={false}
            readonly={false}
          />
          <TinyArea
            key="description"
            label={t("description")}
            placeholder={null}
            propName="description"
            tooltip={t("guidanceGroupDescriptionTooltip")}
            readonly={false}
          />

          <div className="form-group">
            <div className={styles.label_form}>
              <label
                htmlFor={"guidance_group_language"}
                data-testid="guidance-group-language-label"
              >
                {t("locale")}
              </label>
            </div>
            <CustomSelect
              inputId={"guidance_group_language"}
              propName={"language_id"}
              onSelectChange={() => {}}
              options={languageOptions}
              selectedOption={selectedOption}
            />
          </div>
        </form>
      </FormProvider>
    </Forms>
  );
}

export default GuidanceGroupForm;
