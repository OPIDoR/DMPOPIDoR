import { useEffect, useMemo, useState } from "react";
import toast from "react-hot-toast";
import { Controller, FormProvider, useForm, useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { useLocation, useNavigate, useParams } from "react-router";

import * as styles from "../../assets/css/form.module.css";

import CustomSpinner from "../../Shared/CustomSpinner";
import Forms from "../../context/FormsContext";
import CustomButton from "../../Styled/CustomButton";
import { getErrorMessage } from "../../../utils/utils";
import CustomSelect from "../../Shared/CustomSelect";
import { createSelectOptions } from "../../../utils/JsonFragmentsUtils";
import { guidancesManagement } from "../../../services";
import InputText from "../../FormComponents/InputText";
import TinyArea from "../../FormComponents/TinyArea";
import Checkbox from "../../FormComponents/Checkbox";
import RadioGroup from "../../FormComponents/RadioGroup";

function GuidanceForm() {
  const params = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  const { t } = useTranslation();
  const methods = useForm({ defaultValues: { published: false } });

  const [loading, setLoading] = useState(false);
  const [availableGuidanceGroups, setAvailableGuidanceGroups] = useState(
    location?.state?.guidanceGroups || [],
  );
  const [availableThemes, setAvailableThemes] = useState([]);
  const isEditing = Boolean(params.id);

  const guidanceGroupId = useWatch({
    control: methods.control,
    name: "guidance_group_id",
  });
  /**
   * Memoized values
   */
  const guidanceGroupsOptions = useMemo(
    () =>
      availableGuidanceGroups?.length > 0
        ? createSelectOptions(availableGuidanceGroups)
        : [],
    [availableGuidanceGroups],
  );

  const selectedGuidanceGroupOption = useMemo(() => {
    if (guidanceGroupId) {
      const selectedOption = guidanceGroupsOptions.find(
        (option) => option.value === guidanceGroupId,
      );
      return selectedOption || null;
    }
    return null;
  }, [guidanceGroupId, guidanceGroupsOptions]);

  const handleError = (error) => toast.error(getErrorMessage(error));

  const handleSaveForm = async (data) => {
    setLoading(true);
    const guidanceData = { ...data, theme_ids: [data.theme_id] };
    let response;
    try {
      if (isEditing) {
        response = await guidancesManagement.saveGuidance(
          params.id,
          guidanceData,
        );
      } else {
        response = await guidancesManagement.createGuidance(guidanceData);
      }
    } catch (error) {
      handleError(error);
      return setLoading(false);
    }
    toast.success(t("saveSuccess"));
    setLoading(false);
    navigate(
      `/administration/guidances_management/guidances/${response.data.id}/edit`,
      { replace: true },
    );
  };

  /**
   * USE EFFECTS
   */
  useEffect(() => {
    if (!location.state?.guidanceGroups) {
      guidancesManagement
        .getGuidanceGroupsData()
        .then((res) => {
          setAvailableGuidanceGroups(
            res.data?.guidance_groups.map((gg) => ({
              ...gg,
              label: gg.name,
            })),
          );
        })
        .catch((error) => {
          console.error(error);
        })
        .finally(() => {
          setLoading(false);
        });
    }
  }, [location]);

  useEffect(() => {
    if (!location.state?.guidanceGroup) {
      const handleGetGuidanceData = isEditing
        ? guidancesManagement.getGuidanceData(params.id)
        : guidancesManagement.getNewGuidanceData();

      handleGetGuidanceData
        .then((res) => {
          methods.reset(res.data);
        })
        .catch((error) => handleError(error))
        .finally(() => setLoading(false));
    } else {
      methods.reset(location.state.guidanceGroup);
    }
  }, [params.id, location]);

  useEffect(() => {
    if (!selectedGuidanceGroupOption) return;

    const {
      data_types,
      language,
      language_abbreviation: locale,
    } = selectedGuidanceGroupOption.object;
    methods.setValues({ locale: locale, language });
    guidancesManagement
      .getThemes(locale, data_types)
      .then((res) => {
        setAvailableThemes(res.data?.themes);
      })
      .catch((error) => handleError(error))
      .finally(() => setLoading(false));
  }, [selectedGuidanceGroupOption]);

  return (
    <>
      {loading && <CustomSpinner isOverlay={true} />}
      <Forms>
        <h1>{isEditing ? "Edit Guidance" : "Create Guidance"}</h1>
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
            <div className="form-group">
              <div className={styles.label_form}>
                <label
                  htmlFor={"guidance_guidance_group"}
                  data-testid="guidance-guidance-group-label"
                >
                  {t("guidanceGroup")}
                </label>
              </div>
              <Controller
                render={({ field }) => (
                  <CustomSelect
                    inputId={"guidance_guidance_group"}
                    propName={"guidance_group_id"}
                    onSelectChange={(e) => {
                      if (!e)
                        return {
                          target: { name: "guidance_group_id", value: 0 },
                        };
                      return field.onChange(e.value);
                    }}
                    options={guidanceGroupsOptions}
                    selectedOption={selectedGuidanceGroupOption}
                  />
                )}
                name="guidance_group_id"
                control={methods.control}
              />
            </div>
            <InputText
              key="locale"
              readonly={true}
              propName={"locale"}
              hidden={true}
            />
            <InputText
              key="language"
              label={t("locale")}
              readonly={true}
              propName={"language"}
            />
            <TinyArea
              key="text"
              label={t("text")}
              placeholder={null}
              propName="text"
              tooltip={t("guidanceTextTooltip")}
              readonly={false}
            />
            <RadioGroup
              label={t("themes")}
              items={availableThemes}
              propName={"theme_id"}
              tooltip={t("themesTooltip")}
              hidden={false}
              readonly={false}
            />
            <Checkbox
              key="published"
              label={t("published")}
              propName="published"
              hidden={false}
              readonly={false}
            />
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

export default GuidanceForm;
