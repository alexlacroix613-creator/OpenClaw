export type MemoryCandidate = {
  kind: "episodic" | "semantic" | "affective" | "relationship" | "reflective";
  importance: number;
  summary: string;
  store: boolean;
};

export function shouldStoreMemory(candidate: MemoryCandidate) {
  if (!candidate.store) return false;
  if (candidate.importance < 0.45) return false;
  if (candidate.summary.trim().length < 8) return false;
  return true;
}
