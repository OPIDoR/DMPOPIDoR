import { isObject, isString } from "./isType";

let constants = {};
export default (key) => constants[key];
document.addEventListener("turbo:load", () => {
  // js-constants is defined in views/layouts/application.html.erb
  const target = $("#js-constants");
  if (isObject(target) && isString(target.val())) {
    constants = JSON.parse(target.val());
  }
});
