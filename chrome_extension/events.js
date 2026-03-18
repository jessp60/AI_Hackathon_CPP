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
