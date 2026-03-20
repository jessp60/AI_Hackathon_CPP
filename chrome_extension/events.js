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

const FARM_STAGES = [
  { threshold: 0, label: "Tiny Pony", xp: 0 },
  { threshold: 500, label: "Pony", xp: 500 },
  { threshold: 1500, label: "Young Bronco", xp: 1500 },
  { threshold: 3000, label: "Adult Bronco", xp: 3000 },
  { threshold: 5000, label: "Champion Bronco", xp: 5000 }
];

const ACCESSORY_UNLOCKS = [
  { threshold: 250, label: "Bandana" },
  { threshold: 700, label: "Trail Saddle" },
  { threshold: 1400, label: "Bronco Ribbon" },
  { threshold: 2200, label: "Lucky Horseshoes" },
  { threshold: 3200, label: "Champion Blanket" },
  { threshold: 4500, label: "Gold Bridle" }
];

function hashString(value) {
  let hash = 0;
  for (let index = 0; index < value.length; index += 1) {
    hash = (hash * 31 + value.charCodeAt(index)) & 0x7fffffff;
  }
  return hash;
}

function displayNameFromEmail(email) {
  const prefix = (email || "new.farmer").split("@")[0];
  return prefix
    .split(/[._-]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ") || "New Farmer";
}

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

function getLeaderboard(currentEmail = "") {
  const board = [...INSIGHT_LEADERBOARD];
  if (currentEmail) {
    const current = getPlayerProfile(currentEmail);
    if (!board.some((player) => player.email.toLowerCase() === currentEmail.toLowerCase())) {
      board.push({
        email: current.email,
        name: current.name,
        points: current.points
      });
    }
  }
  return board.sort((a, b) => b.points - a.points);
}

function getFarmProgress(points) {
  let current = FARM_STAGES[0];
  let next = null;

  FARM_STAGES.forEach((stage, index) => {
    if (points >= stage.threshold) {
      current = stage;
      next = FARM_STAGES[index + 1] || null;
    }
  });

  const previousThreshold = current.threshold;
  const nextThreshold = next ? next.threshold : 7000;
  const progress = next
    ? Math.min(1, (points - previousThreshold) / (nextThreshold - previousThreshold))
    : 1;
  const accessories = ACCESSORY_UNLOCKS
    .filter((item) => points >= item.threshold)
    .map((item) => item.label);
  const horseCount = points >= 4800 ? 4 : points >= 3200 ? 3 : points >= 1800 ? 2 : 1;
  const animals = Array.from({ length: horseCount }, (_, index) =>
    index === 0 ? "Thunder" : `Bronco ${index + 1}`
  );

  return {
    tier: current.label,
    stageNumber: FARM_STAGES.findIndex((stage) => stage.threshold === current.threshold) + 1,
    stageName: current.label,
    progress,
    nextThreshold,
    pointsToNext: next ? Math.max(0, next.threshold - points) : 0,
    nextUnlock: next ? next.label : "Champion status",
    nextStageLabel: next ? next.label : current.label,
    landLabel: `${horseCount} bronco paddock${horseCount > 1 ? "s" : ""}`,
    items: accessories,
    animals
  };
}

function getPlayerProfile(email) {
  const normalizedEmail = (email || "").toLowerCase();
  const baseIdentity = normalizedEmail || "guest@broncoboost.app";
  const seed = hashString(baseIdentity);
  const points = 900 + (seed % 4200);
  const leaderboard = getLeaderboard();
  const simulatedBoard = [...leaderboard, { email: baseIdentity, name: displayNameFromEmail(baseIdentity), points }]
    .sort((a, b) => b.points - a.points);
  const rank = simulatedBoard.findIndex((player) => player.email.toLowerCase() === baseIdentity) + 1;
  const existing = leaderboard.find((player) => player.email.toLowerCase() === normalizedEmail);
  const name = existing ? existing.name : displayNameFromEmail(baseIdentity);

  return {
    email: normalizedEmail,
    name,
    points,
    rank,
    horseName: "Thunder",
    farm: getFarmProgress(points)
  };
}
