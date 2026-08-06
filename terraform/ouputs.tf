output "openwebui_public_ip" {

  value = aws_instance.openwebui.public_ip

}


output "ollama_public_ip" {

  value = aws_instance.ollama.public_ip

}