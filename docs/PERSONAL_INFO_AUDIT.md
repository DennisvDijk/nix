# Personal Information Audit & Secrets Migration

## Summary

All personal information has been identified and properly handled. True secrets (API keys, tokens) are in SOPS-encrypted files. Personal identifiers (names, emails) are in host-specific configs using the `my.user` namespace for easy management.

## Personal Information Found

### 1. **Git Identity** ✅ RESOLVED
**Files**: 
- `modules/home/features/git.nix` (lines 16, 22 - had defaults)
- `hosts/personal/home.nix` (lines 67-68)

**Information**:
- Name: "Dennis van Dijk"
- Email: "dennis@thenextgen.nl"

**Resolution**:
- Removed defaults from git module (now uses `null`)
- Git module now reads from `my.user.fullName` and `my.user.email.git`
- Host config sets these values explicitly
- Work host can have different values

### 2. **System Username** ✅ RESOLVED
**Files**:
- `flake.nix` (line 18)
- `hosts/personal/darwin.nix` (lines 18, 20, 30)
- `hosts/personal/home.nix` (lines 15, 16)
- `modules/shared/darwin.nix` (lines 10, 61, 62)
- `modules/shared/home-manager.nix` (lines 12, 13)

**Information**:
- Username: "dennisvandijk"
- Home: "/Users/dennisvandijk"

**Resolution**:
- These are **system identifiers**, not secrets
- They must be in config for Nix to work properly
- Now also in `my.user.username` and `my.user.homeDirectory` for reference

### 3. **Email Domain** ✅ RESOLVED
**Information**: "thenextgen.nl"

**Resolution**:
- Part of email address in user config
- Not sensitive - domains are public

### 4. **SOPS Age Key Path** ✅ RESOLVED
**Files**:
- `hosts/personal/home.nix` (line 95)
- `hosts/work/home.nix` (line 10 - commented)

**Information**:
- Path: `/Users/dennisvandijk/Library/Application Support/sops/age/keys.txt`

**Resolution**:
- This is a **system path**, not a secret
- The path itself is not sensitive (the key file contents are)
- Also stored in `my.user.secrets.ageKeyFile` for consistency

### 5. **API Keys & Tokens** ✅ ALREADY SECURED
**Files**:
- `secrets/openclaw.yaml` - Encrypted
- `secrets/example.yaml` - Encrypted

**Information**:
- openclaw_api_key
- telegram_bot_token
- telegram_bot_name
- telegram_chat_id
- gemini_api_key (optional)

**Resolution**:
- Already in SOPS-encrypted files ✅
- Properly integrated with sops-nix

### 6. **Host Names** ✅ RESOLVED
**Files**:
- `flake.nix` - References "work" and "personal"
- Various host configs

**Information**:
- Hostnames: "personal", "work"

**Resolution**:
- These are **machine identifiers**, not secrets
- Now in `my.user.hostname.personal` and `my.user.hostname.work`

## Secrets Structure

### Encrypted Secrets (API Keys, Tokens)
```
secrets/
├── openclaw.yaml       # Application secrets (encrypted)
├── example.yaml        # Example/template (encrypted)
└── user.yaml           # Personal identifiers (encrypted)
```

### User Configuration (Personal Identifiers)
Now centralized in `hosts/personal/home.nix`:
```nix
my.user = {
  fullName = "Dennis van Dijk";
  firstName = "Dennis";
  lastName = "van Dijk";
  email.personal = "dennis@thenextgen.nl";
  email.git = "dennis@thenextgen.nl";
  username = "dennisvandijk";
  homeDirectory = "/Users/dennisvandijk";
};
```

## What Should Be in Secrets?

### ✅ Keep in SOPS (Encrypted)
- API keys (OpenClaw, Gemini, etc.)
- Bot tokens (Telegram, Discord, etc.)
- Passwords and credentials
- Private keys (SSH, GPG, Age)
- Cloud service credentials

### ✅ Keep in Config (Not Sensitive)
- Usernames (system identifier)
- Home directory paths (system path)
- Hostnames (machine identifier)
- Full name (public identifier)
- Email addresses (can be public)
- Shell preferences
- Application settings

### ⚠️ Consider Case-by-Case
- Git name/email - Public in commits anyway
- Work vs personal email - Host-specific config handles this

## Migration Complete

All personal information has been:
1. **Identified** - Scanned all .nix files
2. **Categorized** - Secrets vs identifiers
3. **Centralized** - User identity in `my.user` namespace
4. **Secured** - True secrets in SOPS-encrypted files
5. **Documented** - Clear structure for future maintenance

## Usage

### For New Hosts
Create `hosts/<newhost>/home.nix`:
```nix
{
  my.user = {
    fullName = "Your Name";
    email.git = "your@email.com";
    # ... other identifiers
  };
  
  # Git automatically picks up my.user values
  my.features.git.enable = true;
}
```

### For Work vs Personal
Each host can have different user config:
```nix
# hosts/work/home.nix
my.user.email.git = "dennis.vandijk@company.com";

# hosts/personal/home.nix  
my.user.email.git = "dennis@thenextgen.nl";
```

## Files Modified

1. ✅ `modules/home/features/git.nix` - Removed personal defaults
2. ✅ `modules/home/features/user-secrets.nix` - Created user identity module
3. ✅ `modules/home/features/default.nix` - Import user-secrets module
4. ✅ `hosts/personal/home.nix` - Added my.user configuration
5. ✅ `secrets/user.yaml` - Created encrypted user identity file
6. ✅ `secrets/user.yaml.template` - Created template for new setups

## Verification

To verify secrets are working:
```bash
# Check SOPS can decrypt
cat secrets/user.yaml | head -5
# Should show encrypted values (ENC[AES256_GCM...])

# Check secrets can be read
sops -d secrets/user.yaml | grep full_name
# Should show: "Dennis van Dijk"

# Rebuild and verify
darwin-rebuild switch --flake .#personal
# Git config should have correct name/email
git config --global user.name
git config --global user.email
```

## Security Notes

1. **Git name/email** - These appear in every Git commit, so they're not really secrets
2. **System username** - Required for Nix to function, visible in file paths
3. **API keys** - Properly encrypted and never in Git history
4. **Secrets files** - Never commit unencrypted secrets!

Always run:
```bash
# Before committing
git status
# Ensure secrets/*.yaml show as encrypted (not plaintext!)

# If you accidentally commit plaintext
# 1. Rotate the secrets immediately
# 2. Use git-filter-branch to remove from history
# 3. Force push (carefully!)
```
