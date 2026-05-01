export type ScreenObservation = {
  appCategory?: string;
  ocrSummary?: string;
  visualSummary?: string;
  sensitive?: boolean;
};

const sensitivePatterns = [
  /password/i,
  /passcode/i,
  /credit card/i,
  /cvv/i,
  /sin\b/i,
  /ssn\b/i,
  /bank/i,
  /medical/i,
  /diagnosis/i
];

export function redactSensitiveContext(input: ScreenObservation): ScreenObservation {
  const text = `${input.appCategory ?? ""}\n${input.ocrSummary ?? ""}\n${input.visualSummary ?? ""}`;
  const sensitive = input.sensitive || sensitivePatterns.some(pattern => pattern.test(text));

  if (!sensitive) return input;

  return {
    appCategory: input.appCategory,
    ocrSummary: "[redacted sensitive screen context]",
    visualSummary: "[redacted sensitive visual context]",
    sensitive: true
  };
}
