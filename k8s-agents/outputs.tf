output "kubectl_get_update_credentials" {
  description = "Run to retrieve the access credentials for the k8s and configure kubectl"
  value       = local.aws_eks_credentials_cmd
}
