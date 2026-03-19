const INSIGHT_EVENTS = [
  {
    id: "portland-2026-04-16",
    title: "Insight Portland Student Mixer",
    date: "2026-04-16",
    region: "Portland",
    nearbyUniversities: "Portland State, U of Oregon, Oregon State",
    courseAlignment: "Marketing Research, Consumer Behavior",
    rewardXp: 120,
    rewardCoins: 35
  },
  {
    id: "sandiego-2026-05-14",
    title: "Insight San Diego Analytics Night",
    date: "2026-05-14",
    region: "San Diego",
    nearbyUniversities: "SDSU, USD, UC San Diego",
    courseAlignment: "Analytics capstones, project presentations",
    rewardXp: 140,
    rewardCoins: 40
  },
  {
    id: "losangeles-2026-06-18",
    title: "Insight Los Angeles Summer Launch",
    date: "2026-06-18",
    region: "Los Angeles",
    nearbyUniversities: "UCLA, USC, Cal Poly Pomona, LMU",
    courseAlignment: "Summer intensives, boot camps",
    rewardXp: 180,
    rewardCoins: 50
  },
  {
    id: "sanfrancisco-2026-07-23",
    title: "Insight Bay Area Innovation Session",
    date: "2026-07-23",
    region: "San Francisco",
    nearbyUniversities: "USF, SFSU, Berkeley Haas, Santa Clara",
    courseAlignment: "Executive education, certificate programs",
    rewardXp: 160,
    rewardCoins: 45
  },
  {
    id: "seattle-2026-08-20",
    title: "Insight Seattle Welcome Week",
    date: "2026-08-20",
    region: "Seattle",
    nearbyUniversities: "UW Foster, Seattle U, WSU",
    courseAlignment: "New student orientations, welcome week",
    rewardXp: 125,
    rewardCoins: 35
  },
  {
    id: "ventura-2026-09-10",
    title: "Insight Ventura Student Kickoff",
    date: "2026-09-10",
    region: "Ventura / Thousand Oaks",
    nearbyUniversities: "CLU, CSUCI",
    courseAlignment: "Intro courses, widest-net outreach",
    rewardXp: 120,
    rewardCoins: 35
  },
  {
    id: "oclb-2026-10-15",
    title: "Insight Orange County Midterm Forum",
    date: "2026-10-15",
    region: "Orange County / Long Beach",
    nearbyUniversities: "CSULB, Chapman, UCI, CSUF",
    courseAlignment: "Mid-term guest lecture sweet spot",
    rewardXp: 150,
    rewardCoins: 45
  },
  {
    id: "seattle-2026-12-03",
    title: "Insight Seattle Career Panel",
    date: "2026-12-03",
    region: "Seattle",
    nearbyUniversities: "UW, Seattle U",
    courseAlignment: "Capstone presentations, career panels",
    rewardXp: 135,
    rewardCoins: 40
  },
  {
    id: "losangeles-2026-12-10",
    title: "Insight Los Angeles Career Next Session",
    date: "2026-12-10",
    region: "Los Angeles",
    nearbyUniversities: "UCLA, USC, CPP, LMU",
    courseAlignment: "Last week of classes, career-focused sessions",
    rewardXp: 145,
    rewardCoins: 45
  }
];

const INSIGHT_LEADERBOARD = [
  { email: "jordan.rivera@gmail.com", name: "Jordan Rivera", points: 1280 },
  { email: "skylar.choi@campus.edu", name: "Skylar Choi", points: 1120 },
  { email: "marcus.reed@campus.edu", name: "Marcus Reed", points: 980 },
  { email: "alina.singh@campus.edu", name: "Alina Singh", points: 860 }
];

const FARM_MILESTONES = [
  {
    threshold: 0,
    tier: "Starter Plot",
    landLabel: "1 meadow plot",
    items: ["Seed pouch", "Wood fence", "Welcome sign"],
    animals: ["Chick"],
    nextUnlock: "Water trough"
  },
  {
    threshold: 300,
    tier: "Sprout Farm",
    landLabel: "2 meadow plots",
    items: ["Water trough", "Berry patch", "Compost bin"],
    animals: ["Chicken", "Duck"],
    nextUnlock: "Windmill"
  },
  {
    threshold: 650,
    tier: "Harvest Farm",
    landLabel: "4 meadow plots",
    items: ["Windmill", "Market cart", "Fruit tree"],
    animals: ["Goat", "Sheep"],
    nextUnlock: "Red barn"
  },
  {
    threshold: 1000,
    tier: "Show Barn",
    landLabel: "6 meadow plots",
    items: ["Red barn", "Lantern path", "Irrigation pump"],
    animals: ["Cow", "Piglet"],
    nextUnlock: "Golden silo"
  },
  {
    threshold: 1400,
    tier: "Champion Ranch",
    landLabel: "8 meadow plots",
    items: ["Golden silo", "Orchard gate", "Festival pen"],
    animals: ["Mini horse", "Highland calf"],
    nextUnlock: "Maxed ranch"
  }
];

function getTodayIsoDate() {
  return new Date().toISOString().slice(0, 10);
}

function getTodayEvents() {
  const today = getTodayIsoDate();
  return INSIGHT_EVENTS.filter((event) => event.date === today);
}

function getUpcomingEvents(limit = 4) {
  const today = getTodayIsoDate();
  return INSIGHT_EVENTS
    .filter((event) => event.date >= today)
    .sort((a, b) => a.date.localeCompare(b.date))
    .slice(0, limit);
}

function getLeaderboard() {
  return [...INSIGHT_LEADERBOARD].sort((a, b) => b.points - a.points);
}

function getFarmProgress(points) {
  let current = FARM_MILESTONES[0];
  let next = null;

  FARM_MILESTONES.forEach((milestone, index) => {
    if (points >= milestone.threshold) {
      current = milestone;
      next = FARM_MILESTONES[index + 1] || null;
    }
  });

  const previousThreshold = current.threshold;
  const nextThreshold = next ? next.threshold : current.threshold;
  const progress = next
    ? Math.min(1, (points - previousThreshold) / (nextThreshold - previousThreshold))
    : 1;

  return {
    ...current,
    progress,
    nextThreshold,
    pointsToNext: next ? Math.max(0, next.threshold - points) : 0
  };
}

function getPlayerProfile(email) {
  const normalizedEmail = (email || "").toLowerCase();
  const leaderboard = getLeaderboard();
  const existing = leaderboard.find((player) => player.email.toLowerCase() === normalizedEmail);
  const points = existing ? existing.points : 180;
  const rank = existing ? leaderboard.findIndex((player) => player.email.toLowerCase() === normalizedEmail) + 1 : leaderboard.length + 1;
  const name = existing ? existing.name : "New Farmer";

  return {
    email,
    name,
    points,
    rank,
    farm: getFarmProgress(points)
  };
}
