function formatDate(dateString) {
  return new Date(`${dateString}T12:00:00`).toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
    year: "numeric"
  });
}

function setStatus(message) {
  document.getElementById("status").textContent = message;
}

function setBusyState(isBusy) {
  const buttons = [
    "email-sign-in",
    "create-account",
    "forgot-password",
    "email-sign-out",
    "notify-now"
  ];
  buttons.forEach((id) => {
    const element = document.getElementById(id);
    if (element) {
      element.disabled = isBusy;
    }
  });
}

function friendlyAuthError(error) {
  const message = typeof error === "string" ? error : error?.message || "Authentication failed.";
  if (message.includes("EMAIL_EXISTS")) {
    return "That email already has an account.";
  }
  if (message.includes("INVALID_LOGIN_CREDENTIALS") || message.includes("INVALID_PASSWORD") || message.includes("EMAIL_NOT_FOUND")) {
    return "Incorrect email or password.";
  }
  if (message.includes("WEAK_PASSWORD")) {
    return "Use a stronger password with at least 6 characters.";
  }
  if (message.includes("INVALID_EMAIL")) {
    return "That email address is not valid.";
  }
  return message;
}

async function firebaseAuthRequest(url, payload) {
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(payload)
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.error?.message || "Firebase request failed.");
  }
  return data;
}

function renderChipList(containerId, values, className, emptyText) {
  const container = document.getElementById(containerId);
  container.innerHTML = "";
  if (!values.length) {
    const empty = document.createElement("p");
    empty.className = "empty";
    empty.textContent = emptyText;
    container.appendChild(empty);
    return;
  }
  values.forEach((value) => {
    const chip = document.createElement("div");
    chip.className = className;
    chip.textContent = value;
    container.appendChild(chip);
  });
}

function createEventCard(event) {
  const card = document.createElement("article");
  card.className = "event-card";

  const title = document.createElement("h3");
  title.textContent = event.title;

  const meta = document.createElement("p");
  meta.className = "meta";
  meta.textContent = `${formatDate(event.date)} • ${event.region}`;

  const schools = document.createElement("p");
  schools.className = "meta";
  schools.textContent = `Nearby schools: ${event.nearbyUniversities}`;

  const footer = document.createElement("div");
  footer.className = "event-footer";

  const xpChip = document.createElement("span");
  xpChip.className = "reward-chip";
  xpChip.textContent = `+${event.rewardXp} PTS`;

  const coinChip = document.createElement("span");
  coinChip.className = "reward-chip";
  coinChip.textContent = `+${event.rewardCoins} FARM`;

  footer.append(xpChip, coinChip);
  card.append(title, meta, schools, footer);
  return card;
}

function renderList(containerId, events, emptyMessage) {
  const container = document.getElementById(containerId);
  container.innerHTML = "";

  if (!events.length) {
    const empty = document.createElement("p");
    empty.className = "empty";
    empty.textContent = emptyMessage;
    container.appendChild(empty);
    return;
  }

  events.forEach((event) => {
    container.appendChild(createEventCard(event));
  });
}

function renderLeaderboard(email) {
  const container = document.getElementById("leaderboard-list");
  container.innerHTML = "";
  getLeaderboard().forEach((player, index) => {
    const row = document.createElement("article");
    row.className = "leaderboard-row";

    const left = document.createElement("div");
    left.className = "leader-left";

    const rank = document.createElement("div");
    rank.className = "leader-rank";
    rank.textContent = `#${index + 1}`;

    const name = document.createElement("div");
    name.className = "leader-name";
    name.textContent = player.name + (player.email === email ? " (YOU)" : "");

    const points = document.createElement("div");
    points.className = "leader-points";
    points.textContent = `${player.points} pts`;

    left.append(rank, name);
    row.append(left, points);
    container.appendChild(row);
  });
}

function renderFarm(profile) {
  const farm = profile.farm;
  document.getElementById("farm-rank-badge").textContent = `RANK ${profile.rank}`;
  document.getElementById("farm-points").textContent = `${profile.points}`;
  document.getElementById("farm-tier").textContent = farm.tier;
  document.getElementById("farm-land").textContent = farm.landLabel;
  document.getElementById("farm-next").textContent = farm.nextUnlock;
  document.getElementById("farm-progress").style.width = `${Math.round(farm.progress * 100)}%`;
  document.getElementById("farm-progress-text").textContent = farm.pointsToNext > 0
    ? `${farm.pointsToNext} pts until ${farm.nextUnlock}.`
    : "Your ranch is fully upgraded for this demo tier.";
  document.getElementById("item-count").textContent = String(farm.items.length);
  document.getElementById("animal-count").textContent = String(farm.animals.length);
  renderChipList("farm-items", farm.items, "farm-chip", "No farm items unlocked yet.");
  renderChipList("farm-animals", farm.animals, "farm-chip animal", "No animals unlocked yet.");
  renderLeaderboard(profile.email);
}

function renderSignedInAccount(account) {
  const signedOut = document.getElementById("account-signed-out");
  const signedIn = document.getElementById("account-signed-in");
  signedOut.classList.add("hidden");
  signedIn.classList.remove("hidden");
  document.getElementById("account-name").textContent = account.fullName;
  document.getElementById("account-email").textContent = account.email;
  document.getElementById("account-avatar").textContent = account.avatarInitials;
}

