export type PetSnapIntent = {
  userId: string;
  petId: string;
  reason: "new_outfit" | "learned_word" | "memory" | "mood" | "ar_invite";
  caption: string;
  stickerAssetUrl?: string;
  videoAssetUrl?: string;
  lensLaunchData?: Record<string, string>;
};

export async function createSnapSuggestion(intent: PetSnapIntent) {
  return {
    title: "Your pet made a Snap",
    caption: intent.caption,
    assets: {
      sticker: intent.stickerAssetUrl,
      video: intent.videoAssetUrl
    },
    lensLaunchData: intent.lensLaunchData,
    requiresUserApproval: true
  };
}
