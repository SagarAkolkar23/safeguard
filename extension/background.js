const API_BASE_URL = "http://localhost:5000/phishing/phish";
const cache = new Map();
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes

console.log("[PhishGuard] Background service worker loaded.");

// Listen for tab updates
chrome.tabs.onUpdated.addListener(async (tabId, changeInfo, tab) => {
  if (changeInfo.status === "complete" && tab.url) {
    console.log("[PhishGuard] Tab updated:", tab.url);

    // Skip chrome internal pages
    if (
      tab.url.startsWith("chrome") ||
      tab.url.startsWith("edge") ||
      tab.url.startsWith("about") ||
      tab.url.startsWith("moz-extension")
    ) {
      console.log("[PhishGuard] Skipped internal browser page.");
      return;
    }

    await checkUrl(tab.url, tabId);
  }
});

// Listen for switching tabs
chrome.tabs.onActivated.addListener(async (activeInfo) => {
  const tab = await chrome.tabs.get(activeInfo.tabId);
  if (tab.url) {
    console.log("[PhishGuard] Tab activated:", tab.url);

    if (!tab.url.startsWith("chrome") && !tab.url.startsWith("edge")) {
      await checkUrl(tab.url, activeInfo.tabId);
    }
  }
});

async function checkUrl(url, tabId) {
  try {
    console.log(`[PhishGuard] Checking URL: ${url}`);

    // Cache logic
    const cached = cache.get(url);
    if (cached && Date.now() - cached.timestamp < CACHE_DURATION) {
      console.log("[PhishGuard] Cache hit:", cached.data);
      sendResultToTab(tabId, cached.data);
      updateBadge(tabId, cached.data);
      return;
    }

    console.log("[PhishGuard] Cache miss. Fetching from backend...");

    // Show loading badge
    chrome.action.setBadgeText({ text: "...", tabId });
    chrome.action.setBadgeBackgroundColor({ color: "#6366f1", tabId });

    console.log("[PhishGuard] Sending POST →", `${API_BASE_URL}`);

    const response = await fetch(`${API_BASE_URL}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ url }),
    });

    console.log("[PhishGuard] Response status:", response.status);

    if (!response.ok) throw new Error("API request failed");

    const result = await response.json();
    console.log("[PhishGuard] Backend result:", result);

    const data = result.data;

    // Cache
    cache.set(url, { data, timestamp: Date.now() });
    console.log("[PhishGuard] Cached new result.");

    // Store for popup
    chrome.storage.local.set({ lastCheck: { url, ...data } });

    sendResultToTab(tabId, data);
    updateBadge(tabId, data);
  } catch (error) {
    console.error("[PhishGuard] ERROR:", error);

    chrome.action.setBadgeText({ text: "!", tabId });
    chrome.action.setBadgeBackgroundColor({ color: "#f59e0b", tabId });

    sendResultToTab(tabId, {
      error: true,
      message: "Connection failed",
    });
  }
}

function sendResultToTab(tabId, data) {
  console.log("[PhishGuard] Sending result to content script:", data);

  chrome.tabs
    .sendMessage(tabId, { type: "PHISH_RESULT", data })
    .catch((err) => {
      console.warn(
        "[PhishGuard] Could not send message (content script missing):",
        err
      );
    });
}

function updateBadge(tabId, data) {
  console.log("[PhishGuard] Updating badge:", data);

  if (data.is_phishing) {
    chrome.action.setBadgeText({ text: "⚠", tabId });
    chrome.action.setBadgeBackgroundColor({ color: "#ef4444", tabId });
  } else {
    chrome.action.setBadgeText({ text: "✓", tabId });
    chrome.action.setBadgeBackgroundColor({ color: "#10b981", tabId });
  }
}

// Popup message listeners
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  console.log("[PhishGuard] Popup message received:", msg);

  if (msg.type === "GET_STATUS") {
    chrome.storage.local.get("lastCheck", (result) => {
      console.log(
        "[PhishGuard] Sending last check to popup:",
        result.lastCheck
      );
      sendResponse(result.lastCheck || null);
    });
    return true;
  }

  if (msg.type === "RECHECK") {
    console.log("[PhishGuard] Rechecking current tab...");
    chrome.tabs.query({ active: true, currentWindow: true }, async (tabs) => {
      if (tabs[0]) {
        console.log("[PhishGuard] Clearing cache for:", tabs[0].url);
        cache.delete(tabs[0].url);
        await checkUrl(tabs[0].url, tabs[0].id);
        sendResponse({ success: true });
      }
    });
    return true;
  }
});
