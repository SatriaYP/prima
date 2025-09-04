import { inject } from "vue";

export const useAlert = () => {
  const alertRef = inject("alert");
  if (!alertRef) throw new Error("Alert not provided");

  return {
    showAlert: (msg, type = "success") => {
      alertRef.value?.showAlert(msg, type);
    },
  };
};
