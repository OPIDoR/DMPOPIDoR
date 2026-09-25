import "dayjs/locale/en-gb";
import "dayjs/locale/fr";
import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";

import getConstant from "./constants";

dayjs.extend(relativeTime);

export const TimeAgo = {
  render(elements) {
    Array.from(elements).forEach((el) => {
      const currentLocale =
        getConstant("CURRENT_LOCALE").substring(0, 2) ||
        getConstant("DEFAULT_LOCALE").substring(0, 2) ||
        "en";
      dayjs.locale(currentLocale);
      $(el).html(dayjs(el.getAttribute("datetime")).fromNow());
    });
  },
};

export default TimeAgo;
