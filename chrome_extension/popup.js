function formatDate(dateString) {
  return new Date(`${dateString}T12:00:00`).toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
    year: "numeric"
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

  const chips = document.createElement("div");
  chips.className = "chips";

  const xpChip = document.createElement("span");
  xpChip.className = "chip";
  xpChip.textContent = `+${event.rewardXp} XP`;

  const coinChip = document.createElement("span");
  coinChip.className = "chip";
  coinChip.textContent = `+${event.rewardCoins} coins`;

  chips.append(xpChip, coinChip);
  card.append(title, meta, schools, chips);
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

function renderAccount(account) {
  const signedOut = document.getElementById("account-signed-out");
  const signedIn = document.getElementById("account-signed-in");

  if (!account) {
    signedOut.classList.remove("hidden");
    signedIn.classList.add("hidden");
    return;
  }

  signedOut.classList.add("hidden");
  signedIn.classList.remove("hidden");
  document.getElementById("account-name").textContent = account.fullName;
  document.getElementById("account-email").textContent = account.email;
  document.getElementById("account-avatar").textContent = account.avatarInitials;
}

async function loadAccount() {
  const { appAccountSession } = await chrome.storage.local.get("appAccountSession");
  if (!appAccountSession?.idToken) {
    renderAccount(null);
    return;
  }

  try {
    const lookup = await firebaseAuthRequest(FIREBASE_AUTH_ENDPOINTS.lookup, {
      idToken: appAccountSession.idToken
    });
    const user = lookup.users?.[0];
    if (!user?.email) {
      renderAccount(null);
      return;
    }

    const account = {
      fullName: user.displayName || "Insight Student",
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
    renderAccount(account);
  } catch (error) {
    await chrome.storage.local.remove("appAccountSession");
    renderAccount(null);
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
    const appAccount = {
      fullName: "Insight Student",
      email: data.email || email,
      avatarInitials: initialsFromEmail(data.email || email)
    };
    await chrome.storage.local.set({
      appAccountSession: {
        email: data.email || email,
        localId: data.localId,
        idToken: data.idToken,
        refreshToken: data.refreshToken,
        displayName: appAccount.fullName
      }
    });
    renderAccount(appAccount);
    setStatus("Signed in with Firebase.");
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
    const appAccount = {
      fullName: "Insight Student",
      email: data.email || email,
      avatarInitials: initialsFromEmail(data.email || email)
    };
    await chrome.storage.local.set({
      appAccountSession: {
        email: data.email || email,
        localId: data.localId,
        idToken: data.idToken,
        refreshToken: data.refreshToken,
        displayName: appAccount.fullName
      }
    });
    renderAccount(appAccount);
    setStatus("Firebase account created and signed in.");
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
  renderAccount(null);
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
  const upcomingEvents = getUpcomingEvents();

  loadAccount();
  document.getElementById("today-count").textContent = String(todayEvents.length);
  renderList("today-list", todayEvents, "No Insight events are scheduled for today.");
  renderList("upcoming-list", upcomingEvents, "No upcoming events are currently loaded.");
  document.getElementById("email-sign-in").addEventListener("click", signInWithEmail);
  document.getElementById("create-account").addEventListener("click", createAccount);
  document.getElementById("forgot-password").addEventListener("click", requestPasswordReset);
  document.getElementById("email-sign-out").addEventListener("click", signOut);
  document.getElementById("notify-now").addEventListener("click", triggerNotification);
}

document.addEventListener("DOMContentLoaded", initPopup);
