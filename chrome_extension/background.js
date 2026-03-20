const NOTIFICATION_ID = "insight-quest-today";
const DAILY_ALARM = "insight-quest-daily-check";

function createNotification(events) {
  if (!events.length) {
    return chrome.notifications.create(NOTIFICATION_ID, {
      type: "basic",
      iconUrl: "icons/icon-128.png",
      title: "Insight Quest",
      message: "No Insight Association events are scheduled for today.",
      priority: 1
    });
  }

  const firstEvent = events[0];
  const extraCount = events.length - 1;
  const detail = extraCount > 0
    ? `${firstEvent.region} plus ${extraCount} more event${extraCount > 1 ? "s" : ""}.`
    : `${firstEvent.region} is on the calendar today.`;

  return chrome.notifications.create(NOTIFICATION_ID, {
    type: "basic",
    iconUrl: "icons/icon-128.png",
    title: `${events.length} Insight event${events.length > 1 ? "s" : ""} today`,
    message: `${firstEvent.title}. ${detail}`,
    priority: 2
  });
}

async function notifyTodayEvents() {
  const events = getTodayEvents();
  await createNotification(events);
  await chrome.storage.local.set({
    lastNotificationDate: getTodayIsoDate(),
    lastNotificationCount: events.length
  });
  return events;
}

async function maybeNotifyTodayEvents() {
  const today = getTodayIsoDate();
  const { lastNotificationDate } = await chrome.storage.local.get("lastNotificationDate");

  if (lastNotificationDate === today) {
    return [];
  }

  return notifyTodayEvents();
}

chrome.runtime.onInstalled.addListener(async () => {
  await chrome.alarms.create(DAILY_ALARM, {
    delayInMinutes: 1,
    periodInMinutes: 60
  });
  await maybeNotifyTodayEvents();
});

chrome.alarms.onAlarm.addListener(async (alarm) => {
  if (alarm.name === DAILY_ALARM) {
    await maybeNotifyTodayEvents();
  }
});

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message?.type === "notifyToday") {
    notifyTodayEvents()
      .then((events) => {
        sendResponse({
          ok: true,
          message: events.length
            ? `Sent notification for ${events.length} event${events.length > 1 ? "s" : ""}.`
            : "Sent a no-events notification."
        });
      })
      .catch(() => {
        sendResponse({ ok: false });
      });
    return true;
  }

  return false;
});
