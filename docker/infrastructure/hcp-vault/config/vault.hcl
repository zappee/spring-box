/*
 * Vault configuration. See: https://www.vaultproject.io/docs/configuration
 */
ui                      = true
cluster_name            = "${VAULT_CLUSTER_NAME}"
cluster_addr            = "${VAULT_CLUSTER_PROTOCOL}://${VAULT_CLUSTER_HOST}:${VAULT_CLUSTER_PORT}"
api_addr                = "${VAULT_API_PROTOCOL}://${VAULT_API_HOST}:${VAULT_API_PORT}"
disable_mlock           = false
disable_cache           = true
log_level               = "${VAULT_LOG_LEVEL}"

storage "file" {
  path                  = "${VAULT_FILE_STORE}"
}

listener "tcp" {
  address               = "${VAULT_TCP_HOST}:${VAULT_TCP_PORT}"
  tls_disable           = false
  tls_cert_file         = "${TLS_CERT_FILE}"
  tls_key_file          = "${TLS_KEY_FILE}"
  tls_client_ca_file    = "${TLS_CA_FILE}"
  max_token_header_size = 16384
}
