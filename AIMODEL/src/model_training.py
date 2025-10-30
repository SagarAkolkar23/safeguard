import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier
from lightgbm import LGBMClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import joblib
import json

# Load dataset
print("Loading dataset...")
df = pd.read_csv("data/phishing.csv")

print(f"Dataset shape: {df.shape}")
print(f"Columns: {df.columns.tolist()}")

# Drop unnecessary columns like 'id' if present
if 'id' in df.columns:
    df = df.drop(columns=['id'])

# Separate features (X) and target (y)
X = df.drop(columns=['CLASS_LABEL'])
y = df['CLASS_LABEL']

print(f"\nFeatures: {X.shape[1]}")
print(f"Samples: {X.shape[0]}")
print(f"Class distribution:\n{y.value_counts()}")

# IMPORTANT: Save the feature columns for later use
feature_columns = X.columns.tolist()
with open('feature_columns.json', 'w') as f:
    json.dump(feature_columns, f)
print(f"\n✅ Saved {len(feature_columns)} feature columns to feature_columns.json")

# Split into train/test with stratification
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

print(f"\nTraining set: {X_train.shape[0]} samples")
print(f"Test set: {X_test.shape[0]} samples")

# Train models
print("\n" + "="*50)
print("TRAINING MODELS")
print("="*50)

print("\n[1/3] Training RandomForest...")
rf = RandomForestClassifier(n_estimators=200, random_state=42, n_jobs=-1)
rf.fit(X_train, y_train)
print("✅ RandomForest trained")

print("\n[2/3] Training XGBoost...")
xgb = XGBClassifier(
    use_label_encoder=False, 
    eval_metric='logloss', 
    random_state=42,
    n_estimators=200
)
xgb.fit(X_train, y_train)
print("✅ XGBoost trained")

print("\n[3/3] Training LightGBM...")
lgbm = LGBMClassifier(random_state=42, n_estimators=200, verbose=-1)
lgbm.fit(X_train, y_train)
print("✅ LightGBM trained")

# Evaluate all models
print("\n" + "="*50)
print("MODEL EVALUATION")
print("="*50)

models = {
    'RandomForest': rf, 
    'XGBoost': xgb, 
    'LightGBM': lgbm
}

best_acc = 0
best_model_name = None
best_model = None

for name, model in models.items():
    preds = model.predict(X_test)
    acc = accuracy_score(y_test, preds)
    
    print(f"\n{name} Results:")
    print(f"Accuracy: {acc:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, preds, target_names=['Safe', 'Phishing']))
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, preds))
    
    if acc > best_acc:
        best_acc = acc
        best_model_name = name
        best_model = model

# Save the best model
print("\n" + "="*50)
print(f"🏆 Best Model: {best_model_name} with accuracy {best_acc:.4f}")
joblib.dump(best_model, "phishing_model.pkl")
print("✅ Model saved as phishing_model.pkl")

# Save model metadata
metadata = {
    "model_type": best_model_name,
    "accuracy": float(best_acc),
    "n_features": len(feature_columns),
    "feature_columns": feature_columns
}
with open('model_metadata.json', 'w') as f:
    json.dump(metadata, f, indent=2)
print("✅ Model metadata saved to model_metadata.json")

# Feature importance (for RandomForest or best tree model)
if hasattr(best_model, 'feature_importances_'):
    feature_importance = pd.DataFrame({
        'feature': feature_columns,
        'importance': best_model.feature_importances_
    }).sort_values('importance', ascending=False)
    
    print("\n" + "="*50)
    print("TOP 10 MOST IMPORTANT FEATURES")
    print("="*50)
    print(feature_importance.head(10).to_string(index=False))
    
    feature_importance.to_csv('feature_importance.csv', index=False)
    print("\n✅ Feature importance saved to feature_importance.csv")

print("\n" + "="*50)
print("✅ TRAINING COMPLETE!")
print("="*50)
print("\nFiles created:")
print("  - phishing_model.pkl (trained model)")
print("  - feature_columns.json (feature list)")
print("  - model_metadata.json (model info)")
print("  - feature_importance.csv (feature rankings)")