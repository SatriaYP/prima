function togglePasswordVisibility(inputRef, iconRef) {
  if (!inputRef?.value || !iconRef?.value) return;

  const input = inputRef.value;
  const icon = iconRef.value;

  const isPassword = input.type === "password";
  input.type = isPassword ? "text" : "password";

  icon.classList.toggle("fa-eye");
  icon.classList.toggle("fa-eye-slash");
}

module.exports = {
  togglePasswordVisibility,
};
