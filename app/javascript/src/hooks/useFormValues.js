import { useCallback } from "react";

export function useFormValues(methods) {
  const setValues = useCallback(
    (data) =>
      Object.keys(data).forEach((k) =>
        methods.setValue(k, data[k], { shouldDirty: true }),
      ),
    [methods],
  );

  return { setValues };
}
