import { useContext, useEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import { useNavigate, useParams } from "react-router";
import { useForm, FormProvider, Controller, useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";

import * as styles from "../../assets/css/form.module.css";

import { guidancesManagement } from "../../../services";
import Forms from "../../context/FormsContext";
import InputText from "../../FormComponents/InputText";
import CustomButton from "../../Styled/CustomButton";
import TinyArea from "../../FormComponents/TinyArea";
import CustomSelect from "../../Shared/CustomSelect";
import { createSelectOptions } from "../../../utils/JsonFragmentsUtils";
import SelectMultipleString from "../../FormComponents/registries/SelectMultipleString";
import Checkbox from "../../FormComponents/Checkbox";
import { GlobalContext } from "../../context/GlobalContext";
import { getErrorMessage } from "../../../utils/utils";
import CustomSpinner from "../../Shared/CustomSpinner";

function GuidanceGroupForm() {
  const { isUserSuperAdmin } = useContext(GlobalContext);
  const params = useParams();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const methods = useForm({ defaultValues: {} });
  const [loading, setLoading] = useState(true);
  const [availableLanguages, setAvailableLanguages] = useState([]);
  const isEditing = Boolean(params.id);

  const languageId = useWatch({
    control: methods.control,
    name: "language_id",
  });
  /**
   * Memoized values
   */
  const languageOptions = useMemo(
    () =>
      availableLanguages?.length > 0
        ? createSelectOptions(availableLanguages)
        : [],
    [availableLanguages],
  );

  const selectedLanguageOption = useMemo(() => {
    if (languageId) {
      const selectedOption = languageOptions.find(
        (option) => option.value === languageId,
      );
      return selectedOption || null;
    }
    return null;
  }, [languageId, languageOptions]);

  const handleError = (error) => toast.error(getErrorMessage(error));

  const handleSaveForm = async (data) => {
    setLoading(true);
    let response;
    try {
      if (isEditing) {
        response = await guidancesManagement.saveGuidanceGroup(params.id, data);
      } else {
        response = await guidancesManagement.createGuidanceGroup(data);
      }
    } catch (error) {
      handleError(error);
      return setLoading(false);
    }
    toast.success(t("saveSuccess"));
    setLoading(false);
    navigate(
      `/administration/guidances_management/guidance_groups/${response.data.id}/edit`,
      { replace: true },
    );
  };

  /**
   * USE EFFECTS
   */
  useEffect(() => {
    const handleGetGuidanceGroupData = isEditing
      ? guidancesManagement.getGuidanceGroupData(params.id)
      : guidancesManagement.getNewGuidanceGroupData();

    handleGetGuidanceGroupData
      .then((res) => {
        methods.reset(res.data);
      })
      .catch((error) => handleError(error))
      .finally(() => setLoading(false));
  }, [params.id]);

  useEffect(() => {
    guidancesManagement
      .getLanguages()
      .then((res) => {
        setAvailableLanguages(
          res?.data?.map((language) => ({
            id: language.id,
            label: language.name,
            abbreviation: language.abbreviation,
          })),
        );
      })
      .catch((error) => handleError(error))
      .finally(() => setLoading(false));
  }, []);

  return (
    <>
      {loading && <CustomSpinner isOverlay={true} />}
      <Forms>
        <h1>{isEditing ? "Edit Guidance Group" : "Create Guidance Group"}</h1>
        <CustomButton
          handleClick={() => navigate("/administration/guidances_management")}
          title={t("seeAllGuidances")}
          position="end"
        >
          {t("seeAllGuidances")}
        </CustomButton>
        <FormProvider {...methods}>
          <form
            name="guidance-group-form"
            id="guidance-group-form"
            style={{ margin: "15px" }}
            onSubmit={methods.handleSubmit((data) => handleSaveForm(data))}
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
              <Controller
                render={({ field }) => (
                  <CustomSelect
                    inputId={"guidance_group_language"}
                    propName={"language_id"}
                    onSelectChange={(e) => {
                      if (!e)
                        return { target: { name: "language_id", value: 0 } };
                      return field.onChange(e.value);
                    }}
                    options={languageOptions}
                    selectedOption={selectedLanguageOption}
                  />
                )}
                name="language_id"
                control={methods.control}
              />
            </div>

            <SelectMultipleString
              key="topics"
              label={t("topics")}
              registries={["Topics"]}
              placeholder={null}
              propName="topics"
              readonly={false}
            />

            <SelectMultipleString
              key="questionnaires"
              label={t("questionnaires")}
              registries={["Questionnaires"]}
              placeholder={null}
              propName="data_types"
              readonly={false}
            />

            <Checkbox
              key="published"
              label={t("published")}
              propName="published"
              tooltip={t("guidanceGroupPublishedTooltip")}
              hidden={false}
              readonly={false}
            />
            {isUserSuperAdmin && (
              <Checkbox
                key="isDefault"
                label={t("isDefault")}
                propName="is_default"
                hidden={false}
                readonly={false}
              />
            )}

            <CustomButton
              handleClick={null}
              title={t("save")}
              buttonType="submit"
              position="center"
              sticky={true}
            />
          </form>
        </FormProvider>
      </Forms>
    </>
  );
}

export default GuidanceGroupForm;
