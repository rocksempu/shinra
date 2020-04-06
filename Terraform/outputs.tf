output "frontend01" {
  value = "${aws_instance.frontend01.public_ip}"
}

output "frontend02" {
  value = "${aws_instance.frontend02.public_ip}"
}

output "backend01" {
  value = "${aws_instance.backend01.public_ip}"
}

output "backend02" {
  value = "${aws_instance.backend02.public_ip}"
}
