document.addEventListener("DOMContentLoaded", () => {
  const statusRing = document.getElementById("status-ring");
  const statusIcon = document.getElementById("status-icon");
  const statusText = document.getElementById("status-text");
  const statusSubtitle = document.getElementById("status-subtitle");
  const detailsCard = document.getElementById("details-card");
  const confidenceBar = document.getElementById("confidence-bar");
  const confidenceValue = document.getElementById("confidence-value");
  const riskBadge = document.getElementById("risk-badge");
  const urlValue = document.getElementById("url-value");
  const rescanBtn = document.getElementById("rescan-btn");

  // Load current status
  loadStatus();

  // Rescan button
  rescanBtn.addEventListener("click", () => {
    showLoading();
    chrome.runtime.sendMessage({ type: "RECHECK" }, () => {
      setTimeout(loadStatus, 1500);
    });
  });

  function loadStatus() {
    chrome.runtime.sendMessage({ type: "GET_STATUS" }, (data) => {
      if (data) {
        updateUI(data);
      } else {
        showLoading();
      }
    });
  }

  function showLoading() {
    statusRing.className = "status-ring";
    statusIcon.innerHTML = '<div class="loader"></div>';
    statusText.textContent = "Analyzing...";
    statusText.className = "status-text";
    statusSubtitle.textContent = "Checking current page";
    detailsCard.style.display = "none";
  }

  function updateUI(data) {
    detailsCard.style.display = "block";

    // Update URL
    const displayUrl = data.url || "Unknown";
    urlValue.textContent =
      displayUrl.length > 50 ? displayUrl.substring(0, 50) + "..." : displayUrl;

    // Update confidence
    const confidence = Math.round((data.confidence || 0) * 100);
    confidenceBar.style.width = confidence + "%";
    confidenceValue.textContent = confidence + "%";

    // Update risk badge
    const risk = (data.risk_level || "unknown").toLowerCase();
    riskBadge.textContent = data.risk_level || "Unknown";
    riskBadge.className = "risk-badge " + risk;

    if (data.is_phishing) {
      // Dangerous site
      statusRing.className = "status-ring danger";
      statusIcon.className = "status-icon danger";
      statusIcon.innerHTML = `
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"/>
          <line x1="15" y1="9" x2="9" y2="15"/>
          <line x1="9" y1="9" x2="15" y2="15"/>
        </svg>
      `;
      statusText.textContent = "Threat Detected";
      statusText.className = "status-text danger";
      statusSubtitle.textContent = "This site may be dangerous";
      confidenceBar.className = "progress-fill danger";
    } else {
      // Safe site
      statusRing.className = "status-ring safe";
      statusIcon.className = "status-icon safe";
      statusIcon.innerHTML = `
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M22 11.08V12a10 10 0 11-5.93-9.14"/>
          <polyline points="22 4 12 14.01 9 11.01"/>
        </svg>
      `;
      statusText.textContent = "Site is Safe";
      statusText.className = "status-text safe";
      statusSubtitle.textContent = "No threats detected";
      confidenceBar.className = "progress-fill safe";
    }
  }

  // Listen for updates from background
  chrome.storage.onChanged.addListener((changes) => {
    if (changes.lastCheck) {
      updateUI(changes.lastCheck.newValue);
    }
  });
});
