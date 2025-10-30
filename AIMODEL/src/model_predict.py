import joblib
import pandas as pd
import os
import sys

# Path to your saved model (adjust if you saved it elsewhere)
MODEL_PATH = os.path.join(os.path.dirname(__file__), "..", "phishing_model.pkl")
MODEL_PATH = os.path.abspath(MODEL_PATH)

# Load trained model
try:
    model = joblib.load(MODEL_PATH)
except Exception as e:
    print(f"Error loading model from {MODEL_PATH}: {e}")
    sys.exit(1)

# Full list of feature columns used during training (exact order matters)
FEATURE_COLUMNS = [
    'NumDots', 'SubdomainLevel', 'PathLevel', 'UrlLength', 'NumDash', 'NumDashInHostname',
    'AtSymbol', 'TildeSymbol', 'NumUnderscore', 'NumPercent', 'NumQueryComponents', 'NumAmpersand',
    'NumHash', 'NumNumericChars', 'NoHttps', 'RandomString', 'IpAddress', 'DomainInSubdomains',
    'DomainInPaths', 'HttpsInHostname', 'HostnameLength', 'PathLength', 'QueryLength',
    'DoubleSlashInPath', 'NumSensitiveWords', 'EmbeddedBrandName', 'PctExtHyperlinks',
    'PctExtResourceUrls', 'ExtFavicon', 'InsecureForms', 'RelativeFormAction', 'ExtFormAction',
    'AbnormalFormAction', 'PctNullSelfRedirectHyperlinks', 'FrequentDomainNameMismatch',
    'FakeLinkInStatusBar', 'RightClickDisabled', 'PopUpWindow', 'SubmitInfoToEmail',
    'IframeOrFrame', 'MissingTitle', 'ImagesOnlyInForm', 'SubdomainLevelRT', 'UrlLengthRT',
    'PctExtResourceUrlsRT', 'AbnormalExtFormActionR', 'ExtMetaScriptLinkRT',
    'PctExtNullSelfRedirectHyperlinksRT'
]

def predict_phishing(features: dict):
    """
    Predict whether a site is phishing/unsafe.
    :param features: dict of feature_name -> value (you may provide a subset; missing features will be filled with 0)
    :return: dict with keys 'prediction' (int) and 'probability_of_being_unsafe' (float)
    """

    # Create DataFrame from input dictionary
    X = pd.DataFrame([features])

    # Add missing features with default 0
    for col in FEATURE_COLUMNS:
        if col not in X.columns:
            X[col] = 0

    # Keep only expected columns and ensure correct order
    X = X[FEATURE_COLUMNS]

    # Some models require numeric dtype; ensure numeric
    X = X.apply(pd.to_numeric, errors='coerce').fillna(0)

    # Predict
    pred = model.predict(X)[0]
    # predict_proba returns probabilities for each class; index [1] is the probability for class label 1
    try:
        prob = model.predict_proba(X)[0][1]
    except Exception:
        # If model doesn't implement predict_proba, fallback to distance-based or raise
        prob = float(model.predict(X)[0])

    return {
        "prediction": int(pred),
        "probability_of_being_unsafe": float(prob)
    }

# --- TEST BLOCK ---
if __name__ == "__main__":
    # Example input: provide a few features (rest will default to 0)
    # IMPORTANT: adjust these values to reflect realistic ranges from your dataset.
    sample_features = {
        'NumDots': 3,
        'SubdomainLevel': 1,
        'PathLevel': 2,
        'UrlLength': 85,
        'NumDash': 1,
        'NumDashInHostname': 0,
        'AtSymbol': 0,
        'TildeSymbol': 0,
        'NumUnderscore': 0,
        'NumPercent': 0,
        'NumQueryComponents': 1,
        'NumAmpersand': 0,
        'NumHash': 0,
        'NumNumericChars': 5,
        'NoHttps': 0,                # 1 if no https, 0 if https present
        'RandomString': 0,
        'IpAddress': 0,              # 1 if URL uses IP instead of domain
        'DomainInSubdomains': 0,
        'DomainInPaths': 0,
        'HttpsInHostname': 0,
        'HostnameLength': 15,
        'PathLength': 25,
        'QueryLength': 0,
        'DoubleSlashInPath': 0,
        'NumSensitiveWords': 0,
        'EmbeddedBrandName': 0,
        'PctExtHyperlinks': 0,
        'PctExtResourceUrls': 0,
        'ExtFavicon': 0,
        'InsecureForms': 0,
        'RelativeFormAction': 0,
        'ExtFormAction': 0,
        'AbnormalFormAction': 0,
        'PctNullSelfRedirectHyperlinks': 0,
        'FrequentDomainNameMismatch': 0,
        'FakeLinkInStatusBar': 0,
        'RightClickDisabled': 0,
        'PopUpWindow': 0,
        'SubmitInfoToEmail': 0,
        'IframeOrFrame': 0,
        'MissingTitle': 0,
        'ImagesOnlyInForm': 0,
        'SubdomainLevelRT': 0,
        'UrlLengthRT': 0,
        'PctExtResourceUrlsRT': 0,
        'AbnormalExtFormActionR': 0,
        'ExtMetaScriptLinkRT': 0,
        'PctExtNullSelfRedirectHyperlinksRT': 0
    }

    out = predict_phishing(sample_features)
    print("Prediction result:", out)
    # Interpretation hint:
    #   - "prediction": integer class predicted by the model (0 or 1).
    #   - "probability_of_being_unsafe": model's probability for class label 1.
    # If class label 1 == unsafe in your training set, higher probability => more likely phishing.