function renderSignedOutState() {
  document.getElementById("account-signed-out").classList.remove("hidden");
  document.getElementById("account-signed-in").classList.add("hidden");
  renderFarm(getPlayerProfile(""));
  renderLeaderboard("");
}

async function loadAccount() {
  const { appAccountSession } = await chrome.storage.local.get("appAccountSession");
  if (!appAccountSession?.idToken) {
    renderSignedOutState();
    return;
  }

  try {
    const lookup = await firebaseAuthRequest(FIREBASE_AUTH_ENDPOINTS.lookup, {
      idToken: appAccountSession.idToken
    });
    const user = lookup.users?.[0];
    if (!user?.email) {
      renderSignedOutState();
      return;
    }

    const account = {
      fullName: user.displayName || getPlayerProfile(user.email).name,
      email: user.email,
      avatarInitials: initialsFromEmail(user.email)
    };
    await chrome.storage.local.set({
      appAccountSession: {
        ...appAccountSession,
        email: account.email,
        displayName: account.fullName
      }
    });
    renderSignedInAccount(account);
    renderFarm(getPlayerProfile(account.email));
  } catch (error) {
    await chrome.storage.local.remove("appAccountSession");
    renderSignedOutState();
    setStatus(`Session expired. ${friendlyAuthError(error)}`);
  }
}

function initialsFromEmail(email) {
  const prefix = email.split("@")[0] || "iq";
  return prefix
    .split(/[._-]+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join("")
    .toUpperCase() || "IQ";
}

async function signInWithEmail() {
  const email = document.getElementById("auth-email").value.trim();
  const password = document.getElementById("auth-password").value.trim();

  if (!email || !password) {
    setStatus("Enter both email and password.");
    return;
  }

  setBusyState(true);
  try {
    const data = await firebaseAuthRequest(FIREBASE_AUTH_ENDPOINTS.signIn, {
      email,
      password,
      returnSecureToken: true
    });
    const profile = getPlayerProfile(data.email || email);
    const account = {
      fullName: profile.name,
      email: data.email || email,
      avatarInitials: initialsFromEmail(data.email || email)
    };
    await chrome.storage.local.set({
      appAccountSession: {
        email: account.email,
        localId: data.localId,
        idToken: data.idToken,
        refreshToken: data.refreshToken,
        displayName: account.fullName
      }
    });
    renderSignedInAccount(account);
    renderFarm(profile);
    setStatus("Trainer data synced from Firebase.");
  } catch (error) {
    setStatus(friendlyAuthError(error));
  } finally {
    setBusyState(false);
  }
}

async function createAccount() {
  const email = document.getElementById("auth-email").value.trim();
  const password = document.getElementById("auth-password").value.trim();

  if (!email || !password) {
    setStatus("Enter an email and password to create your account.");
    return;
  }

  setBusyState(true);
  try {
    const data = await firebaseAuthRequest(FIREBASE_AUTH_ENDPOINTS.signUp, {
      email,
      password,
      returnSecureToken: true
    });
    const profile = getPlayerProfile(data.email || email);
    const account = {
      fullName: profile.name,
      email: data.email || email,
      avatarInitials: initialsFromEmail(data.email || email)
    };
    await chrome.storage.local.set({
      appAccountSession: {
        email: account.email,
        localId: data.localId,
        idToken: data.idToken,
        refreshToken: data.refreshToken,
        displayName: account.fullName
      }
    });
    renderSignedInAccount(account);
    renderFarm(profile);
    setStatus("New trainer account created.");
  } catch (error) {
    setStatus(friendlyAuthError(error));
  } finally {
    setBusyState(false);
  }
}

async function requestPasswordReset() {
  const email = document.getElementById("auth-email").value.trim();
  if (!email) {
    setStatus("Enter your email before requesting a password reset.");
    return;
  }
  setBusyState(true);
  try {
    await firebaseAuthRequest(FIREBASE_AUTH_ENDPOINTS.resetPassword, {
      requestType: "PASSWORD_RESET",
      email
    });
    setStatus(`Password reset email sent to ${email}.`);
  } catch (error) {
    setStatus(friendlyAuthError(error));
  } finally {
    setBusyState(false);
  }
}

async function signOut() {
  await chrome.storage.local.remove("appAccountSession");
  renderSignedOutState();
  setStatus("Signed out.");
}

async function triggerNotification() {
  const response = await chrome.runtime.sendMessage({ type: "notifyToday" });
  if (response?.ok) {
    setStatus(response.message);
  } else {
    setStatus("Notification request failed.");
  }
}

function initPopup() {
  const todayEvents = getTodayEvents();
  const upcomingEvents = getUpcomingEvents(5);

  document.getElementById("today-count").textContent = String(todayEvents.length);
  renderList("today-list", todayEvents, "No Insight events are scheduled for today.");
  renderList("upcoming-list", upcomingEvents, "No upcoming events are currently loaded.");
  renderFarm(getPlayerProfile(""));
  renderLeaderboard("");
  loadAccount();
  document.getElementById("email-sign-in").addEventListener("click", signInWithEmail);
  document.getElementById("create-account").addEventListener("click", createAccount);
  document.getElementById("forgot-password").addEventListener("click", requestPasswordReset);
  document.getElementById("email-sign-out").addEventListener("click", signOut);
  document.getElementById("notify-now").addEventListener("click", triggerNotification);
}

document.addEventListener("DOMContentLoaded", initPopup);
