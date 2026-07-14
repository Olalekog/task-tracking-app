output "cluster_name" {
  description = "Name of the EKS cluster used by the Helm/Argo CD installation job."
  value       = module.eks.cluster_name
}
