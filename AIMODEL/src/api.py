
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, validator
import joblib
import pandas as pd
import json
import os
from typing import Optional
from datetime import datetime

from src.feature_extractor import extract_features, get_feature_vector

# --- Load model and metadata ---
MODEL_PATH = "src/phishing_model.pkl"
METADATA_PATH = "src/model_metadata.json"
FEATURE_COLUMNS_PATH = "src/feature_columns.json"

try:
    model = joblib.load(MODEL_PATH)
    print(f"✅ Model loaded from {MODEL_PATH}")
except Exception as e:
    raise RuntimeError(f"Error loading model from {MODEL_PATH}: {e}")

# Load feature columns
try:
    with open(FEATURE_COLUMNS_PATH, 'r') as f:
        FEATURE_COLUMNS = json.load(f)
    print(f"✅ Loaded {len(FEATURE_COLUMNS)} feature columns")
except FileNotFoundError:
    print("⚠️  feature_columns.json not found, using fallback")
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

MODEL_INFO = {}
if os.path.exists(METADATA_PATH):
    with open(METADATA_PATH, 'r') as f:
        MODEL_INFO = json.load(f)

# --- FastAPI setup ---
app = FastAPI(
    title="Phishing URL Detection API",
    description="Detects if a given URL is likely to be phishing or safe using ML model.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class URLRequest(BaseModel):
    url: str = Field(..., description="URL to check for phishing", min_length=1)
    
    @validator('url')
    def validate_url(cls, v):
        if not v.strip():
            raise ValueError("URL cannot be empty")
        if not any(v.startswith(prefix) for prefix in ['http://', 'https://', 'ftp://']):
            v = 'https://' + v
        return v


class PhishingPredictionResponse(BaseModel):
    """
    ✅ UNIFIED RESPONSE MODEL - Used across all layers
    This ensures consistency between FastAPI, Node.js, and Flutter
    """
    url: str = Field(..., description="The analyzed URL")
    is_phishing: bool = Field(..., description="True if phishing detected, False if safe")
    prediction: int = Field(..., description="0 = Safe, 1 = Phishing")
    confidence: float = Field(..., description="Model confidence (0-100%)")
    probability: float = Field(..., description="Probability of being phishing (0-1)")
    risk_level: str = Field(..., description="LOW, MEDIUM, or HIGH")
    timestamp: str = Field(..., description="ISO timestamp of analysis")
    
    class Config:
        json_schema_extra = {
            "example": {
                "url": "https://example.com",
                "is_phishing": False,
                "prediction": 0,
                "confidence": 85.5,
                "probability": 0.075,
                "risk_level": "LOW",
                "timestamp": "2025-01-15T10:30:00Z"
            }
        }


# --- Helper Functions ---
def get_risk_level(probability: float) -> str:
    """Categorize risk based on probability"""
    if probability < 0.3:
        return "LOW"
    elif probability < 0.7:
        return "MEDIUM"
    else:
        return "HIGH"


def predict_phishing_from_url(url: str) -> PhishingPredictionResponse:
    """
    Extract features from URL and predict if it's phishing.
    Returns unified response model.
    """
    try:
        # Extract features
        features = get_feature_vector(url, FEATURE_COLUMNS)
        
        # Convert to DataFrame
        X = pd.DataFrame([features])
        X = X[FEATURE_COLUMNS]
        X = X.apply(pd.to_numeric, errors='coerce').fillna(0)
        
        # Make prediction
        prediction = int(model.predict(X)[0])
        
        # Get probability
        try:
            probability = float(model.predict_proba(X)[0][1])
        except AttributeError:
            probability = float(prediction)
        
        # Calculate risk level and confidence
        risk_level = get_risk_level(probability)
        confidence = abs(probability - 0.5) * 200  # Scale to 0-100%
        
        # ✅ Return unified response
        return PhishingPredictionResponse(
            url=url,
            is_phishing=bool(prediction == 1),
            prediction=prediction,
            confidence=round(confidence, 2),
            probability=round(probability, 4),
            risk_level=risk_level,
            timestamp=datetime.utcnow().isoformat() + "Z"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


# --- API Routes ---
@app.get("/")
def root():
    return {
        "message": "🛡️ Phishing URL Detection API",
        "version": "1.0.0",
        "model_info": MODEL_INFO,
        "endpoints": {
            "/predict": "POST - Predict if URL is phishing",
            "/health": "GET - Check API health",
            "/docs": "GET - API documentation"
        }
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "features_count": len(FEATURE_COLUMNS)
    }


@app.post("/predict", response_model=PhishingPredictionResponse)
def predict_url(data: URLRequest):
    """
    ✅ Predict if a URL is phishing or safe.
    Returns standardized PhishingPredictionResponse model.
    """
    try:
        result = predict_phishing_from_url(data.url)
        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

