output "master_ip" {
  value = yandex_compute_instance.master_vm.network_interface.0.nat_ip_address
}

output "node1_ip" {
  value = yandex_compute_instance.node1_vm.network_interface.0.nat_ip_address
}

output "node2_ip" {
  value = yandex_compute_instance.node2_vm.network_interface.0.nat_ip_address
}