# shellcheck shell=bash
#
# Google Play upload for scripts/deploy_stores.sh — sourced, never run on its own.
# Uses the Play Developer API directly (curl + openssl + jq): no fastlane, no gcloud.
# Needs PKG and PLAY_SERVICE_ACCOUNT_JSON from the caller. The private key is never echoed.

API_BODY=""
ACCESS_TOKEN=""

b64url() { openssl base64 -e -A | tr '+/' '-_' | tr -d '='; }

api() { # method url [json-body] -> API_BODY; nonzero on HTTP error
  local method="$1" url="$2" data="${3-}" tmp code
  tmp=$(mktemp)
  local -a args=(-sS -o "$tmp" -w '%{http_code}' -X "$method"
                 -H "Authorization: Bearer $ACCESS_TOKEN")
  [[ -n "$data" ]] && args+=(-H "Content-Type: application/json" -d "$data")
  code=$(curl "${args[@]}" "$url") || { rm -f "$tmp"; API_BODY=""; return 1; }
  API_BODY=$(cat "$tmp"); rm -f "$tmp"
  [[ "$code" == 2* ]]
}

api_err() { jq -r '.error.message // .' <<<"${API_BODY:-}" 2>/dev/null | head -3; }

# OAuth2: sign a JWT with the service-account key, swap it for an access token.
play_authenticate() {
  local key_file sa_email now header claims sig token_json
  key_file=$(mktemp); chmod 600 "$key_file"
  trap 'rm -f "$key_file"' EXIT
  jq -r '.private_key' "$PLAY_SERVICE_ACCOUNT_JSON" > "$key_file"
  sa_email=$(jq -r '.client_email' "$PLAY_SERVICE_ACCOUNT_JSON")

  now=$(date +%s)
  header=$(printf '%s' '{"alg":"RS256","typ":"JWT"}' | b64url)
  claims=$(jq -nc --arg iss "$sa_email" --argjson iat "$now" --argjson exp "$(( now + 3600 ))" \
      '{iss:$iss,
        scope:"https://www.googleapis.com/auth/androidpublisher",
        aud:"https://oauth2.googleapis.com/token",
        iat:$iat, exp:$exp}' | b64url)
  sig=$(printf '%s.%s' "$header" "$claims" | openssl dgst -sha256 -sign "$key_file" -binary | b64url)
  rm -f "$key_file"; trap - EXIT

  token_json=$(curl -sS -X POST https://oauth2.googleapis.com/token \
    --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer" \
    --data-urlencode "assertion=${header}.${claims}.${sig}")
  ACCESS_TOKEN=$(jq -r '.access_token // empty' <<<"$token_json")
  [[ -n "$ACCESS_TOKEN" ]] || die \
    "Google rejected the service-account key: $(jq -r '.error_description // .error // .' <<<"$token_json")
  Check that the Google Play Android Developer API is enabled for the key's project."
  ok "authenticated as $sa_email"
}

play_upload_bundle() { # aab track release-notes
  local aab="$1" track="$2" notes="$3"
  local play_api="https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$PKG"
  local play_upload="https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications/$PKG"
  local edit_id up_tmp up_code up_body version_code track_body

  play_authenticate

  api POST "$play_api/edits" || die "Could not open a Play edit: $(api_err)
  Most likely the service account has not been given access to this app in
  Play Console → Users and permissions (see scripts/README_release.md)."
  edit_id=$(jq -r '.id' <<<"$API_BODY")
  info "edit $edit_id"

  info "uploading $(du -h "$aab" | cut -f1) bundle…"
  up_tmp=$(mktemp)
  up_code=$(curl -# -o "$up_tmp" -w '%{http_code}' -X POST \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/octet-stream" \
    --data-binary @"$aab" \
    "$play_upload/edits/$edit_id/bundles?uploadType=media")
  up_body=$(cat "$up_tmp"); rm -f "$up_tmp"
  [[ "$up_code" == 2* ]] || die \
    "Bundle upload failed (HTTP $up_code): $(jq -r '.error.message // .' <<<"$up_body" | head -3)
  If it mentions a version code already in use: Play burns a code permanently
  once uploaded to any track. Raise the +N in pubspec.yaml and run again."
  version_code=$(jq -r '.versionCode' <<<"$up_body")
  ok "uploaded versionCode $version_code"

  track_body=$(jq -nc --arg t "$track" --arg vc "$version_code" --arg notes "$notes" \
    '{track:$t, releases:[{versionCodes:[$vc], status:"completed",
       releaseNotes:[{language:"en-US", text:$notes}]}]}')
  api PUT "$play_api/edits/$edit_id/tracks/$track" "$track_body" \
    || die "Could not assign versionCode $version_code to '$track': $(api_err)"
  ok "assigned to $track"

  # Commit; retry unreviewed if the account lacks review rights.
  if ! api POST "$play_api/edits/$edit_id:commit"; then
    warn "commit rejected ($(api_err)) — retrying with changesNotSentForReview=true"
    api POST "$play_api/edits/$edit_id:commit?changesNotSentForReview=true" \
      || die "Commit failed: $(api_err)"
  fi
  ok "committed — live on the $track track shortly"
}
