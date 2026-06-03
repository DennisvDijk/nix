# ~/.aws/config is managed by chezmoi with age encryption.
#
# To add/update the encrypted config on the work laptop:
#   chezmoi add --encrypt ~/.aws/config
#
# This creates dot_aws/encrypted_config.age in the chezmoi source.
# Commit and push to keep it in sync across reinstalls.
#
# credentials is intentionally NOT managed here — use aws-vault instead.
