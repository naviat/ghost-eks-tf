locals {
  service_account_name = "vpa-sa"
  namespace            = "vpa-ns"

  default_helm_config = {
    name                       = "vpa"
    chart                      = "vpa"
    repository                 = "https://charts.fairwinds.com/stable"
    version                    = "0.5.0"
    namespace                  = "vpa-ns"
    timeout                    = "1200"
    create_namespace           = true
    description                = "Kubernetes Vertical Pod Autoscaler"
    lint                       = false
    wait                       = true
    wait_for_jobs              = false
    verify                     = false
    keyring                    = ""
    repository_key_file        = ""
    repository_cert_file       = ""
    repository_ca_file         = ""
    repository_username        = ""
    repository_password        = ""
    disable_webhooks           = false
    reuse_values               = false
    reset_values               = false
    force_update               = false
    recreate_pods              = false
    cleanup_on_fail            = false
    max_history                = 0
    atomic                     = false
    skip_crds                  = false
    render_subchart_notes      = true
    disable_openapi_validation = false
    dependency_update          = false
    replace                    = false
    postrender                 = ""
    set                        = []
    set_sensitive              = []
    values                     = local.default_helm_values
  }
  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    vpa_sa_name = local.service_account_name
  })]


}
