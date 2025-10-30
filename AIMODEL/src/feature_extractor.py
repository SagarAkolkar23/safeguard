import re
import tldextract
from urllib.parse import urlparse, parse_qs
import json
import os

# Load expected feature columns
FEATURE_COLUMNS_PATH = "feature_columns.json"

def load_feature_columns():
    """Load the feature columns used during training"""
    if os.path.exists(FEATURE_COLUMNS_PATH):
        with open(FEATURE_COLUMNS_PATH, 'r') as f:
            return json.load(f)
    else:
        # Fallback to the 47 features from your predict.py
        return [
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

EXPECTED_FEATURES = load_feature_columns()


def extract_features(url: str) -> dict:
    """
    Extract URL-based features for phishing detection.
    Returns a dictionary with all features, filling missing ones with 0.
    """
    try:
        parsed = urlparse(url)
        extracted = tldextract.extract(url)
        
        hostname = parsed.hostname or ""
        path = parsed.path or ""
        query = parsed.query or ""
        scheme = parsed.scheme or ""
        
        # Parse query parameters
        query_params = parse_qs(query)
        
        # Basic URL features
        num_dots = url.count('.')
        num_dash = url.count('-')
        num_dash_hostname = hostname.count('-')
        at_symbol = 1 if '@' in url else 0
        tilde_symbol = 1 if '~' in url else 0
        num_underscore = url.count('_')
        num_percent = url.count('%')
        num_query_components = len(query_params)
        num_ampersand = url.count('&')
        num_hash = url.count('#')
        num_numeric_chars = sum(c.isdigit() for c in url)
        
        # HTTPS check
        no_https = 1 if scheme != 'https' else 0
        
        # Subdomain analysis
        subdomain = extracted.subdomain or ""
        subdomain_level = len(subdomain.split('.')) if subdomain else 0
        
        # Path analysis
        path_parts = [p for p in path.split('/') if p]
        path_level = len(path_parts)
        double_slash_in_path = 1 if '//' in path else 0
        
        # Length features
        url_length = len(url)
        hostname_length = len(hostname)
        path_length = len(path)
        query_length = len(query)
        
        # IP address check
        ip_address = 1 if re.match(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$", hostname) else 0
        
        # Domain features
        domain = extracted.domain or ""
        domain_in_subdomains = 1 if domain and domain in subdomain else 0
        domain_in_paths = 1 if domain and domain in path else 0
        https_in_hostname = 1 if 'https' in hostname else 0
        
        # Random string detection (heuristic: many consonants in a row)
        random_string = 1 if re.search(r'[bcdfghjklmnpqrstvwxyz]{8,}', url.lower()) else 0
        
        # Sensitive words
        sensitive_words = ['login', 'secure', 'account', 'bank', 'verify', 'update', 
                          'confirm', 'signin', 'ebay', 'paypal', 'amazon']
        num_sensitive_words = sum(1 for word in sensitive_words if word in url.lower())
        
        # Embedded brand name (heuristic)
        brand_names = ['paypal', 'amazon', 'google', 'microsoft', 'apple', 'facebook', 
                      'netflix', 'ebay', 'alibaba', 'instagram']
        embedded_brand_name = 1 if any(brand in url.lower() for brand in brand_names) and domain.lower() not in brand_names else 0
        
        # Build feature dictionary with all possible features
        features = {
            'NumDots': num_dots,
            'SubdomainLevel': subdomain_level,
            'PathLevel': path_level,
            'UrlLength': url_length,
            'NumDash': num_dash,
            'NumDashInHostname': num_dash_hostname,
            'AtSymbol': at_symbol,
            'TildeSymbol': tilde_symbol,
            'NumUnderscore': num_underscore,
            'NumPercent': num_percent,
            'NumQueryComponents': num_query_components,
            'NumAmpersand': num_ampersand,
            'NumHash': num_hash,
            'NumNumericChars': num_numeric_chars,
            'NoHttps': no_https,
            'RandomString': random_string,
            'IpAddress': ip_address,
            'DomainInSubdomains': domain_in_subdomains,
            'DomainInPaths': domain_in_paths,
            'HttpsInHostname': https_in_hostname,
            'HostnameLength': hostname_length,
            'PathLength': path_length,
            'QueryLength': query_length,
            'DoubleSlashInPath': double_slash_in_path,
            'NumSensitiveWords': num_sensitive_words,
            'EmbeddedBrandName': embedded_brand_name,
            # HTML-based features (placeholder - set to 0 without HTML parsing)
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
            # RT (Real-Time) features - placeholders
            'SubdomainLevelRT': subdomain_level,  # Copy from static
            'UrlLengthRT': url_length,  # Copy from static
            'PctExtResourceUrlsRT': 0,
            'AbnormalExtFormActionR': 0,
            'ExtMetaScriptLinkRT': 0,
            'PctExtNullSelfRedirectHyperlinksRT': 0
        }
        
        return features
        
    except Exception as e:
        print(f"Error extracting features from {url}: {e}")
        # Return default features (all zeros)
        return {col: 0 for col in EXPECTED_FEATURES}


def get_feature_vector(url: str, feature_columns: list) -> dict:
    """
    Extract features and ensure all required columns are present.
    """
    features = extract_features(url)
    
    # Ensure all required features exist
    for col in feature_columns:
        if col not in features:
            features[col] = 0
    
    # Keep only required features
    return {col: features.get(col, 0) for col in feature_columns}


if __name__ == "__main__":
    # Test the feature extractor
    test_urls = [
        "https://www.google.com",
        "http://192.168.1.1/login",
        "https://secure-paypal-verify.com/update",
        "http://bit.ly/xyz123"
    ]
    
    print(f"Expected features: {len(EXPECTED_FEATURES)}")
    print("\nTesting feature extraction:\n")
    
    for url in test_urls:
        print(f"URL: {url}")
        features = extract_features(url)
        print(f"Extracted {len(features)} features")
        print(f"Sample features: {dict(list(features.items())[:5])}")
        print()