# Outputs the ELB tags and DNS name #
output "aws_elb" {
  value       = aws_elb.web-elb.dns_name
  description = "The DNS name of the ELB."
}

output "aws_instance" {
  value = aws_instance.Whiskey-DB.*.id
}

output "ip" {
  value = aws_instance.Whiskey-DB.*.public_ip
}
