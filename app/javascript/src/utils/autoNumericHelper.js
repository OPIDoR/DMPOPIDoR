import AutoNumeric from "autonumeric";

export const AutoNumericHelper = {
  init(classname) {
    if ($(classname).length > 0) {
      new AutoNumeric(classname, {
        digitGroupSeparator: " ",
        decimalPlaces: "0",
        overrideMinMaxLimits: "invalid",
      });
    }
  },
};

export default AutoNumericHelper;
