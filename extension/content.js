// PhishGuard Content Script
let alertOverlay = null;
let statusIndicator = null;

// Create status indicator
function createStatusIndicator() {
  if (statusIndicator) return;

  statusIndicator = document.createElement("div");
  statusIndicator.id = "phishguard-status";
  statusIndicator.innerHTML = `
    <div class="pg-indicator pg-loading">
      <div class="pg-spinner"></div>
      <span>Scanning...</span>
    </div>
  `;
  document.body.appendChild(statusIndicator);

  // Auto-hide after 4 seconds for safe sites
  setTimeout(() => {
    if (statusIndicator && statusIndicator.querySelector(".pg-safe")) {
      statusIndicator.classList.add("pg-fade-out");
      setTimeout(() => statusIndicator?.remove(), 500);
    }
  }, 4000);
}

// Create danger alert overlay
function createDangerAlert(data) {
  if (alertOverlay) alertOverlay.remove();

  alertOverlay = document.createElement("div");
  alertOverlay.id = "phishguard-alert";
  alertOverlay.innerHTML = `
    <div class="pg-alert-backdrop"></div>
    <div class="pg-alert-container">
      <div class="pg-alert-glow"></div>
      <div class="pg-alert-content">
        <div class="pg-alert-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 9v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
        </div>
        <h1 class="pg-alert-title">⚠️ PHISHING DETECTED</h1>
        <p class="pg-alert-subtitle">This website has been identified as potentially dangerous</p>
        
        <div class="pg-alert-stats">
          <div class="pg-stat">
            <span class="pg-stat-label">Risk Level</span>
            <span class="pg-stat-value pg-risk-${
              data.risk_level?.toLowerCase() || "high"
            }">${data.risk_level || "HIGH"}</span>
          </div>
          <div class="pg-stat">
            <span class="pg-stat-label">Confidence</span>
            <span class="pg-stat-value">${(data.confidence * 100).toFixed(
              1
            )}%</span>
          </div>
          <div class="pg-stat">
            <span class="pg-stat-label">Threat Score</span>
            <span class="pg-stat-value">${(data.probability * 100).toFixed(
              1
            )}%</span>
          </div>
        </div>
        
        <div class="pg-alert-url">
          <span class="pg-url-label">Dangerous URL:</span>
          <code class="pg-url-text">${data.url || window.location.href}</code>
        </div>
        
        <div class="pg-alert-actions">
          <button class="pg-btn pg-btn-back" id="pg-go-back">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="18" height="18">
              <path d="M19 12H5m7-7l-7 7 7 7"/>
            </svg>
            Go Back to Safety
          </button>
          <button class="pg-btn pg-btn-proceed" id="pg-proceed">
            Proceed Anyway (Not Recommended)
          </button>
        </div>
        
        <p class="pg-alert-footer">Protected by PhishGuard AI</p>
      </div>
    </div>
  `;

  document.body.appendChild(alertOverlay);

  // Event listeners
  document.getElementById("pg-go-back").addEventListener("click", () => {
    history.back() || window.close();
  });

  document.getElementById("pg-proceed").addEventListener("click", () => {
    alertOverlay.classList.add("pg-dismiss");
    setTimeout(() => alertOverlay?.remove(), 300);
  });
}

// Update status indicator
function updateStatus(data) {
  if (!statusIndicator) createStatusIndicator();

  const indicator = statusIndicator.querySelector(".pg-indicator");
  if (!indicator) return;

  if (data.error) {
    indicator.className = "pg-indicator pg-error";
    indicator.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="20" height="20">
        <circle cx="12" cy="12" r="10"/><path d="M12 8v4m0 4h.01"/>
      </svg>
      <span>Connection Error</span>
    `;
  } else if (data.is_phishing) {
    indicator.className = "pg-indicator pg-danger";
    indicator.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="20" height="20">
        <path d="M12 9v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
      </svg>
      <span>DANGER - Phishing Detected!</span>
    `;
    createDangerAlert(data);
  } else {
    indicator.className = "pg-indicator pg-safe";
    indicator.innerHTML = `
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="20" height="20">
        <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
      </svg>
      <span>Site Verified Safe</span>
    `;
  }
}

// Listen for messages from background script
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (msg.type === "PHISH_RESULT") {
    updateStatus(msg.data);
  }
});

// Initialize on page load
createStatusIndicator();
