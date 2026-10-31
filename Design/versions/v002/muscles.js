/** Count planned sets for each catalog primary muscle, without estimating intensity. */
function summarizeWorkoutMuscles(workout, catalog) {
 const counts = new Map();
 const secondary = new Set();
 let missing = 0;
 for (const item of workout.items) {
  const exercise = catalog.find(candidate => candidate.name === item.name);
  if (!exercise) { missing++; continue; }
  const primary = exercise.primaryMuscles?.length ? exercise.primaryMuscles : [exercise.primaryMuscle];
  const sets = Number.isSafeInteger(item.sets) && item.sets > 0 ? item.sets : 0;
  for (const muscle of new Set(primary.filter(Boolean))) {
   counts.set(muscle, (counts.get(muscle) ?? 0) + sets);
  }
  for (const muscle of exercise.secondaryMuscles ?? []) secondary.add(muscle);
 }
 const ranked = [...counts].filter(([, sets]) => sets > 0)
  .map(([muscle, sets]) => ({ muscle, sets }))
  .sort((a, b) => b.sets - a.sets || a.muscle.localeCompare(b.muscle, 'en'));
 return {
  ranked,
  secondary: [...secondary].filter(muscle => !counts.has(muscle)),
  missing,
  totalSets: workout.items.reduce((total, item) => total + (Number.isSafeInteger(item.sets) && item.sets > 0 ? item.sets : 0), 0)
 };
}
